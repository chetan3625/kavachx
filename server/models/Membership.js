import mongoose from "mongoose";

const membershipSchema = new mongoose.Schema(
  {
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },

    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: true
    },

    status: {
      type: String,
      enum: ["active", "inactive", "expired"],
      default: "active"
    },

    joinedAt: {
      type: Date,
      default: Date.now
    }
  },
  {
    timestamps: true
  }
);

membershipSchema.index({ memberId: 1, gymId: 1 }, { unique: true });

const Membership = mongoose.model("Membership", membershipSchema);

export default Membership;
