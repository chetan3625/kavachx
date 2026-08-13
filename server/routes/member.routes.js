import express from "express";
import { protect } from "../middleware/auth.middleware.js";
import { upload } from "../middleware/multer.middleware.js";
import {
  getDashboardSummary,
  memberCheckIn,
  memberCheckOut,
  updateHydration,
  updateExerciseProgress,
  createExercise,
  getExercises,
  updateExercise,
  deleteExercise,
  logWorkoutSummary,
  getCurrentSubscription,
  getAvailablePlans,
  subscribeToPlan,
  getProfile,
  updateProfile,
  uploadProfileImage,
  getAttendanceHistory,
  getAttendanceStats,
  getNotifications,
  markAllNotificationsRead,
  markNotificationRead,
  getGymDetails
} from "../controllers/members/member.controller.js";
import { completeOnboarding, updateFcmToken } from "../controllers/members/onboarding.controller.js";

const router = express.Router();

// Member Dashboard Summary
router.get("/dashboard/summary", protect, getDashboardSummary);

// Member Check-in & Check-out
router.post("/check-in", protect, memberCheckIn);
router.post("/check-out", protect, memberCheckOut);

// Member Hydration
router.patch("/hydration", protect, updateHydration);

// Exercise Routine CRUD & Workout Summary
router.post("/exercises", protect, createExercise);
router.get("/exercises", protect, getExercises);
router.put("/exercises/:id", protect, updateExercise);
router.delete("/exercises/:id", protect, deleteExercise);
router.patch("/exercises/:exerciseId/progress", protect, updateExerciseProgress);
router.post("/workout-summary", protect, logWorkoutSummary);

// Member Subscriptions & Plans
router.get("/subscription/current", protect, getCurrentSubscription);
router.get("/plans", protect, getAvailablePlans);
router.post("/subscription/subscribe", protect, subscribeToPlan);

// Member Profile
router.get("/profile", protect, getProfile);
router.put("/profile", protect, updateProfile);
router.put("/profile/image", protect, upload.single("profileImage"), uploadProfileImage);

// Attendance History & Stats
router.get("/attendance/history", protect, getAttendanceHistory);
router.get("/attendance/stats", protect, getAttendanceStats);

// Notifications
router.get("/notifications", protect, getNotifications);
router.patch("/notifications/read-all", protect, markAllNotificationsRead);
router.patch("/notifications/:id/read", protect, markNotificationRead);

// Gym Details
router.get("/gym", protect, getGymDetails);
// Onboarding
router.post("/onboarding", protect, completeOnboarding);

// FCM Token
router.put("/fcm-token", protect, updateFcmToken);

export default router;
