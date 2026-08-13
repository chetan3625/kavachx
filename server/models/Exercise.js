import mongoose from "mongoose";

const exerciseSchema = new mongoose.Schema(
  {
    gymId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Gym",
      required: false
    },
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: false
    },
    dateString: {
      type: String, // YYYY-MM-DD
      required: false
    },
    dateStr: { type: String, index: true },
    name: {
      type: String,
      required: true,
      trim: true
    },
    muscleGroup: { type: String, default: "" },
    weightInKg: { type: Number, default: 0 },
    repsPerSet: { type: Number, default: 0 },
    durationMinutes: { type: Number, default: 0 },
    notes: { type: String, default: "" },
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
