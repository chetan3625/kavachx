import mongoose from "mongoose";

const notificationSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    gymId: { type: mongoose.Schema.Types.ObjectId, ref: "Gym", required: true },
    title: { type: String, required: true },
    message: { type: String, required: true },
    type: { type: String, default: "announcement" },
    isRead: { type: Boolean, default: false },
  },
  { timestamps: true },
);

export default mongoose.model("Notification", notificationSchema);
