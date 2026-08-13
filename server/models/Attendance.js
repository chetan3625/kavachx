import mongoose from "mongoose";

const attendanceSchema = new mongoose.Schema(
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
    dateStr: { type: String, index: true },
    dateString: {
      type: String, // Format: YYYY-MM-DD
      required: true
    },
    checkInTime: {
      type: Date,
      required: true
    },
    checkOutTime: {
      type: Date,
      default: null
    },
    status: { type: String, enum: ["checked_in", "checked_out"], default: "checked_in" },
    streakDays: {
      type: Number,
      default: 1
    }
  },
  {
    timestamps: true
  }
);

// Prevent duplicate attendance for the same member on the same day
attendanceSchema.index({ memberId: 1, dateString: 1 }, { unique: true });
// Useful for querying all attendance for a specific gym on a specific day
attendanceSchema.index({ gymId: 1, dateString: 1 });

const Attendance = mongoose.model("Attendance", attendanceSchema);

export default Attendance;
