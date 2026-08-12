import express from "express";
import { checkIn, checkOut } from "../controllers/attendance/attendance.controller.js";
import { protect, authorize } from "../middleware/auth.middleware.js";

const router = express.Router();

// POST /api/v1/attendance/check-in
router.post("/check-in", protect, authorize("gym_member"), checkIn);

// POST /api/v1/attendance/check-out
router.post("/check-out", protect, authorize("gym_member"), checkOut);

export default router;
