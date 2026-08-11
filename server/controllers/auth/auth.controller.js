import asyncHandler from "../../utils/AsyncHandler.js";

import {
  registerUser,
  registerOwner,
  registerMember,
  loginUser,
  refreshUserToken,
  logoutUser,
  getCurrentUser
} from "../../services/auth.service.js";

export const register = asyncHandler(async (req, res) => {
  const {
    name,
    email,
    phone,
    password
  } = req.body;

  const {
    user,
    accessToken,
    refreshToken
  } = await registerUser({
    name,
    email,
    phone,
    password
  });

  res.status(201).json({
    success: true,
    message: "User registered successfully",

    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        gymId: user.gymId || null
      },

      accessToken,
      refreshToken
    }
  });
});


export const registerOwnerController = asyncHandler(async (req, res) => {
  const {
    name,
    email,
    phone,
    password,
    gymName,
    gymPhone,
    gymAddress
  } = req.body;

  const {
    user,
    gym,
    gymToken,
    joinUrl,
    qrUrl,
    accessToken,
    refreshToken
  } = await registerOwner({
    name,
    email,
    phone,
    password,
    gymName,
    gymPhone,
    gymAddress
  });

  res.status(201).json({
    success: true,
    message: "Gym owner registered successfully",

    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        gymId: user.gymId
      },

      gym: {
        id: gym._id,
        name: gym.name
      },

      qrUrl,
      joinUrl,

      accessToken,
      refreshToken
    }
  });
});


export const registerMemberController = asyncHandler(async (req, res) => {
  const {
    name,
    email,
    phone,
    password
  } = req.body;

  const {
    user,
    accessToken,
    refreshToken
  } = await registerMember({
    name,
    email,
    phone,
    password
  });

  res.status(201).json({
    success: true,
    message: "Member registered successfully",

    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        gymId: user.gymId || null
      },

      accessToken,
      refreshToken
    }
  });
});


export const login = asyncHandler(async (req, res) => {
  const {
    email,
    password
  } = req.body;

  const {
    user,
    accessToken,
    refreshToken
  } = await loginUser({
    email,
    password
  });

  res.status(200).json({
    success: true,
    message: "Login successful",

    data: {
      user: {
        id: user._id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        role: user.role,
        gymId: user.gymId || null
      },

      accessToken,
      refreshToken
    }
  });
});


export const refresh = asyncHandler(async (req, res) => {
  const { refreshToken } = req.body;

  const {
    accessToken,
    refreshToken: newRefreshToken
  } = await refreshUserToken(refreshToken);

  res.status(200).json({
    success: true,

    data: {
      accessToken,
      refreshToken: newRefreshToken
    }
  });
});


export const logout = asyncHandler(async (req, res) => {
  await logoutUser(req.user.userId);

  res.status(200).json({
    success: true,
    message: "Logout successful"
  });
});


export const me = asyncHandler(async (req, res) => {
  const user = await getCurrentUser(req.user.userId);

  res.status(200).json({
    success: true,

    data: {
      user
    }
  });
});