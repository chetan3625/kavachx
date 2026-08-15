import admin from "firebase-admin";
import "./env.js"; // Ensures process.env variables are loaded via dotenv before init

const getAdmin = () => {
  if (admin && admin.apps && admin.apps.length > 0) {
    return admin;
  }

  try {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY;

    if (
      projectId &&
      clientEmail &&
      !clientEmail.includes("xxxxx") &&
      privateKey &&
      !privateKey.includes("...")
    ) {
      let formattedKey = privateKey;
      if (formattedKey.includes("\\n")) {
        formattedKey = formattedKey.replace(/\\n/g, "\n");
      }

      admin.initializeApp({
        credential: admin.credential.cert({
          projectId: projectId,
          clientEmail: clientEmail,
          privateKey: formattedKey,
        }),
      });
      console.log("[Firebase] Admin initialized successfully.");
      return admin;
    } else {
      console.warn(
        "[Firebase Warning] Placeholder or missing Firebase Service Account credentials in .env. FCM push notifications will fail until valid Firebase Admin credentials are set in .env.",
      );
    }
  } catch (err) {
    console.error("[Firebase Error] Admin initialization failed:", err.message);
  }
  return null;
};

// Initial attempt on module load
getAdmin();

export const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  const firebaseAdmin = getAdmin();
  if (!firebaseAdmin || !firebaseAdmin.apps || firebaseAdmin.apps.length === 0) {
    console.error(
      "[Firebase Error] Cannot send push notification: Firebase Admin is not initialized. Please check FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY in .env.",
    );
    return null;
  }

  if (!fcmToken) {
    console.warn("[Firebase Warning] FCM token is missing.");
    return null;
  }

  const message = {
    token: fcmToken,
    notification: { title, body },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
        sound: "default",
        priority: "max",
      },
    },
  };

  try {
    const response = await firebaseAdmin.messaging().send(message);
    console.log("[Firebase Success] Single push sent:", response);
    return response;
  } catch (error) {
    console.error("[Firebase Error] Single push failed:", error.message);
    return null;
  }
};

export const sendMultiplePushNotifications = async (
  fcmTokens,
  title,
  body,
  data = {},
) => {
  const firebaseAdmin = getAdmin();
  if (!firebaseAdmin || !firebaseAdmin.apps || firebaseAdmin.apps.length === 0) {
    console.error(
      "[Firebase Error] Cannot send multicast push notification: Firebase Admin is not initialized. Please check FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY in .env.",
    );
    return null;
  }

  if (!fcmTokens || fcmTokens.length === 0) {
    console.warn("[Firebase Warning] No target FCM tokens provided.");
    return null;
  }

  const message = {
    tokens: fcmTokens,
    notification: { title, body },
    data: { ...data, click_action: "FLUTTER_NOTIFICATION_CLICK" },
    android: {
      priority: "high",
      notification: {
        channelId: "high_importance_channel",
        sound: "default",
        priority: "max",
      },
    },
  };

  try {
    const response = await firebaseAdmin.messaging().sendEachForMulticast(message);
    console.log(
      `[Firebase Success] Multicast result: ${response.successCount} succeeded, ${response.failureCount} failed.`,
    );
    if (response.failureCount > 0) {
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.error(
            `[Firebase Error] Token index ${idx} failed:`,
            resp.error?.message || resp.error,
          );
        }
      });
    }
    return response;
  } catch (error) {
    console.error("[Firebase Error] Multicast push failed:", error.message);
    return null;
  }
};

export default admin;