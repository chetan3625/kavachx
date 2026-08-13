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

const serializeUser = (user) => ({
  id: user._id,
  name: user.name,
  email: user.email,
  phone: user.phone,
  role: user.role,
  gymId: user.gymId,
});

const sendAuthResponse = (res, status, result) => {
  res.status(status).json({
    success: true,
    accessToken: result.accessToken,
    refreshToken: result.refreshToken,
    // `token` is retained for older clients.
    token: result.accessToken,
    user: serializeUser(result.user),
    data: { user: serializeUser(result.user), gym: result.gym, gymToken: result.gymToken, joinUrl: result.joinUrl, qrUrl: result.qrUrl },
  });
};

export const registerOwner = async (req, res, next) => {
  try {
    const result = await registerOwnerService(req.body);
    sendAuthResponse(res, 201, result);
  } catch (error) { next(error); }
};

export const registerMember = async (req, res, next) => {
  try {
    const result = await registerMemberService(req.body);
    sendAuthResponse(res, 201, result);
  } catch (error) { next(error); }
};

export const login = async (req, res, next) => {
  try {
    const result = await loginUser(req.body);
    sendAuthResponse(res, 200, result);
  } catch (error) { next(error); }
};

export const refresh = async (req, res, next) => {
  try {
    const result = await refreshUserToken(req.body.refreshToken);
    res.status(200).json({ success: true, accessToken: result.accessToken, token: result.accessToken });
  } catch (error) { next(error); }
};

export const logout = async (req, res, next) => {
  try {
    await logoutUser(req.user.userId);
    res.status(200).json({ success: true, message: "Logged out successfully" });
  } catch (error) { next(error); }
};

export const getMe = async (req, res, next) => {
  try {
    const user = await getCurrentUser(req.user.userId);
    res.status(200).json({ success: true, data: serializeUser(user), user: serializeUser(user) });
  } catch (error) { next(error); }
};

export const forgotPassword = async (req, res, next) => {
  try {
    await forgotPasswordService(req.body.email);
    res.status(200).json({ success: true, message: "Password reset email sent" });
  } catch (error) { next(error); }
};

export const resetPassword = async (req, res, next) => {
  try {
    await resetPasswordService(req.params.token, req.body.password);
    res.status(200).json({ success: true, message: "Password reset successfully" });
  } catch (error) { next(error); }
};

export const changePassword = async (req, res, next) => {
  try {
    await changePasswordService(req.user.userId, req.body.oldPassword, req.body.newPassword);
    res.status(200).json({ success: true, message: "Password changed successfully" });
  } catch (error) { next(error); }
};
