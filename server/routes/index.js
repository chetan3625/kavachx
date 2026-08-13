import express from "express";

import authRoutes from "./auth.routes.js";
import gymRoutes from "./gym.routes.js";
import memberRoutes from "./member.routes.js"; // <-- ADD THIS IMPORT

const router = express.Router();

router.use("/auth", authRoutes);



router.use("/gyms", gymRoutes);
router.use("/members", memberRoutes); // Line 19 works now!

export default router;
