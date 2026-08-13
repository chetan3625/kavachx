import express from "express";

import { updateHydration } from "../controllers/hydration/hydration.controller.js";

import { protect } from "../middleware/auth.middleware.js";

import { validateHydration } from "../validators/hydration.validator.js";

const router = express.Router();

router.patch("/", protect, validateHydration, updateHydration);

export default router;
