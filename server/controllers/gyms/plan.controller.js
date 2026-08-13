import Gym from "../../models/Gym.js";
import MembershipPlan from "../../models/MembershipPlan.js";

// GET /api/v1/gyms/plans
export const getPlans = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "No active gym found" });
    }

    const plans = await MembershipPlan.find({ gymId: gym._id }).sort({
      createdAt: -1,
    });

    return res.status(200).json({
      success: true,
      count: plans.length,
      data: plans,
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/gyms/plans
export const createPlan = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const { name, price, durationInMonths, features } = req.body;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym) {
      return res
        .status(404)
        .json({ success: false, message: "No active gym found" });
    }

    const plan = await MembershipPlan.create({
      gymId: gym._id,
      name,
      price: parseFloat(price),
      durationInMonths: parseInt(durationInMonths, 10),
      features: Array.isArray(features) ? features : [],
    });

    return res.status(201).json({
      success: true,
      message: "Membership plan created successfully",
      data: plan,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/gyms/plans/:id
export const updatePlan = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, price, durationInMonths, features } = req.body;

    const plan = await MembershipPlan.findByIdAndUpdate(
      id,
      {
        name,
        price: parseFloat(price),
        durationInMonths: parseInt(durationInMonths, 10),
        features: Array.isArray(features) ? features : [],
      },
      { new: true },
    );

    if (!plan) {
      return res
        .status(404)
        .json({ success: false, message: "Plan not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Plan updated successfully",
      data: plan,
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/gyms/plans/:id
export const deletePlan = async (req, res, next) => {
  try {
    const { id } = req.params;
    const plan = await MembershipPlan.findByIdAndDelete(id);
    if (!plan) {
      return res
        .status(404)
        .json({ success: false, message: "Plan not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Plan deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};
