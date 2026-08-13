import Gym from "../../models/Gym.js";
import User from "../../models/User.js";
import JoinRequest from "../../models/JoinRequest.js";

export const joinRequest = async (req, res, next) => {
  try {
    const { gymId } = req.body;
    const userId = req.user.userId;

    const existing = await JoinRequest.findOne({
      userId,
      gymId,
      status: "pending",
    });
    if (existing) {
      return res
        .status(400)
        .json({ success: false, message: "Join request already pending." });
    }

    const request = await JoinRequest.create({ userId, gymId });
    return res.status(201).json({ success: true, data: request });
  } catch (error) {
    next(error);
  }
};

export const listPendingRequests = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const requests = await JoinRequest.find({
      gymId: gym._id,
      status: "pending",
    }).populate("userId", "name email");
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
    const ownerId = req.user.userId;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });

    const request = await JoinRequest.findById(requestId);
    if (!request || request.status !== "pending") {
      return res
        .status(400)
        .json({ success: false, message: "Invalid or processed request." });
    }

    request.status = "approved";
    await request.save();

    // Link user document without strict mode violations
    await User.findByIdAndUpdate(
      request.userId,
      { gymId: gym._id, role: "gym_member", isApproved: true },
      { new: true, runValidators: true },
    );

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
    const request = await JoinRequest.findByIdAndUpdate(
      requestId,
      { status: "rejected" },
      { new: true },
    );
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
