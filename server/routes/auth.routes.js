import express from "express";
import {
  registerOwner,
  registerMember,
  login,
  refresh,
  logout,
  getMe,
  forgotPassword,
  resetPassword,
  changePassword,
} from "../controllers/auth/auth.controller.js";
import { protect } from "../middleware/auth.middleware.js";
import {
  validateRegisterOwner,
  validateRegisterMember,
  validateLogin,
  validateForgotPassword,
  validateResetPassword,
  validateChangePassword,
} from "../validators/auth.validator.js";

const router = express.Router();

router.post("/register-owner", validateRegisterOwner, registerOwner);
router.post("/register-member", validateRegisterMember, registerMember);
router.post("/login", validateLogin, login);
router.post("/refresh", refresh);
router.post("/logout", protect, logout);
router.get("/me", protect, getMe);
router.post("/forgot-password", validateForgotPassword, forgotPassword);
router.patch("/reset-password/:token", validateResetPassword, resetPassword);
router.patch(
  "/change-password",
  protect,
  validateChangePassword,
  changePassword,
);

export default router;
