import asyncHandler from "../../utils/asyncHandler.js";

import {
  registerUser,
  registerOwner,
  registerMember,
  loginUser,
  refreshUserToken,
  logoutUser,
  getCurrentUser
} from "../../services/auth.service.js";

import {
  setRefreshTokenCookie,
  clearRefreshTokenCookie
} from "../../utils/cookies.js";

export const register = asyncHandler(
  async (req, res) => {
    const {
      name,
      email,
      phone,
      password
    } = req.body;

    // Backwards-compatible: create owner by default
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

    setRefreshTokenCookie(
      res,
      refreshToken
    );

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

        accessToken
      }
    });
  }
);

export const registerOwnerController = asyncHandler(
  async (req, res) => {
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

    setRefreshTokenCookie(res, refreshToken);

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
        qr: {
          token: gymToken,
          joinUrl: `https://kavachx.com/join/${gymToken}`
        },
        accessToken
      }
    });
  }
);

export const registerMemberController = asyncHandler(
  async (req, res) => {
    const { name, email, phone, password } = req.body;

    const { user, accessToken, refreshToken } = await registerMember({
      name,
      email,
      phone,
      password
    });

    setRefreshTokenCookie(res, refreshToken);

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
          gymId: user.gymId
        },
        accessToken
      }
    });
  }
);

export const login = asyncHandler(
  async (req, res) => {
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

    setRefreshTokenCookie(
      res,
      refreshToken
    );

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

        accessToken
      }
    });
  }
);

export const refresh = asyncHandler(
  async (req, res) => {
    const refreshToken =
      req.cookies.refreshToken;

    const {
      accessToken
    } = await refreshUserToken(
      refreshToken
    );

    res.status(200).json({
      success: true,

      data: {
        accessToken
      }
    });
  }
);

export const logout = asyncHandler(
  async (req, res) => {
    await logoutUser(
      req.user.userId
    );

    clearRefreshTokenCookie(res);

    res.status(200).json({
      success: true,

      message: "Logout successful"
    });
  }
);

export const me = asyncHandler(
  async (req, res) => {
    const user =
      await getCurrentUser(
        req.user.userId
      );

    res.status(200).json({
      success: true,

      data: {
        user
      }
    });
  }
);