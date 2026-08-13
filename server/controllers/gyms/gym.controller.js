import Gym from "../../models/Gym.js";
import GymJoinRequest from "../../models/GymJoinRequest.js";
import Membership from "../../models/MembershipPlan.js";
import User from "../../models/User.js";
import Attendance from "../../models/Attendance.js";
import ApiError from "../../utils/ApiError.js";
import { getIO } from "../../config/socket.js";

// POST /api/v1/gyms/join-request
export const joinRequest = async (req, res, next) => {
  try {
    const memberId = req.user.userId;
    const { gymToken } = req.body;

    if (!gymToken) {
      return res
        .status(400)
        .json({ success: false, message: "Gym token is required" });
    }

    const gym = await Gym.findOne({ gymToken, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "Invalid or inactive gym token" });
    }

    const existingMembership = await Membership.findOne({
      memberId,
      gymId: gym._id,
    });
    if (existingMembership) {
      return res.status(400).json({
        success: false,
        message: "You are already a member of this gym",
      });
    }

    const existingRequest = await GymJoinRequest.findOne({
      memberId,
      gymId: gym._id,
      status: "pending",
    });
    if (existingRequest) {
      return res.status(400).json({
        success: false,
        message: "You already have a pending join request for this gym",
      });
    }

    const request = await GymJoinRequest.create({ memberId, gymId: gym._id });
    const populatedReq = await GymJoinRequest.findById(request._id)
      .populate("memberId", "name email phone profileImage")
      .populate("gymId", "name");

    try {
      const io = getIO();
      const ownerIdStr = gym.ownerId.toString();
      io.to(`owner_${ownerIdStr}`).emit("new_join_request", populatedReq);
    } catch (err) {
      console.error("Socket emit error (joinRequest):", err.message);
    }

    return res.status(201).json({
      success: true,
      message: "Join request submitted successfully",
      data: populatedReq,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/gyms/join-requests
export const listPendingRequests = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gyms = await Gym.find({ ownerId }).select("_id");
    const gymIds = gyms.map((g) => g._id);

    const requests = await GymJoinRequest.find({
      gymId: { $in: gymIds },
      status: "pending",
    })
      .populate("memberId", "name email phone profileImage")
      .populate("gymId", "name");

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

    const reqDoc = await GymJoinRequest.findById(requestId);
    if (!reqDoc) {
      return res
        .status(404)
        .json({ success: false, message: "Join request not found" });
    }

    const gym = await Gym.findById(reqDoc.gymId);
    if (!gym || gym.ownerId.toString() !== ownerId.toString()) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    reqDoc.status = "approved";
    reqDoc.reviewedAt = new Date();
    reqDoc.reviewedBy = ownerId;
    await reqDoc.save();

    await Membership.findOneAndUpdate(
      { memberId: reqDoc.memberId, gymId: reqDoc.gymId },
      { memberId: reqDoc.memberId, gymId: reqDoc.gymId, status: "active" },
      { upsert: true, new: true },
    );

    await User.findByIdAndUpdate(reqDoc.memberId, { gymId: reqDoc.gymId });

    try {
      const io = getIO();
      const memberIdStr = reqDoc.memberId.toString();
      io.to(`member_${memberIdStr}`).emit("join_request_updated", reqDoc);
    } catch (err) {
      console.error("Socket emit error (approveRequest):", err.message);
    }

    return res
      .status(200)
      .json({ success: true, message: "Join request approved", data: reqDoc });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/gyms/join-requests/:requestId/reject
export const rejectRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const ownerId = req.user.userId;

    const reqDoc = await GymJoinRequest.findById(requestId);
    if (!reqDoc) {
      return res
        .status(404)
        .json({ success: false, message: "Join request not found" });
    }

    const gym = await Gym.findById(reqDoc.gymId);
    if (!gym || gym.ownerId.toString() !== ownerId.toString()) {
      return res
        .status(403)
        .json({ success: false, message: "Not authorized" });
    }

    reqDoc.status = "rejected";
    reqDoc.reviewedAt = new Date();
    reqDoc.reviewedBy = ownerId;
    await reqDoc.save();

    try {
      const io = getIO();
      const memberIdStr = reqDoc.memberId.toString();
      io.to(`member_${memberIdStr}`).emit("join_request_updated", reqDoc);
    } catch (err) {
      console.error("Socket emit error (rejectRequest):", err.message);
    }

    return res
      .status(200)
      .json({ success: true, message: "Join request rejected", data: reqDoc });
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
        .json({ success: false, message: "No active gym found" });
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
        .json({ success: false, message: "No active gym found" });
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
