import Gym from "../../models/Gym.js";
import User from "../../models/User.js";
import GymJoinRequest from "../../models/GymJoinRequest.js";
import {
  approveJoinRequest,
  createJoinRequest,
  getPendingRequestsForOwner,
  rejectJoinRequest,
} from "../../services/gym.service.js";

export const joinRequest = async (req, res, next) => {
  try {
    const request = await createJoinRequest(req.user.userId, req.body.gymToken);
    return res.status(201).json({ success: true, data: request });
  } catch (error) {
    next(error);
  }
};

export const listPendingRequests = async (req, res, next) => {
  try {
    const requests = await getPendingRequestsForOwner(req.user.userId);
    return res
      .status(200)
      .json({ success: true, count: requests.length, data: requests });
  } catch (error) {
    next(error);
  }
};

export const approveRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    await approveJoinRequest(requestId, req.user.userId);

    return res
      .status(200)
      .json({ success: true, message: "Join request approved successfully." });
  } catch (error) {
    next(error);
  }
};

export const rejectRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const request = await rejectJoinRequest(requestId, req.user.userId);
    return res.status(200).json({ success: true, data: request });
  } catch (error) {
    next(error);
  }
};

export const getGymMembers = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const members = await User.find({
      gymId: gym._id,
      role: "gym_member",
    }).select("-password");
    return res
      .status(200)
      .json({ success: true, count: members.length, data: members });
  } catch (error) {
    next(error);
  }
};

export const getInactiveMembers = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const days = parseInt(req.query.days, 10) || 3;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - days);

    const inactiveMembers = await User.find({
      gymId: gym._id,
      role: "gym_member",
      lastActiveAt: { $lt: cutoffDate },
    }).select("-password");

    return res
      .status(200)
      .json({
        success: true,
        count: inactiveMembers.length,
        data: inactiveMembers,
      });
  } catch (error) {
    next(error);
  }
};
