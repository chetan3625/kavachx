import asyncHandler from "../../utils/AsyncHandler.js";
import {
  createJoinRequest,
  getPendingRequestsForOwner,
  approveJoinRequest,
  rejectJoinRequest,
  getRequestById
} from "../../services/gym.service.js";

import ApiError from "../../utils/ApiError.js";

export const joinRequest = asyncHandler(async (req, res) => {
  const { gymToken } = req.body;

  if (!gymToken) {
    throw new ApiError(400, "gymToken is required");
  }

  const memberId = req.user.userId;

  // Ensure role
  if (req.user.role !== "gym_member") {
    throw new ApiError(403, "Only gym members can request to join a gym");
  }

  const reqDoc = await createJoinRequest(memberId, gymToken);

  res.status(201).json({ success: true, message: "Join request created", data: reqDoc });
});

export const listPendingRequests = asyncHandler(async (req, res) => {
  const ownerId = req.user.userId;

  if (req.user.role !== "gym_owner") {
    throw new ApiError(403, "Only gym owners can view join requests");
  }

  const requests = await getPendingRequestsForOwner(ownerId);

  res.status(200).json({ success: true, data: requests });
});

export const approveRequest = asyncHandler(async (req, res) => {
  const { requestId } = req.params;
  const ownerId = req.user.userId;

  if (req.user.role !== "gym_owner") {
    throw new ApiError(403, "Only gym owners can approve requests");
  }

  const reqDoc = await approveJoinRequest(requestId, ownerId);

  res.status(200).json({ success: true, message: "Request approved", data: reqDoc });
});

export const rejectRequest = asyncHandler(async (req, res) => {
  const { requestId } = req.params;
  const ownerId = req.user.userId;

  if (req.user.role !== "gym_owner") {
    throw new ApiError(403, "Only gym owners can reject requests");
  }

  const reqDoc = await rejectJoinRequest(requestId, ownerId);

  res.status(200).json({ success: true, message: "Request rejected", data: reqDoc });
});
