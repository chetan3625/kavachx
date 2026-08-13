import mongoose from "mongoose";

const workoutLogSchema = new mongoose.Schema(
  {
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true
    },
    targetPart: {
      type: String,
      required: true,
      default: "Chest & Triceps"
    },
    totalDurationMinutes: {
      type: Number,
      default: 45
    },
    caloriesBurned: {
      type: Number,
      default: 300
    },
    dateStr: {
      type: String, // YYYY-MM-DD
      required: true,
      index: true
    },
    notes: {
      type: String,
      default: ""
    }
  },
  {
    timestamps: true
  }
);

const WorkoutLog = mongoose.model("WorkoutLog", workoutLogSchema);

export default WorkoutLog;
