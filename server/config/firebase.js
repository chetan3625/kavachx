import admin from "firebase-admin";

// Safe optional chaining check for admin and admin.apps
if (admin && admin.apps && admin.apps.length === 0) {
  try {
    if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL) {
      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY
            ? process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n")
            : undefined,
        }),
      });
      console.log("[Firebase] Admin initialized successfully.");
    } else {
      console.log("[Firebase] Credentials missing in .env — FCM push skipped.");
    }
  } catch (err) {
    console.log("[Firebase] Initialization skipped:", err.message);
  }
}

// 1. Single Token Push Notification
export const sendPushNotification = async (
  fcmToken,
  title,
  body,
  data = {},
) => {
  if (!admin || !admin.apps || admin.apps.length === 0 || !fcmToken) {
    console.log(
      "[Firebase] Skipping single push notification (FCM not ready).",
    );
    return null;
  }

  const message = {
    token: fcmToken,
    notification: { title, body },
    data: {
      ...data,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("[Firebase] Successfully sent single notification:", response);
    return response;
  } catch (error) {
    console.error(
      "[Firebase] Error sending single push notification:",
      error.message,
    );
    return null;
  }
};

// 2. Multicast Batch Push Notifications
export const sendMultiplePushNotifications = async (
  fcmTokens,
  title,
  body,
  data = {},
) => {
  if (
    !admin ||
    !admin.apps ||
    admin.apps.length === 0 ||
    !fcmTokens ||
    fcmTokens.length === 0
  ) {
    console.log("[Firebase] Skipping multicast push notification.");
    return null;
  }

  const message = {
    tokens: fcmTokens,
    notification: { title, body },
    data: {
      ...data,
      click_action: "FLUTTER_NOTIFICATION_CLICK",
    },
  };

  try {
    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(
      `[Firebase] Successfully sent ${response.successCount} multicast messages.`,
    );
    return response;
  } catch (error) {
    console.error(
      "[Firebase] Error sending multicast notifications:",
      error.message,
    );
    return null;
  }
};

export default admin;
