import express from "express";
import { updateProgress } from "../controllers/exercises/exercise.controller.js";
import { protect, authorize } from "../middleware/auth.middleware.js";
import { validateUpdateProgress } from "../validators/exercise.validator.js";

const router = express.Router();

// PATCH /api/v1/exercises/:exerciseId/progress
router.patch(
  "/:exerciseId/progress",
  protect,
  authorize("gym_member"),
  validateUpdateProgress,
  updateProgress
);

export default router;
