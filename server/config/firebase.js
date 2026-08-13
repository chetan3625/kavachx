import admin from "firebase-admin";

// Safe check for ESM compatibility
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
      console.log("[Firebase] Credentials missing in environment — FCM push skipped.");
    }
  } catch (err) {
    console.log("[Firebase] Initialization skipped:", err.message);
  }
}

export const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!admin || !admin.apps || admin.apps.length === 0 || !fcmToken) {
    return null;
  }

  const message = {
    token: fcmToken,
    notification: { title, body },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
  };

  try {
    return await admin.messaging().send(message);
  } catch (error) {
    console.error("[Firebase Error] Single push failed:", error.message);
    return null;
  }
};

export const sendMultiplePushNotifications = async (fcmTokens, title, body, data = {}) => {
  if (!admin || !admin.apps || admin.apps.length === 0 || !fcmTokens || fcmTokens.length === 0) {
    return null;
  }

  const message = {
    tokens: fcmTokens,
    notification: { title, body },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
  };

  try {
    return await admin.messaging().sendEachForMulticast(message);
  } catch (error) {
    console.error("[Firebase Error] Multicast push failed:", error.message);
    return null;
  }
};

export default admin;