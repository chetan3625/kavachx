import User from "../models/User.js";
import Notification from "../models/Notification.js";
import { sendPushNotification } from "../config/firebase.js";

/**
 * Create a notification in DB and optionally send a push notification
 */
export const createAndSendNotification = async ({
  userId,
  gymId,
  title,
  message,
  type = "general",
}) => {
  try {
    // Save to database
    const notification = await Notification.create({
      userId,
      gymId: gymId || null,
      title,
      message,
      type,
    });

    // Send push notification if user has FCM token
    const user = await User.findById(userId).select("fcmToken");
    if (user?.fcmToken) {
      await sendPushNotification(user.fcmToken, title, message, {
        notificationId: notification._id.toString(),
        type,
      });
    }

    return notification;
  } catch (error) {
    console.error(
      "[NotificationService] Error creating notification:",
      error.message,
    );
    return null;
  }
};

/**
 * Send water intake reminders to users who have opted in
 * Called by cron job every hour
 */
export const sendWaterReminders = async () => {
  try {
    const now = new Date();

    // Find users who want water reminders and have FCM tokens
    const users = await User.find({
      waterIntakeReminder: true,
      fcmToken: { $ne: null },
      isOnboarded: true,
    }).select(
      "_id fcmToken waterReminderIntervalHours lastWaterReminderSentAt targetWaterLitres name",
    );

    let sentCount = 0;

    for (const user of users) {
      const intervalMs =
        (user.waterReminderIntervalHours || 2) * 60 * 60 * 1000;
      const lastSent = user.lastWaterReminderSentAt;

      // Skip if we sent a reminder recently
      if (lastSent && now - new Date(lastSent) < intervalMs) {
        continue;
      }

      // Only send reminders during reasonable hours (6 AM to 10 PM)
      const currentHour = now.getHours();
      if (currentHour < 6 || currentHour >= 22) {
        continue;
      }

      const target = user.targetWaterLitres || 4;
      const messages = [
        `Stay hydrated! Aim for ${target}L today 💧`,
        `Time for a water break! Your goal: ${target}L 🥤`,
        `Don't forget to drink water! Target: ${target}L 💪`,
        `Hydration check! Keep pushing towards ${target}L 🏋️`,
      ];
      const randomMsg = messages[Math.floor(Math.random() * messages.length)];

      await sendPushNotification(
        user.fcmToken,
        "💧 Hydration Reminder",
        randomMsg,
        { type: "water_reminder" },
      );

      // Update last reminder timestamp
      await User.findByIdAndUpdate(user._id, { lastWaterReminderSentAt: now });
      sentCount++;
    }

    console.log(
      `[WaterReminder] Sent ${sentCount} reminders to ${users.length} eligible users.`,
    );
  } catch (error) {
    console.error("[WaterReminder] Error:", error.message);
  }
};

/**
 * Check and send membership expiry warnings
 * Called by cron job daily
 */
export const sendMembershipExpiryReminders = async () => {
  try {
    // Import Membership model dynamically to avoid circular deps
    const { default: Membership } = await import("../models/Membership.js");

    const now = new Date();
    const warningDays = [7, 3, 1];

    for (const days of warningDays) {
      const targetDate = new Date(now);
      targetDate.setDate(targetDate.getDate() + days);
      const startOfDay = new Date(targetDate.setHours(0, 0, 0, 0));
      const endOfDay = new Date(targetDate.setHours(23, 59, 59, 999));

      const expiringMemberships = await Membership.find({
        status: "active",
        endDate: { $gte: startOfDay, $lte: endOfDay },
      }).populate("memberId", "fcmToken name");

      for (const membership of expiringMemberships) {
        if (membership.memberId) {
          await createAndSendNotification({
            userId: membership.memberId._id,
            title: "⚠️ Membership Expiring Soon",
            message: `Your membership expires in ${days} day${days > 1 ? "s" : ""}. Renew now to keep your streak!`,
            type: "membership_expiry",
          });
        }
      }
    }

    console.log("[ExpiryReminder] Membership expiry check completed.");
  } catch (error) {
    console.error("[ExpiryReminder] Error:", error.message);
  }
};
