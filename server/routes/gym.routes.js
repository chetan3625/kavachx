import express from "express";
import {
  joinRequest,
  listPendingRequests,
  approveRequest,
  rejectRequest,
  getGymMembers,
  getInactiveMembers,
} from "../controllers/gyms/gym.controller.js";
import {
  getPlans,
  createPlan,
  updatePlan,
  deletePlan,
} from "../controllers/gyms/plan.controller.js";
import { sendGymAnnouncement } from "../controllers/gyms/notification.controller.js";
import { protect, authorize } from "../middleware/auth.middleware.js";

const router = express.Router();

// Plans
router.get("/plans", protect, authorize("gym_owner"), getPlans);
router.post("/plans", protect, authorize("gym_owner"), createPlan);
router.put("/plans/:id", protect, authorize("gym_owner"), updatePlan);
router.delete("/plans/:id", protect, authorize("gym_owner"), deletePlan);

// Join Requests & Members
router.post("/join-request", protect, authorize("gym_member"), joinRequest);
router.get(
  "/join-requests",
  protect,
  authorize("gym_owner"),
  listPendingRequests,
);
router.patch(
  "/join-requests/:requestId/approve",
  protect,
  authorize("gym_owner"),
  approveRequest,
);
router.patch(
  "/join-requests/:requestId/reject",
  protect,
  authorize("gym_owner"),
  rejectRequest,
);
router.get("/members", protect, authorize("gym_owner"), getGymMembers);
router.get(
  "/inactive-members",
  protect,
  authorize("gym_owner"),
  getInactiveMembers,
);

// Announcements
router.post("/announce", protect, authorize("gym_owner"), sendGymAnnouncement);

export default router;
