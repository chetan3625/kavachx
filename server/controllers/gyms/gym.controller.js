import JoinRequest from "../../models/GymJoinRequest.js";
import User from "../../models/User.js";
import Gym from "../../models/Gym.js";

// PATCH /api/v1/gyms/join-requests/:requestId/approve
export const approveRequest = async (req, res, next) => {
  try {
    const { requestId } = req.params;
    const ownerId = req.user.userId;

    // 1. Find the owner's gym
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found." });
    }

    // 2. Find the pending request
    const request = await JoinRequest.findById(requestId);
    if (!request || request.status !== "pending") {
      return res
        .status(400)
        .json({
          success: false,
          message: "Invalid or already processed request.",
        });
    }

    // 3. Update the request status
    request.status = "approved";
    await request.save();

    // 4. Link the member user account to this gym (FIXED HERE)
    await User.findByIdAndUpdate(
      request.userId, // Use request.userId to find the member user document
      {
        gymId: gym._id,
        role: "gym_member",
        isApproved: true,
      },
      { new: true, runValidators: true }, // Remove upsert: true
    );

    return res.status(200).json({
      success: true,
      message: "Join request approved successfully.",
    });
  } catch (error) {
    next(error);
  }
};
