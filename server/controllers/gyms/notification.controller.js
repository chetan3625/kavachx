import User from "../../models/User.js";
import Gym from "../../models/Gym.js";
import Notification from "../../models/Notification.js";
import { getIO } from "../../config/socket.js";

export const sendGymAnnouncement = async (req, res, next) => {
  try {
    const { title, message, type = "announcement" } = req.body;
    const ownerId = req.user.userId;

    if (!title || !message) {
      return res
        .status(400)
        .json({ success: false, message: "Title and message are required." });
    }

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const members = await User.find({
      gymId: gym._id,
      role: "gym_member",
    }).select("_id fcmToken");
    if (!members || members.length === 0) {
      return res
        .status(200)
        .json({ success: true, message: "No active members to notify." });
    }

    const memberIds = members.map((m) => m._id);
    const fcmTokens = members.map((m) => m.fcmToken).filter(Boolean);

    // Batch Insert to DB
    const notifications = memberIds.map((userId) => ({
      userId,
      gymId: gym._id,
      title,
      message,
      type,
    }));
    await Notification.insertMany(notifications);

    // Dispatch FCM
    try {
      const firebaseConfig = await import("../../config/firebase.js");
      if (
        firebaseConfig.sendMultiplePushNotifications &&
        fcmTokens.length > 0
      ) {
        await firebaseConfig.sendMultiplePushNotifications(
          fcmTokens,
          title,
          message,
          {
            type,
            gymId: gym._id.toString(),
          },
        );
      }
    } catch (fbErr) {
      console.log("[Notice] FCM skipped:", fbErr.message);
    }

    // Dispatch Socket Event
    try {
      const io = getIO();
      io.to(`gym_${gym._id.toString()}`).emit("new_announcement", {
        title,
        message,
        type,
        createdAt: new Date(),
      });
    } catch (sktErr) {
      console.error("Socket emit error:", sktErr.message);
    }

    return res.status(200).json({
      success: true,
      message: `Announcement broadcasted to ${members.length} member(s).`,
    });
  } catch (error) {
    next(error);
  }
};
