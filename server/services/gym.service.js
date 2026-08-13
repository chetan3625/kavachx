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
  const existingMembership = await Membership.findOne({ memberId, gymId: gym._id });

  if (existingMembership) {
    throw new ApiError(400, "Member already belongs to this gym");
  }

  // Check pending request
  const existingRequest = await GymJoinRequest.findOne({ memberId, gymId: gym._id, status: "pending" });

  if (existingRequest) {
    throw new ApiError(400, "There is already a pending join request for this gym");
  }

  const reqDoc = await GymJoinRequest.create({ memberId, gymId: gym._id });

  const populatedReq = await GymJoinRequest.findById(reqDoc._id)
    .populate("memberId", "name email phone")
    .populate("gymId", "name");

  // Emit real-time Socket.IO event to Gym Owner's room
  try {
    const io = getIO();
    const ownerIdStr = gym.ownerId._id ? gym.ownerId._id.toString() : gym.ownerId.toString();
    const gymIdStr = gym._id.toString();

    console.log(`[SOCKET.IO SERVER] Emitting new_join_request to rooms: owner_${ownerIdStr} and gym_${gymIdStr}`);
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
    .populate("memberId", "name email phone")
    .populate("gymId", "name");

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

  if (reqDoc.status === "approved") {
    // Already approved - ensure membership & user gymId are linked and return gracefully
    await Membership.findOneAndUpdate(
      { memberId: reqDoc.memberId, gymId: reqDoc.gymId },
      { memberId: reqDoc.memberId, gymId: reqDoc.gymId, status: "active" },
      { upsert: true, new: true }
    );
    await User.findByIdAndUpdate(reqDoc.memberId, { gymId: reqDoc.gymId });
    return reqDoc;
  }

  if (reqDoc.status !== "pending") {
    throw new ApiError(400, `Request status is currently '${reqDoc.status}' and cannot be approved.`);
  }

  reqDoc.status = "approved";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;

  await reqDoc.save();

  // Create or update membership (safely upserting without duplicate key error)
  await Membership.findOneAndUpdate(
    { memberId: reqDoc.memberId, gymId: reqDoc.gymId },
    { memberId: reqDoc.memberId, gymId: reqDoc.gymId, status: "active" },
    { upsert: true, new: true }
  );
  await User.findByIdAndUpdate(reqDoc.memberId, { gymId: reqDoc.gymId });

  // Emit real-time Socket.IO event
  try {
    const io = getIO();
    const memberIdStr = reqDoc.memberId._id ? reqDoc.memberId._id.toString() : reqDoc.memberId.toString();
    const ownerIdStr = ownerId._id ? ownerId._id.toString() : ownerId.toString();

    console.log(`[SOCKET.IO SERVER] Emitting join_request_updated (approved) to member_${memberIdStr} and owner_${ownerIdStr}`);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", reqDoc);
    io.to(`member_${memberIdStr}`).emit("join_request_updated", reqDoc);
    io.emit("join_request_updated", reqDoc); // Broadcast fallback
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

  if (reqDoc.status === "rejected") {
    return reqDoc;
  }

  if (reqDoc.status !== "pending") {
    throw new ApiError(400, `Request status is currently '${reqDoc.status}' and cannot be rejected.`);
  }

  reqDoc.status = "rejected";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;

  await reqDoc.save();

  // Emit real-time Socket.IO event
  try {
    const io = getIO();
    const memberIdStr = reqDoc.memberId._id ? reqDoc.memberId._id.toString() : reqDoc.memberId.toString();
    const ownerIdStr = ownerId._id ? ownerId._id.toString() : ownerId.toString();

    console.log(`[SOCKET.IO SERVER] Emitting join_request_updated (rejected) to member_${memberIdStr} and owner_${ownerIdStr}`);
    io.to(`owner_${ownerIdStr}`).emit("join_request_updated", reqDoc);
    io.to(`member_${memberIdStr}`).emit("join_request_updated", reqDoc);
    io.emit("join_request_updated", reqDoc); // Broadcast fallback
  } catch (err) {
    console.error("Socket emit error (rejectJoinRequest):", err.message);
  }

  return reqDoc;
};
