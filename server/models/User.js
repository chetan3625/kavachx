import mongoose from "mongoose";
import bcrypt from "bcryptjs";
import crypto from "crypto";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      unique: true,
      lowercase: true,
      trim: true,
    },
    password: { type: String, required: true, select: false },
    phone: { type: String, unique: true, sparse: true, trim: true },
    refreshToken: { type: String, select: false },
    isActive: { type: Boolean, default: true },
    role: {
      type: String,
      enum: ["gym_owner", "gym_member"],
      default: "gym_member",
    },
    gymId: { type: mongoose.Schema.Types.ObjectId, ref: "Gym", default: null },
    fcmToken: { type: String, default: null },
    isApproved: { type: Boolean, default: false },
    lastActiveAt: { type: Date, default: Date.now },
    lastLoginAt: { type: Date, default: null },
    resetPasswordToken: { type: String, select: false },
    resetPasswordExpire: { type: Date, select: false },
    isOnboarded: { type: Boolean, default: false },
    age: Number,
    height: Number,
    heightCm: Number,
    currentWeightKg: Number,
    targetWeightKg: Number,
    waterLitres: { type: Number, default: 0 },
    targetWaterLitres: { type: Number, default: 0 },
    gender: { type: String, enum: ["male", "female", "other", ""], default: "" },
    fitnessGoal: String,
    waterIntakeReminder: Boolean,
    waterReminderIntervalHours: Number,
    dateOfBirth: Date,
    emergencyContact: String,
    bloodGroup: String,
    address: String,
    medicalConditions: String,
    todayTargetPart: String,
    streakDays: { type: Number, default: 0 },
    profileImage: String,
  },
  { timestamps: true },
);

userSchema.pre("save", async function () {
  if (!this.isModified("password")) return;
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

userSchema.methods.comparePassword = userSchema.methods.matchPassword;

userSchema.methods.createPasswordResetToken = function () {
  const resetToken = crypto.randomBytes(32).toString("hex");
  this.resetPasswordToken = crypto
    .createHash("sha256")
    .update(resetToken)
    .digest("hex");
  this.resetPasswordExpire = Date.now() + 10 * 60 * 1000;
  return resetToken;
};

export default mongoose.model("User", userSchema);
