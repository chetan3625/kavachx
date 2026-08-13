import asyncHandler from "../../utils/AsyncHandler.js";
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

export const registerOwner = asyncHandler(async (req, res, next) => {
  const result = await registerOwnerService(req.body);
  sendAuthResponse(res, 201, result);
});

export const registerMember = asyncHandler(async (req, res, next) => {
  const result = await registerMemberService(req.body);
  sendAuthResponse(res, 201, result);
});

export const login = asyncHandler(async (req, res, next) => {
  const result = await loginUser(req.body);
  sendAuthResponse(res, 200, result);
});

export const refresh = asyncHandler(async (req, res, next) => {
  const result = await refreshUserToken(req.body.refreshToken);
  res.status(200).json({
    success: true,
    accessToken: result.accessToken,
    token: result.accessToken,
  });
});

export const logout = asyncHandler(async (req, res, next) => {
  await logoutUser(req.user.userId);
  res.status(200).json({ success: true, message: "Logged out successfully" });
});

export const getMe = asyncHandler(async (req, res, next) => {
  const user = await getCurrentUser(req.user.userId);
  const serializedUser = serializeUser(user);
  res.status(200).json({
    success: true,
    data: { user: serializedUser },
    user: serializedUser,
  });
});

export const forgotPassword = asyncHandler(async (req, res, next) => {
  await forgotPasswordService(req.body.email);
  res.status(200).json({ success: true, message: "Password reset email sent" });
});





export const resetPassword = asyncHandler(async (req, res, next) => {
  await resetPasswordService(req.params.token, req.body.password);
  res
    .status(200)
    .json({ success: true, message: "Password reset successfully" });
});

export const changePassword = asyncHandler(async (req, res, next) => {
  await changePasswordService(
    req.user.userId,
    req.body.oldPassword,
    req.body.newPassword,
  );
  res
    .status(200)
    .json({ success: true, message: "Password changed successfully" });
});
