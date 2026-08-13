import mongoose from "mongoose";

const membershipSchema = new mongoose.Schema(
  {
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: true,
      index: true,
    },
    status: {
      type: String,
      enum: ["active", "inactive", "expired"],
      default: "active",
    },
    planName: {
      type: String,
      default: "Active Membership",
    },
    price: {
      type: Number,
      default: 0,
    },
    durationInMonths: {
      type: Number,
      default: 1,
    },
    startDate: {
      type: Date,
      default: Date.now,
    },
    endDate: {
      type: Date,
      default: null,
    },
    features: [{ type: String }],
    joinedAt: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: true,
  },
);

membershipSchema.index({ memberId: 1, gymId: 1 }, { unique: true });

const Membership = mongoose.model("Membership", membershipSchema);

export default Membership;
