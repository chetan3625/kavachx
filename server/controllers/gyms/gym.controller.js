import JoinRequest from "../../models/GymJoinRequest.js";
import User from "../../models/User.js";
import Gym from "../../models/Gym.js";
import Membership from "../../models/Membership.js";
import Attendance from "../../models/Attendance.js";
import {
  createJoinRequest,
  getPendingRequestsForOwner,
  approveJoinRequest,
  rejectJoinRequest,
} from "../../services/gym.service.js";

// POST /api/v1/gyms/join-request
export const joinRequest = async (req, res, next) => {
  try {
    const memberId = req.user.userId;
    const { gymToken } = req.body;

    if (!gymToken) {
      return res
        .status(400)
        .json({ success: false, message: "Gym token is required." });
    }

    const reqDoc = await createJoinRequest(memberId, gymToken);

    return res.status(201).json({
      success: true,
      message: "Join request submitted successfully.",
      data: reqDoc,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/gyms/join-requests
export const listPendingRequests = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const requests = await getPendingRequestsForOwner(ownerId);

    return res.status(200).json({
      success: true,
      data: requests,
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/gyms/join-requests/:requestId/approve
export const approveRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const ownerId = req.user.userId;

    const reqDoc = await approveJoinRequest(requestId, ownerId);

    return res.status(200).json({
      success: true,
      message: "Join request approved successfully.",
      data: reqDoc,
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/gyms/join-requests/:requestId/reject
export const rejectRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const ownerId = req.user.userId;

    const reqDoc = await rejectJoinRequest(requestId, ownerId);

    return res.status(200).json({
      success: true,
      message: "Join request rejected successfully.",
      data: reqDoc,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/gyms/members
export const getGymMembers = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "No active gym found." });
    }

    const memberships = await Membership.find({
      gymId: gym._id,
      status: "active",
    })
      .populate({
        path: "memberId",
        select:
          "name email phone profileImage currentWeightKg targetWeightKg fitnessGoal createdAt",
      })
      .sort({ createdAt: -1 });

    const membersData = memberships.map((m) => {
      const user = m.memberId || {};
      return {
        id: user._id?.toString() || m._id.toString(),
        name: user.name || "Member",
        email: user.email || "",
        phone: user.phone || "",
        profileImage: user.profileImage || "",
        planName: m.planName || "Active Plan",
        joinedDate: m.joinedAt || m.createdAt,
        fitnessGoal: user.fitnessGoal || "General Fitness",
        currentWeightKg: user.currentWeightKg || 0,
      };
    });

    return res.status(200).json({
      success: true,
      count: membersData.length,
      data: membersData,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/gyms/inactive-members?days=3
export const getInactiveMembers = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const minDays = parseInt(req.query.days, 10) || 3;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "No active gym found." });
    }

    const memberships = await Membership.find({
      gymId: gym._id,
      status: "active",
    }).populate({
      path: "memberId",
      select: "name email phone profileImage",
    });

    const now = new Date();
    const inactiveMembers = [];

    for (const m of memberships) {
      if (!m.memberId) continue;
      const user = m.memberId;

      const latestAttendance = await Attendance.findOne({
        memberId: user._id,
      }).sort({ checkInTime: -1, createdAt: -1 });

      let lastActiveDate;
      if (
        latestAttendance &&
        (latestAttendance.checkInTime || latestAttendance.createdAt)
      ) {
        lastActiveDate = new Date(
          latestAttendance.checkInTime || latestAttendance.createdAt,
        );
      } else {
        lastActiveDate = new Date(
          m.joinedAt || m.createdAt || user.createdAt || Date.now(),
        );
      }

      const diffMs = now - lastActiveDate;
      const daysAbsent = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (daysAbsent >= minDays) {
        inactiveMembers.push({
          user: {
            id: user._id.toString(),
            name: user.name || "Gym Member",
            email: user.email || "",
            phone: user.phone || "",
            profileImage: user.profileImage || "",
            role: "gym_member",
          },
          daysAbsent,
          lastActiveDate: lastActiveDate.toISOString(),
        });
      }
    }

    inactiveMembers.sort((a, b) => b.daysAbsent - a.daysAbsent);

    return res.status(200).json({
      success: true,
      count: inactiveMembers.length,
      data: inactiveMembers,
    });
  } catch (error) {
    next(error);
  }
};
