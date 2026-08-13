import express from "express";

import authRoutes from "./auth.routes.js";
import gymRoutes from "./gym.routes.js";

const router = express.Router();

router.use("/auth", authRoutes);
router.use("/gyms", gymRoutes);

export default router;
