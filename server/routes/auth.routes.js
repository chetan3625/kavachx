import express from "express";

import {
  register,
  registerOwnerController,
  registerMemberController,
  login,
  refresh,
  logout,
  me
} from "../controllers/auth/auth.controller.js";

import {
  protect
} from "../middleware/auth.middleware.js";

import {
  validateRegister,
  validateRegisterOwner,
  validateRegisterMember,
  validateLogin
} from "../validators/auth.validator.js";

const router = express.Router();


// POST /api/v1/auth/register-owner
router.post(
  "/register-owner",
  validateRegisterOwner,
  registerOwnerController
);

// POST /api/v1/auth/register-member
router.post(
  "/register-member",
  validateRegisterMember,
  registerMemberController
);


// POST /api/v1/auth/login
router.post(
  "/login",
  validateLogin,
  login
);


// POST /api/v1/auth/refresh
router.post(
  "/refresh",
  refresh
);


// POST /api/v1/auth/logout
router.post(
  "/logout",
  protect,
  logout
);


// GET /api/v1/auth/me
router.get(
  "/me",
  protect,
  me
);

export default router;