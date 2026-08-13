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

const router = express.Router();

router.post("/register-owner", registerOwner);
router.post("/register-member", registerMember);
router.post("/login", login);
router.post("/refresh", refresh);
router.post("/logout", protect, logout);
router.get("/me", protect, getMe);
router.post("/forgot-password", forgotPassword);
router.patch("/reset-password/:token", resetPassword);
router.patch("/change-password", protect, changePassword);

export default router;
