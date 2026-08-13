import Gym from "../../models/Gym.js";
import MembershipPlan from "../../models/MembershipPlan.js";

export const getPlans = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found" });

    const plans = await MembershipPlan.find({ gymId: gym._id }).sort({
      createdAt: -1,
    });
    return res
      .status(200)
      .json({ success: true, count: plans.length, data: plans });
  } catch (error) {
    next(error);
  }
};

export const createPlan = async (req, res, next) => {
  try {
    const ownerId = req.user.userId;
    const { name, price, durationInMonths, features } = req.body;

    const gym = await Gym.findOne({ ownerId, isActive: true });
    if (!gym)
      return res
        .status(404)
        .json({ success: false, message: "Active gym not found" });

    const plan = await MembershipPlan.create({
      gymId: gym._id,
      name,
      price: parseFloat(price),
      durationInMonths: parseInt(durationInMonths, 10),
      features: Array.isArray(features) ? features : [],
    });

    return res.status(201).json({ success: true, data: plan });
  } catch (error) {
    next(error);
  }
};

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

    if (!plan)
      return res
        .status(404)
        .json({ success: false, message: "Plan not found" });
    return res.status(200).json({ success: true, data: plan });
  } catch (error) {
    next(error);
  }
};

export const deletePlan = async (req, res, next) => {
  try {
    const { id } = req.params;
    const plan = await MembershipPlan.findByIdAndDelete(id);
    if (!plan)
      return res
        .status(404)
        .json({ success: false, message: "Plan not found" });

    return res
      .status(200)
      .json({ success: true, message: "Plan deleted successfully" });
  } catch (error) {
    next(error);
  }
};
