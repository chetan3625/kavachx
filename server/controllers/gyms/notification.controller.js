import User from "../../models/User.js";
import Gym from "../../models/Gym.js";
import Notification from "../../models/Notification.js";
import { sendMultiplePushNotifications } from "../../config/firebase.js";
import { getIO } from "../../config/socket.js";
import asyncHandler from "../../utils/AsyncHandler.js";
import ApiError from "../../utils/ApiError.js";

// POST /api/v1/gyms/announce (Owner Only)
export const sendGymAnnouncement = asyncHandler(async (req, res) => {
  const { title, message, type = "announcement" } = req.body;
  const ownerId = req.user.userId;

  if (!title || !message) {
    throw new ApiError(400, "Title and message are required.");
  }

  // 1. Fetch Owner's active gym
  const gym = await Gym.findOne({ ownerId, isActive: true });
  if (!gym) {
    throw new ApiError(404, "No active gym associated with this account.");
  }

  // 2. Fetch all members associated with this gym
  const members = await User.find({
    gymId: gym._id,
    role: "gym_member",
  }).select("_id fcmToken");
  if (!members || members.length === 0) {
    return res.status(200).json({
      success: true,
      message: "No active members found in your gym to notify.",
    });
  }

  const memberIds = members.map((m) => m._id);
  const fcmTokens = members.map((m) => m.fcmToken).filter(Boolean);

  // 3. Batch insert notifications into MongoDB
  const notificationsPayload = memberIds.map((userId) => ({
    userId,
    gymId: gym._id,
    title,
    message,
    type,
    isRead: false,
  }));
  await Notification.insertMany(notificationsPayload);

  // 4. Dispatch FCM Batch Push Notifications
  if (fcmTokens.length > 0) {
    await sendMultiplePushNotifications(fcmTokens, title, message, {
      type,
      gymId: gym._id.toString(),
    });
  }

  // 5. Emit Real-time Socket.IO event to member and gym rooms
  try {
    const io = getIO();
    const gymIdStr = gym._id.toString();

    io.to(`gym_${gymIdStr}`).emit("new_announcement", {
      title,
      message,
      type,
      createdAt: new Date(),
    });

    memberIds.forEach((mId) => {
      io.to(`member_${mId.toString()}`).emit("new_notification", {
        title,
        message,
        type,
        createdAt: new Date(),
      });
    });
  } catch (err) {
    console.error("Socket emit error (sendGymAnnouncement):", err.message);
  }

  return res.status(200).json({
    success: true,
    message: `Announcement broadcasted to ${members.length} member(s).`,
  });
});
