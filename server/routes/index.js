import express from "express";

import authRoutes from "./auth.routes.js";
import gymRoutes from "./gym.routes.js";
import hydrationRoutes from "./hydration.routes.js";

const router = express.Router();

router.use(
  "/auth",
  authRoutes
);

router.use("/gyms", gymRoutes);

router.use("/hydration", hydrationRoutes);

export default router;