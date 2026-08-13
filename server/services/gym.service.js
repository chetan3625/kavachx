import Gym from "../models/Gym.js";
import GymJoinRequest from "../models/GymJoinRequest.js";
import Membership from "../models/Membership.js";
import User from "../models/User.js";
import ApiError from "../utils/ApiError.js";
import { getIO } from "../config/socket.js";

export const createJoinRequest = async (memberId, gymToken) => {
  const gym = await Gym.findOne({ gymToken, isActive: true });

  if (!gym) {
    throw new ApiError(404, "Invalid or inactive gym token");
  }

  // Check existing membership
  const existingMembership = await Membership.findOne({
    memberId,
    gymId: gym._id,
  });

  if (existingMembership) {
    throw new ApiError(400, "Member already belongs to this gym");
  }

  // Check pending request
  const existingRequest = await GymJoinRequest.findOne({
    userId: memberId,
    gymId: gym._id,
    status: "pending",
  });

  if (existingRequest) {
    throw new ApiError(
      400,
      "There is already a pending join request for this gym",
    );
  }

  const reqDoc = await GymJoinRequest.create({
    userId: memberId,
    gymId: gym._id,
  });

  const populatedReq = await GymJoinRequest.findById(reqDoc._id)
    .populate("userId", "name email phone role gymId isOnboarded")
    .populate("gymId", "name phone address gymToken qrUrl");

  // Emit real-time Socket.IO event to Gym Owner's room
  try {
    const io = getIO();
    const ownerIdStr = gym.ownerId._id
      ? gym.ownerId._id.toString()
      : gym.ownerId.toString();
    const gymIdStr = gym._id.toString();

    console.log(
      `[SOCKET.IO SERVER] Emitting new_join_request to rooms: owner_${ownerIdStr} and gym_${gymIdStr}`,
    );
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

  const requests = await GymJoinRequest.find({
    gymId: { $in: gymIds },
    status: "pending",
  })
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

  // 1. Update Join Request Status
  reqDoc.status = "approved";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;
  await reqDoc.save();

  // 2. Create or update active Membership
  await Membership.findOneAndUpdate(
    { memberId: reqDoc.userId, gymId: reqDoc.gymId },
    { memberId: reqDoc.userId, gymId: reqDoc.gymId, status: "active" },
    { upsert: true, new: true },
  );

  // 3. Link gymId to User and populate updated user details
  const updatedUser = await User.findByIdAndUpdate(
    reqDoc.userId,
    { gymId: reqDoc.gymId, isApproved: true },
    { new: true, runValidators: true },
  )
    .select("-password")
    .populate("gymId", "name phone address gymToken qrUrl");

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
      gymId: updatedUser.gymId
        ? updatedUser.gymId._id.toString()
        : gym._id.toString(),
      gym: gym,
      isOnboarded: updatedUser.isOnboarded,
    },
  };

  // 4. Emit real-time Socket.IO event to Member & Owner rooms
  try {
    const io = getIO();
    const memberIdStr = reqDoc.userId._id
      ? reqDoc.userId._id.toString()
      : reqDoc.userId.toString();
    const ownerIdStr = ownerId._id
      ? ownerId._id.toString()
      : ownerId.toString();

    console.log(
      `[SOCKET.IO SERVER] Emitting join_request_updated (approved) to member_${memberIdStr} and owner_${ownerIdStr}`,
    );
    io.to(`member_${memberIdStr}`).emit("join_request_updated", socketPayload);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", socketPayload);
    io.emit("join_request_updated", socketPayload); // Fallback broadcast
  } catch (err) {
    console.error("Socket emit error (approveJoinRequest):", err.message);
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

  // Emit real-time Socket.IO event
  try {
    const io = getIO();
    const memberIdStr = reqDoc.userId._id
      ? reqDoc.userId._id.toString()
      : reqDoc.userId.toString();
    const ownerIdStr = ownerId._id
      ? ownerId._id.toString()
      : ownerId.toString();

    console.log(
      `[SOCKET.IO SERVER] Emitting join_request_updated (rejected) to member_${memberIdStr} and owner_${ownerIdStr}`,
    );
    io.to(`member_${memberIdStr}`).emit("join_request_updated", socketPayload);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", socketPayload);
    io.emit("join_request_updated", socketPayload); // Fallback broadcast
  } catch (err) {
    console.error("Socket emit error (rejectJoinRequest):", err.message);
  }

  return reqDoc;
};
