import mongoose from "mongoose";

const membershipPlanSchema = new mongoose.Schema(
  {
    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: true,
      index: true,
    },
    name: { type: String, required: true, trim: true },
    price: { type: Number, required: true, min: 0 },
    durationInMonths: { type: Number, required: true, min: 1 },
    features: [{ type: String, trim: true }],
  },
  { timestamps: true },
);

export default mongoose.model("MembershipPlan", membershipPlanSchema);
