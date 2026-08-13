import mongoose from "mongoose";

const planSchema = new mongoose.Schema(
  {
    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: true
    },

    name: {
      type: String,
      required: true,
      trim: true
    },

    price: {
      type: Number,
      required: true,
      min: 0
    },

    durationInMonths: {
      type: Number,
      required: true,
      min: 1
    },

    features: {
      type: [String],
      default: []
    },

    isActive: {
      type: Boolean,
      default: true
    }
  },
  {
    timestamps: true
  }
);

const Plan = mongoose.model("Plan", planSchema);

export default Plan;
