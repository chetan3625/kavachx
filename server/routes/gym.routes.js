import express from "express";

import {
  joinRequest,
  listPendingRequests,
  approveRequest,
  rejectRequest
} from "../controllers/gyms/gym.controller.js";

import { protect, authorize } from "../middleware/auth.middleware.js";

const router = express.Router();

// POST /api/v1/gyms/join-request
router.post("/join-request", protect, authorize("gym_member"), joinRequest);

// GET /api/v1/gyms/join-requests
router.get("/join-requests", protect, authorize("gym_owner"), listPendingRequests);

// PATCH /api/v1/gyms/join-requests/:requestId/approve
router.patch(
  "/join-requests/:requestId/approve",
  protect,
  authorize("gym_owner"),
  approveRequest
);

// PATCH /api/v1/gyms/join-requests/:requestId/reject
router.patch(
  "/join-requests/:requestId/reject",
  protect,
  authorize("gym_owner"),
  rejectRequest
);

export default router;
