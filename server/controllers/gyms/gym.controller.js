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

    const now = new Date();
    const cutoffDate = new Date(now);
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
        const daysAbsent = Math.max(
          1,
          Math.floor((now.getTime() - new Date(latestActivity).getTime()) / (1000 * 60 * 60 * 24))
        );
        const userObj = user.toObject();
        userObj.id = user._id.toString();

        inactiveMembersList.push({
          id: user._id.toString(),
          user: userObj,
          daysAbsent,
          lastActiveDate: latestActivity,
          ...userObj,
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

export const getGymProfile = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const user = await User.findById(ownerId).select("-password");
    const gym = await Gym.findOne({ ownerId, isActive: true });

    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "Gym profile not found." });
    }

    return res.status(200).json({
      success: true,
      data: {
        owner: user,
        gym: gym,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const updateGymProfile = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const { ownerName, phone, gymName, gymPhone, gymAddress } = req.body;

    // Check if phone number is taken by another user
    if (phone) {
      const existingUser = await User.findOne({ phone, _id: { $ne: ownerId } });
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: "Phone number is already registered with another account.",
        });
      }
    }

    // Update User profile details
    const userUpdates = {};
    if (ownerName) userUpdates.name = ownerName;
    if (phone) userUpdates.phone = phone;

    let updatedUser = null;
    if (Object.keys(userUpdates).length > 0) {
      updatedUser = await User.findByIdAndUpdate(ownerId, userUpdates, {
        returnDocument: "after",
        runValidators: true,
      }).select("-password");
    } else {
      updatedUser = await User.findById(ownerId).select("-password");
    }

    // Update Gym details
    const gymUpdates = {};
    if (gymName) gymUpdates.name = gymName;
    if (gymPhone) gymUpdates.phone = gymPhone;
    if (gymAddress) gymUpdates.address = gymAddress;

    let updatedGym = await Gym.findOneAndUpdate(
      { ownerId, isActive: true },
      gymUpdates,
      { returnDocument: "after", runValidators: true },
    );

    return res.status(200).json({
      success: true,
      message: "Gym profile updated successfully! 🎉",
      data: {
        owner: updatedUser,
        gym: updatedGym,
      },
    });
  } catch (error) {
    if (error.code === 11000) {
      return res.status(400).json({
        success: false,
        message: "Duplicate field value. Phone number or email already in use.",
      });
    }
    next(error);
  }
};

export const getMemberAttendanceHistoryForOwner = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const { memberId } = req.params;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const member = await User.findById(memberId).select("-password");
    if (!member) {
      return res
        .status(404)
        .json({ success: false, message: "Member not found." });
    }

    const { default: Attendance } = await import("../../models/Attendance.js");
    const { default: Exercise } = await import("../../models/Exercise.js");

    const attendances = await Attendance.find({ memberId }).sort({
      checkInTime: -1,
      createdAt: -1,
    });

    const exercises = await Exercise.find({ memberId }).sort({ createdAt: -1 });

    const exercisesByDate = {};
    exercises.forEach((ex) => {
      const dateKey = ex.dateStr || ex.dateString;
      if (dateKey) {
        if (!exercisesByDate[dateKey]) {
          exercisesByDate[dateKey] = [];
        }
        exercisesByDate[dateKey].push(ex);
      }
    });

    const history = attendances.map((att) => {
      const dateKey = att.dateStr || att.dateString;
      const dayExercises = exercisesByDate[dateKey] || [];
      const primaryTargetPart =
        dayExercises.length > 0 && dayExercises[0].muscleGroup
          ? dayExercises[0].muscleGroup
          : null;

      return {
        _id: att._id,
        dateStr: dateKey,
        checkInTime: att.checkInTime,
        checkOutTime: att.checkOutTime,
        status: att.status,
        streakDays: att.streakDays,
        targetPart: primaryTargetPart,
        exercises: dayExercises,
      };
    });

    return res.status(200).json({
      success: true,
      data: {
        member,
        totalCheckIns: attendances.length,
        history,
      },
    });
  } catch (error) {
    next(error);
  }
};
