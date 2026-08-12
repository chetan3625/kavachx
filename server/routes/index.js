import express from "express";

import authRoutes from "./auth.routes.js";
import gymRoutes from "./gym.routes.js";
import attendanceRoutes from "./attendance.routes.js";
import exerciseRoutes from "./exercise.routes.js";

const router = express.Router();

router.use(
  "/auth",
  authRoutes
);

router.use("/gyms", gymRoutes);
router.use("/attendance", attendanceRoutes);
router.use("/exercises", exerciseRoutes);

export default router;