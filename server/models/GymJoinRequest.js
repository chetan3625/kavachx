import mongoose from "mongoose";

const gymJoinRequestSchema = new mongoose.Schema(
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
      enum: ["pending", "approved", "rejected"],
      default: "pending"
    },

    requestedAt: {
      type: Date,
      default: Date.now
    },

    reviewedAt: {
      type: Date,
      default: null
    },

    reviewedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null
    }
  },
  {
    timestamps: true
  }
);

const GymJoinRequest = mongoose.model("GymJoinRequest", gymJoinRequestSchema);

export default GymJoinRequest;
