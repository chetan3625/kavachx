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
      enum: ["active", "trial", "inactive", "expired"],
      default: "trial",
    },
    planName: {
      type: String,
      default: "7-Day Free Trial",
    },
    price: {
      type: Number,
      default: 0,
    },
    durationInMonths: {
      type: Number,
      default: 0,
    },
    trialDays: {
      type: Number,
      default: 7,
    },
    startDate: {
      type: Date,
      default: Date.now,
    },
    endDate: {
      type: Date,
      default: function () {
        const d = new Date();
        d.setDate(d.getDate() + 7); // Default 7 Days Free Trial
        return d;
      },
    },
    features: {
      type: [String],
      default: [
        "Full Gym Equipment Access",
        "Free Trainer Guidance",
        "Locker & Shower Facilities",
      ],
    },
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
