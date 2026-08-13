import User from "../models/User.js";
import Gym from "../models/Gym.js";
import crypto from "crypto";
import ApiError from "../utils/ApiError.js";
import {
  generateAccessToken,
  generateRefreshToken,
} from "../utils/generateToken.js";
import qrcode from "qrcode";
import { uploadBufferToCloudinary } from "../utils/cloudinary.js";
import sendEmail from "../utils/sendEmail.js";
import { env } from "../config/env.js";

export const registerUser = async ({ name, email, phone, password }) => {
  const normalizedEmail = email.toLowerCase().trim();
  const normalizedPhone = phone ? phone.toString().trim() : null;

  const existingEmail = await User.findOne({ email: normalizedEmail });
  if (existingEmail) {
    throw new ApiError(409, "Email already registered");
  }

  if (normalizedPhone) {
    const existingPhone = await User.findOne({ phone: normalizedPhone });
    if (existingPhone) {
      throw new ApiError(409, "Phone number already registered");
    }
  }

  const user = await User.create({
    name,
    email: normalizedEmail,
    phone: normalizedPhone,
    password,
    role: "gym_owner",
  });

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  await user.save({ validateBeforeSave: false });

  return { user, accessToken, refreshToken };
};

export const loginUser = async ({ email, password }) => {
  const normalizedEmail = email.toLowerCase().trim();

  const user = await User.findOne({
    email: normalizedEmail,
  }).select("+password +refreshToken");

  if (!user) {
    throw new ApiError(401, "Invalid email or password");
  }

  if (!user.isActive) {
    throw new ApiError(403, "Your account has been disabled");
  }

  const isPasswordCorrect = await user.comparePassword(password);
  if (!isPasswordCorrect) {
    throw new ApiError(401, "Invalid email or password");
  }

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  user.lastLoginAt = new Date();

  await user.save({ validateBeforeSave: false });

  return { user, accessToken, refreshToken };
};

export const refreshUserToken = async (refreshToken) => {
  if (!refreshToken) {
    throw new ApiError(401, "Refresh token missing");
  }

  const user = await User.findOne({ refreshToken }).select("+refreshToken");

  if (!user) {
    throw new ApiError(401, "Invalid refresh token");
  }

  const accessToken = generateAccessToken(user);

  return { accessToken };
};

export const logoutUser = async (userId) => {
  await User.findByIdAndUpdate(userId, {
    $unset: { refreshToken: 1 },
  });
};

export const getCurrentUser = async (userId) => {
  const user = await User.findById(userId);

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  return user;
};

export const registerOwner = async ({
  name,
  email,
  phone,
  password,
  gymName,
  gymPhone,
  gymAddress,
}) => {
  const normalizedEmail = email.toLowerCase().trim();
  const normalizedPhone = phone ? phone.toString().trim() : null;

  // 1. Precise Email Check
  const existingEmail = await User.findOne({ email: normalizedEmail });
  if (existingEmail) {
    throw new ApiError(409, "Email already registered");
  }

  // 2. Precise Phone Check (Only if phone is provided)
  if (normalizedPhone) {
    const existingPhone = await User.findOne({ phone: normalizedPhone });
    if (existingPhone) {
      throw new ApiError(409, "Phone number already registered");
    }
  }

  // 3. Create Gym Owner
  const user = await User.create({
    name,
    email: normalizedEmail,
    phone: normalizedPhone,
    password,
    role: "gym_owner",
  });

  // 4. Generate Unique Gym Token
  let token;
  let exists = true;

  do {
    token = `KAVACHX_GYM_${crypto.randomBytes(16).toString("hex")}`;
    const t = await Gym.findOne({ gymToken: token });
    exists = !!t;
  } while (exists);

  // 5. Create Associated Gym
  const gym = await Gym.create({
    name: gymName,
    ownerId: user._id,
    phone: gymPhone || normalizedPhone,
    address: gymAddress || "Main Branch",
    gymToken: token,
  });

  // 6. Link Gym to Owner User
  user.gymId = gym._id;

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  await user.save({ validateBeforeSave: false });

  const joinUrl = `https://kavachx.com/join/${token}`;
  let qrUrl = null;

  try {
    const qrBuffer = await qrcode.toBuffer(joinUrl);
    const uploadResult = await uploadBufferToCloudinary(
      qrBuffer,
      "kavachx_gym_qrs",
    );
    qrUrl = uploadResult.secure_url;

    gym.qrUrl = qrUrl;
    await gym.save({ validateBeforeSave: false });
  } catch (error) {
    console.error("Failed to generate or upload QR code:", error);
  }

  return {
    user,
    gym,
    accessToken,
    refreshToken,
    gymToken: token,
    joinUrl,
    qrUrl,
  };
};

export const registerMember = async ({ name, email, phone, password }) => {
  const normalizedEmail = email.toLowerCase().trim();
  const normalizedPhone = phone ? phone.toString().trim() : null;

  const existingEmail = await User.findOne({ email: normalizedEmail });
  if (existingEmail) {
    throw new ApiError(409, "Email already registered");
  }

  if (normalizedPhone) {
    const existingPhone = await User.findOne({ phone: normalizedPhone });
    if (existingPhone) {
      throw new ApiError(409, "Phone number already registered");
    }
  }

  const user = await User.create({
    name,
    email: normalizedEmail,
    phone: normalizedPhone,
    password,
    role: "gym_member",
    gymId: null,
  });

  const accessToken = generateAccessToken(user);
  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  user.lastLoginAt = new Date();

  await user.save({ validateBeforeSave: false });

  return {
    user,
    accessToken,
    refreshToken,
  };
};

export const forgotPasswordService = async (email) => {
  const user = await User.findOne({ email: email.toLowerCase().trim() });

  if (!user) {
    throw new ApiError(404, "There is no user with that email address.");
  }

  const resetToken = user.createPasswordResetToken();
  await user.save({ validateBeforeSave: false });

  const resetUrl = `${env.CLIENT_URL}/reset-password/${resetToken}`;
  const message = `You are receiving this email because you requested a password reset. Please use: \n\n ${resetUrl}`;

  try {
    await sendEmail({
      email: user.email,
      subject: "Password reset token",
      message,
    });
  } catch (error) {
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save({ validateBeforeSave: false });

    throw new ApiError(
      500,
      "There was an error sending the email. Try again later!",
    );
  }
};

export const resetPasswordService = async (token, newPassword) => {
  const resetPasswordToken = crypto
    .createHash("sha256")
    .update(token)
    .digest("hex");

  const user = await User.findOne({
    resetPasswordToken,
    resetPasswordExpire: { $gt: Date.now() },
  }).select("+password");

  if (!user) {
    throw new ApiError(400, "Token is invalid or has expired");
  }

  user.password = newPassword;
  user.resetPasswordToken = undefined;
  user.resetPasswordExpire = undefined;

  await user.save();
};

export const changePasswordService = async (
  userId,
  oldPassword,
  newPassword,
) => {
  const user = await User.findById(userId).select("+password");

  if (!user) {
    throw new ApiError(404, "User not found");
  }

  const isPasswordCorrect = await user.comparePassword(oldPassword);
  if (!isPasswordCorrect) {
    throw new ApiError(401, "Invalid old password");
  }

  user.password = newPassword;
  await user.save();
};
