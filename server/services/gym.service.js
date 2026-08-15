import Gym from "../models/Gym.js";
import GymJoinRequest from "../models/GymJoinRequest.js";
import Membership from "../models/Membership.js";
import User from "../models/User.js";
import ApiError from "../utils/ApiError.js";
import { getIO } from "../config/socket.js";
import admin from "../config/firebase.js";

// Helper to dispatch high-priority FCM notifications with system tray fallback
export const sendFcmNotification = async (fcmToken, title, message) => {
  if (!fcmToken) return;

  const payload = {
    token: fcmToken,
    notification: {
      title: title,
      body: message,
    },
    data: {
      type: "announcement",
      title: title,
      message: message,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
        sound: "default",
        priority: "max",
      },
    },
  };

  try {
    const response = await admin.messaging().send(payload);
    console.log("[FCM SUCCESS] Message sent:", response);
  } catch (error) {
    console.error("[FCM ERROR] Failed to send push:", error.message);
  }
};

export const createJoinRequest = async (memberId, gymToken) => {
  const gym = await Gym.findOne({ gymToken, isActive: true });

  if (!gym) {
    throw new ApiError(404, "Invalid or inactive gym token");
  }

  const existingMembership = await Membership.findOne({ memberId, gymId: gym._id });
  if (existingMembership) {
    throw new ApiError(400, "Member already belongs to this gym");
  }

  const existingRequest = await GymJoinRequest.findOne({ userId: memberId, gymId: gym._id, status: "pending" });
  if (existingRequest) {
    throw new ApiError(400, "There is already a pending join request for this gym");
  }

  const reqDoc = await GymJoinRequest.create({ userId: memberId, gymId: gym._id });

  const populatedReq = await GymJoinRequest.findById(reqDoc._id)
    .populate("userId", "name email phone role gymId isOnboarded")
    .populate("gymId", "name phone address gymToken qrUrl");

  try {
    const io = getIO();
    const ownerIdStr = gym.ownerId._id ? gym.ownerId._id.toString() : gym.ownerId.toString();
    const gymIdStr = gym._id.toString();

    io.to(`owner_${ownerIdStr}`).emit("new_join_request", populatedReq);
    io.to(`gym_${gymIdStr}`).emit("new_join_request", populatedReq);
  } catch (err) {
    console.error("Socket emit error (createJoinRequest):", err.message);
  }

  return populatedReq;
};

export const getPendingRequestsForOwner = async (ownerId) => {
  const gyms = await Gym.find({ ownerId }).select("_id");
  const gymIds = gyms.map((g) => g._id);

  const requests = await GymJoinRequest.find({ gymId: { $in: gymIds }, status: "pending" })
    .populate("userId", "name email phone role gymId isOnboarded")
    .populate("gymId", "name phone address gymToken qrUrl");

  return requests;
};

export const getRequestById = async (requestId) => {
  const reqDoc = await GymJoinRequest.findById(requestId);
  if (!reqDoc) {
    throw new ApiError(404, "Join request not found");
  }
  return reqDoc;
};

export const approveJoinRequest = async (requestId, ownerId) => {
  const reqDoc = await GymJoinRequest.findById(requestId);
  if (!reqDoc) {
    throw new ApiError(404, "Join request not found");
  }

  const gym = await Gym.findById(reqDoc.gymId);
  if (!gym) {
    throw new ApiError(404, "Gym not found");
  }

  if (gym.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, "Not authorized to approve this request");
  }

  reqDoc.status = "approved";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;
  await reqDoc.save();

  const startDate = new Date();
  const endDate = new Date();
  endDate.setDate(endDate.getDate() + 7);

  await Membership.findOneAndUpdate(
    { memberId: reqDoc.userId, gymId: reqDoc.gymId },
    {
      memberId: reqDoc.userId,
      gymId: reqDoc.gymId,
      status: "trial",
      planName: "7-Day Free Trial",
      price: 0,
      durationInMonths: 0,
      trialDays: 7,
      startDate,
      endDate,
      features: [
        "Full Gym Equipment Access",
        "Free Trainer Guidance",
        "Locker & Shower Facilities",
      ],
      joinedAt: startDate,
    },
    { upsert: true, new: true }
  );

  const updatedUser = await User.findByIdAndUpdate(
    reqDoc.userId,
    { gymId: reqDoc.gymId, isApproved: true },
    { new: true, runValidators: true }
  ).select("-password").populate("gymId", "name phone address gymToken qrUrl");

  const socketPayload = {
    request: reqDoc,
    status: "approved",
    gym: gym,
    user: {
      id: updatedUser._id.toString(),
      _id: updatedUser._id.toString(),
      name: updatedUser.name,
      email: updatedUser.email,
      phone: updatedUser.phone,
      role: updatedUser.role,
      gymId: updatedUser.gymId ? updatedUser.gymId._id.toString() : gym._id.toString(),
      gym: gym,
      isOnboarded: updatedUser.isOnboarded,
    },
  };

  try {
    const io = getIO();
    const memberIdStr = reqDoc.userId._id ? reqDoc.userId._id.toString() : reqDoc.userId.toString();
    const ownerIdStr = ownerId._id ? ownerId._id.toString() : ownerId.toString();

    io.to(`member_${memberIdStr}`).emit("join_request_updated", socketPayload);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", socketPayload);
    io.emit("join_request_updated", socketPayload);
  } catch (err) {
    console.error("Socket emit error (approveJoinRequest):", err.message);
  }

  // Send FCM notification for join request approval
  if (updatedUser.fcmToken) {
    sendFcmNotification(
      updatedUser.fcmToken,
      "Join Request Approved 🎉",
      `Welcome to ${gym.name}! Your free trial is now active.`
    );
  }

  return reqDoc;
};

export const rejectJoinRequest = async (requestId, ownerId) => {
  const reqDoc = await GymJoinRequest.findById(requestId);
  if (!reqDoc) {
    throw new ApiError(404, "Join request not found");
  }

  const gym = await Gym.findById(reqDoc.gymId);
  if (!gym) {
    throw new ApiError(404, "Gym not found");
  }

  if (gym.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, "Not authorized to reject this request");
  }

  reqDoc.status = "rejected";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;
  await reqDoc.save();

  const socketPayload = {
    request: reqDoc,
    status: "rejected",
    gym: gym,
  };

  try {
    const io = getIO();
    const memberIdStr = reqDoc.userId._id ? reqDoc.userId._id.toString() : reqDoc.userId.toString();
    const ownerIdStr = ownerId._id ? ownerId._id.toString() : ownerId.toString();

    io.to(`member_${memberIdStr}`).emit("join_request_updated", socketPayload);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", socketPayload);
    io.emit("join_request_updated", socketPayload);
  } catch (err) {
    console.error("Socket emit error (rejectJoinRequest):", err.message);
  }

  return reqDoc;
};

export const broadcastAnnouncement = async (ownerId, title, message) => {
  const gym = await Gym.findOne({ ownerId });
  if (!gym) {
    throw new ApiError(404, "Gym not found for this owner");
  }

  const members = await User.find({ gymId: gym._id, role: "gym_member" }).select("fcmToken _id");

  // 1. Socket emit to online member rooms
  try {
    const io = getIO();
    io.to(`gym_${gym._id.toString()}`).emit("announcement", { title, message });
  } catch (err) {
    console.error("Socket broadcast error:", err.message);
  }

  // 2. Push FCM notification to all registered member device tokens
  let sentCount = 0;
  for (const member of members) {
    if (member.fcmToken) {
      await sendFcmNotification(member.fcmToken, title, message);
      sentCount++;
    }
  }

  return { message: `Announcement broadcasted to ${sentCount} member(s).` };
};