import mongoose from "mongoose";

const exerciseSchema = new mongoose.Schema(
  {
    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: true
    },
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true
    },
    dateString: {
      type: String, // YYYY-MM-DD
      required: true
    },
    name: {
      type: String,
      required: true,
      trim: true
    },
    totalSets: {
      type: Number,
      required: true,
      min: 1
    },
    completedSets: {
      type: Number,
      default: 0,
      min: 0
    },
    isCompleted: {
      type: Boolean,
      default: false
    }
  },
  {
    timestamps: true
  }
);

exerciseSchema.index({ memberId: 1, dateString: 1 });

const Exercise = mongoose.model("Exercise", exerciseSchema);

export default Exercise;
