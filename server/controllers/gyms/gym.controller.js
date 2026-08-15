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

    // 1. Get all members belonging to this gym (via User and Membership)
    const directUsers = await User.find({
      gymId: gym._id,
      role: "gym_member",
    }).select("_id");

    const { default: Membership } = await import("../../models/Membership.js");
    const memberships = await Membership.find({
      gymId: gym._id,
      status: { $in: ["active", "trial"] },
    }).select("memberId");

    const memberIds = Array.from(
      new Set([
        ...directUsers.map((u) => u._id.toString()),
        ...memberships.map((m) => m.memberId?.toString()).filter(Boolean),
      ]),
    );

    if (memberIds.length === 0) {
      return res.status(200).json({ success: true, count: 0, data: [] });
    }

    const { default: Attendance } = await import("../../models/Attendance.js");

    const inactiveMembersList = [];

    for (const mId of memberIds) {
      const user = await User.findById(mId).select("-password");
      if (!user) continue;

      // Find latest attendance for member
      const latestAttendance = await Attendance.findOne({ memberId: mId }).sort({
        createdAt: -1,
      });

      // Determine member's latest active date (most recent of lastActiveAt or latest check-in)
      let latestActivity = user.lastActiveAt || user.createdAt;
      if (latestAttendance && latestAttendance.checkInTime) {
        const attDate = new Date(latestAttendance.checkInTime);
        if (attDate > new Date(latestActivity)) {
          latestActivity = attDate;
        }
      }

      if (new Date(latestActivity) < cutoffDate) {
        inactiveMembersList.push({
          ...user.toObject(),
          lastActiveAt: latestActivity,
        });
      }
    }

    return res.status(200).json({
      success: true,
      count: inactiveMembersList.length,
      data: inactiveMembersList,
    });
  } catch (error) {
    next(error);
  }
};

export const getTodayCheckIns = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0");
    const day = String(now.getDate()).padStart(2, "0");
    const todayStr = `${year}-${month}-${day}`;

    // Find member IDs for this gym
    const directUsers = await User.find({
      gymId: gym._id,
      role: "gym_member",
    }).select("_id");

    const { default: Membership } = await import("../../models/Membership.js");
    const memberships = await Membership.find({
      gymId: gym._id,
      status: { $in: ["active", "trial"] },
    }).select("memberId");

    const allMemberIds = Array.from(
      new Set([
        ...directUsers.map((u) => u._id.toString()),
        ...memberships.map((m) => m.memberId?.toString()).filter(Boolean),
      ]),
    );

    const { default: Attendance } = await import("../../models/Attendance.js");

    const todayAttendances = await Attendance.find({
      $or: [
        { gymId: gym._id, dateString: todayStr },
        { gymId: gym._id, dateStr: todayStr },
        { memberId: { $in: allMemberIds }, dateString: todayStr },
        { memberId: { $in: allMemberIds }, dateStr: todayStr },
      ],
    }).populate("memberId", "name email phone profileImage");

    return res.status(200).json({
      success: true,
      count: todayAttendances.length,
      data: todayAttendances,
    });
  } catch (error) {
    next(error);
  }
};
