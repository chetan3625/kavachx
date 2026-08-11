import User from "../models/User.js";
import Gym from "../models/Gym.js";
import crypto from "crypto";
import ApiError from "../utils/ApiError.js";
import { generateAccessToken, generateRefreshToken } from "../utils/generateToken.js";

export const registerUser = async ({
  name,
  email,
  phone,
  password
}) => {
  const normalizedEmail = email.toLowerCase().trim();

  const existingUser = await User.findOne({
    $or: [
      { email: normalizedEmail },
      { phone }
    ]
  });

  if (existingUser) {
    if (existingUser.email === normalizedEmail) {
      throw new ApiError(
        409,
        "Email already registered"
      );
    }

    if (existingUser.phone === phone) {
      throw new ApiError(
        409,
        "Phone number already registered"
      );
    }
  }

  const user = await User.create({
    name,
    email: normalizedEmail,
    phone,
    password,
    role: "gym_owner"
  });

  const accessToken = generateAccessToken(user);

  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;

  await user.save({
    validateBeforeSave: false
  });

  return {
    user,
    accessToken,
    refreshToken
  };
};

export const loginUser = async ({
  email,
  password
}) => {
  const normalizedEmail = email.toLowerCase().trim();

  const user = await User.findOne({
    email: normalizedEmail
  }).select("+password +refreshToken");

  if (!user) {
    throw new ApiError(
      401,
      "Invalid email or password"
    );
  }

  if (!user.isActive) {
    throw new ApiError(
      403,
      "Your account has been disabled"
    );
  }

  const isPasswordCorrect =
    await user.comparePassword(password);

  if (!isPasswordCorrect) {
    throw new ApiError(
      401,
      "Invalid email or password"
    );
  }

  const accessToken = generateAccessToken(user);

  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  user.lastLoginAt = new Date();

  await user.save({
    validateBeforeSave: false
  });

  return {
    user,
    accessToken,
    refreshToken
  };
};

export const refreshUserToken = async (
  refreshToken
) => {
  if (!refreshToken) {
    throw new ApiError(
      401,
      "Refresh token missing"
    );
  }

  const user = await User.findOne({
    refreshToken
  }).select("+refreshToken");

  if (!user) {
    throw new ApiError(
      401,
      "Invalid refresh token"
    );
  }

  const accessToken = generateAccessToken(user);

  return {
    accessToken
  };
};

export const logoutUser = async (userId) => {
  await User.findByIdAndUpdate(
    userId,
    {
      $unset: {
        refreshToken: 1
      }
    }
  );
};

export const getCurrentUser = async (userId) => {
  const user = await User.findById(userId);

  if (!user) {
    throw new ApiError(
      404,
      "User not found"
    );
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
  gymAddress
}) => {
  const normalizedEmail = email.toLowerCase().trim();

  const existingUser = await User.findOne({
    $or: [{ email: normalizedEmail }, { phone }]
  });

  if (existingUser) {
    if (existingUser.email === normalizedEmail) {
      throw new ApiError(409, "Email already registered");
    }

    if (existingUser.phone === phone) {
      throw new ApiError(409, "Phone number already registered");
    }
  }

  // Create owner user first
  const user = await User.create({
    name,
    email: normalizedEmail,
    phone,
    password,
    role: "gym_owner"
  });

  // Generate unique gym token
  let token;
  let exists = true;

  do {
    token = `KAVACHX_GYM_${crypto.randomBytes(16).toString("hex")}`;
    const t = await Gym.findOne({ gymToken: token });
    exists = !!t;
  } while (exists);

  // Create gym associated with owner
  const gym = await Gym.create({
    name: gymName,
    ownerId: user._id,
    phone: gymPhone,
    address: gymAddress,
    gymToken: token
  });

  // Link gym to user
  user.gymId = gym._id;

  const accessToken = generateAccessToken(user);

  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;

  await user.save({ validateBeforeSave: false });

  return {
    user,
    gym,
    accessToken,
    refreshToken,
    gymToken: token
  };
};

export const registerMember = async ({ name, email, phone, password }) => {
  const normalizedEmail = email.toLowerCase().trim();

  const existingUser = await User.findOne({
    $or: [{ email: normalizedEmail }, { phone }]
  });

  if (existingUser) {
    if (existingUser.email === normalizedEmail) {
      throw new ApiError(409, "Email already registered");
    }

    if (existingUser.phone === phone) {
      throw new ApiError(409, "Phone number already registered");
    }
  }

  const user = await User.create({
    name,
    email: normalizedEmail,
    phone,
    password,
    role: "gym_member",
    gymId: null
  });

  const accessToken = generateAccessToken(user);

  const refreshToken = generateRefreshToken(user);

  user.refreshToken = refreshToken;
  user.lastLoginAt = new Date();

  await user.save({ validateBeforeSave: false });

  return {
    user,
    accessToken,
    refreshToken
  };
};