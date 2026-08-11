import Gym from "../models/Gym.js";
import GymJoinRequest from "../models/GymJoinRequest.js";
import Membership from "../models/Membership.js";
import ApiError from "../utils/ApiError.js";

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

  return reqDoc;
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

  if (reqDoc.status !== "pending") {
    throw new ApiError(400, "Request is not pending");
  }

  reqDoc.status = "approved";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;

  await reqDoc.save();

  // Create membership (unique index prevents duplicates)
  await Membership.create({ memberId: reqDoc.memberId, gymId: reqDoc.gymId });

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

  if (reqDoc.status !== "pending") {
    throw new ApiError(400, "Request is not pending");
  }

  reqDoc.status = "rejected";
  reqDoc.reviewedAt = new Date();
  reqDoc.reviewedBy = ownerId;

  await reqDoc.save();

  return reqDoc;
};
