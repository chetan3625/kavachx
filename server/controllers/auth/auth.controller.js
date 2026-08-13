import {
  changePasswordService,
  forgotPasswordService,
  getCurrentUser,
  loginUser,
  logoutUser,
  refreshUserToken,
  registerMember as registerMemberService,
  registerOwner as registerOwnerService,
  resetPasswordService,
} from "../../services/auth.service.js";
import { env } from "../../config/env.js";

const serializeUser = (user) => {
  if (!user) return null;
  return {
    id: user._id ? user._id.toString() : user.id,
    _id: user._id ? user._id.toString() : user.id,
    name: user.name || "",
    email: user.email || "",
    phone: user.phone || "",
    role: user.role || "",
    gymId: user.gymId ? user.gymId.toString() : null,
    isOnboarded: user.isOnboarded ?? false,
  };
};

const sendAuthResponse = (res, status, result) => {
  const serializedUser = serializeUser(result.user);

  res.status(status).json({
    success: true,
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
    token: result.accessToken,
    user: serializedUser,
    gym: result.gym || null,
    gymToken: result.gymToken || null,
    joinUrl: result.joinUrl || null,
    qrUrl: result.qrUrl || null,
    data: {
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      user: serializedUser,
      gym: result.gym || null,
      gymToken: result.gymToken || null,
      joinUrl: result.joinUrl || null,
      qrUrl: result.qrUrl || null,
    },
  });
};

export const registerOwner = async (req, res, next) => {
  try {
    const result = await registerOwnerService(req.body);
    sendAuthResponse(res, 201, result);
  } catch (error) {
    next(error);
  }
};

export const registerMember = async (req, res, next) => {
  try {
    const result = await registerMemberService(req.body);
    sendAuthResponse(res, 201, result);
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const result = await loginUser(req.body);
    sendAuthResponse(res, 200, result);
  } catch (error) {
    next(error);
  }
};

export const refresh = async (req, res, next) => {
  try {
    const result = await refreshUserToken(req.body.refreshToken);
    res.status(200).json({
      success: true,
      accessToken: result.accessToken,
      token: result.accessToken,
    });
  } catch (error) {
    next(error);
  }
};

export const logout = async (req, res, next) => {
  try {
    await logoutUser(req.user.userId);
    res.status(200).json({ success: true, message: "Logged out successfully" });
  } catch (error) {
    next(error);
  }
};

export const getMe = async (req, res, next) => {
  try {
    const user = await getCurrentUser(req.user.userId);
    const serializedUser = serializeUser(user);
    res.status(200).json({
      success: true,
      data: { user: serializedUser },
      user: serializedUser,
    });
  } catch (error) {
    next(error);
  }
};

export const forgotPassword = async (req, res, next) => {
  try {
    await forgotPasswordService(req.body.email);
    res
      .status(200)
      .json({ success: true, message: "Password reset email sent" });
  } catch (error) {
    next(error);
  }
};

export const resetPassword = async (req, res, next) => {
  try {
    await resetPasswordService(req.params.token, req.body.password);
    res
      .status(200)
      .json({ success: true, message: "Password reset successfully" });
  } catch (error) {
    next(error);
  }
};

export const changePassword = async (req, res, next) => {
  try {
    await changePasswordService(
      req.user.userId,
      req.body.oldPassword,
      req.body.newPassword,
    );
    res
      .status(200)
      .json({ success: true, message: "Password changed successfully" });
  } catch (error) {
    next(error);
  }
};
