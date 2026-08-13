import Plan from "../models/Plan.js";
import Gym from "../models/Gym.js";
import User from "../models/User.js";
import ApiError from "../utils/ApiError.js";

export const createPlan = async ({
  ownerId,
  name,
  price,
  durationInMonths,
  features = []
}) => {
  // Find owner's gym
  let gym = await Gym.findOne({ ownerId, isActive: true });

  if (!gym) {
    throw new ApiError(404, "No active gym associated with this owner account");
  }

  const plan = await Plan.create({
    gymId: gym._id,
    name,
    price,
    durationInMonths,
    features,
    isActive: true
  });

  return plan;
};

export const getPlans = async ({ userId, role }) => {
  if (role === "gym_owner") {
    const gyms = await Gym.find({ ownerId: userId }).select("_id");
    const gymIds = gyms.map((g) => g._id);

    const plans = await Plan.find({ gymId: { $in: gymIds } }).sort({ createdAt: -1 });
    return plans;
  }

  // Member flow: fetch plans for member's assigned gym
  const user = await User.findById(userId).select("gymId");
  if (user && user.gymId) {
    const plans = await Plan.find({ gymId: user.gymId, isActive: true }).sort({ createdAt: -1 });
    return plans;
  }

  // Fallback: fetch all active plans if member is not linked to a single gym yet
  const plans = await Plan.find({ isActive: true }).sort({ createdAt: -1 });
  return plans;
};

export const getPlanById = async (planId) => {
  const plan = await Plan.findById(planId);
  if (!plan) {
    throw new ApiError(404, "Membership plan not found");
  }
  return plan;
};

export const updatePlan = async (planId, ownerId, updateData) => {
  const plan = await Plan.findById(planId);
  if (!plan) {
    throw new ApiError(404, "Membership plan not found");
  }

  const gym = await Gym.findById(plan.gymId);
  if (!gym || gym.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, "Not authorized to modify this membership plan");
  }

  const { name, price, durationInMonths, features, isActive } = updateData;

  if (name !== undefined) plan.name = name;
  if (price !== undefined) plan.price = price;
  if (durationInMonths !== undefined) plan.durationInMonths = durationInMonths;
  if (features !== undefined) plan.features = features;
  if (isActive !== undefined) plan.isActive = isActive;

  await plan.save();
  return plan;
};

export const deletePlan = async (planId, ownerId) => {
  const plan = await Plan.findById(planId);
  if (!plan) {
    throw new ApiError(404, "Membership plan not found");
  }

  const gym = await Gym.findById(plan.gymId);
  if (!gym || gym.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, "Not authorized to delete this membership plan");
  }

  await Plan.findByIdAndDelete(planId);
  return { message: "Membership plan deleted successfully" };
};
