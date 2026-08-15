import User from "../../models/User.js";
import Gym from "../../models/Gym.js";
import Notification from "../../models/Notification.js";
import Membership from "../../models/Membership.js";
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

    // 1. Find user IDs from User model
    const directUsers = await User.find({
      gymId: gym._id,
      role: "gym_member",
    }).select("_id fcmToken");

    // 2. Find user IDs from Membership model
    const memberships = await Membership.find({
      gymId: gym._id,
      status: { $in: ["active", "trial"] },
    }).select("memberId");

    const membershipUserIds = memberships
      .map((m) => m.memberId)
      .filter(Boolean);

    // Combine all unique member IDs
    const allUserIdsSet = new Set([
      ...directUsers.map((u) => u._id.toString()),
      ...membershipUserIds.map((id) => id.toString()),
    ]);

    const memberIdsList = Array.from(allUserIdsSet);

    if (memberIdsList.length === 0) {
      return res
        .status(200)
        .json({ success: true, message: "No active members to notify." });
    }

    // Fetch full user records for target member IDs to collect FCM tokens
    const members = await User.find({
      _id: { $in: memberIdsList },
    }).select("_id fcmToken");

    const fcmTokens = Array.from(
      new Set(members.map((m) => m.fcmToken).filter(Boolean))
    );

    // Batch Insert Notifications to DB
    const notifications = memberIdsList.map((userId) => ({
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
        const response = await firebaseConfig.sendMultiplePushNotifications(
          fcmTokens,
          title,
          message,
          {
            type,
            gymId: gym._id.toString(),
          },
        );
        console.log(`[FCM Notice] Multicast dispatched to ${fcmTokens.length} token(s). Response:`, response);
      } else {
        console.log(`[FCM Notice] Skipped push: ${fcmTokens.length} FCM tokens available.`);
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
      message: `Announcement broadcasted to ${memberIdsList.length} member(s).`,
    });
  } catch (error) {
    next(error);
  }
};
