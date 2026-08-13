import express from "express";
import cors from "cors";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import morgan from "morgan";
import cron from "node-cron";
import { sendWaterReminders, sendMembershipExpiryReminders } from "./services/notification.service.js";
import { env } from "./config/env.js";

import routes from "./routes/index.js";
import { requestResponseLogger } from "./middleware/logging.middleware.js";

import {
  errorHandler
} from "./middleware/error.middleware.js";

const app = express();


// Security
app.use(
  helmet()
);


// CORS
app.use(
  cors({
    origin: (origin, callback) => {
      if (!origin || env.NODE_ENV === "development") {
        callback(null, true);
      } else {
        callback(null, env.CLIENT_URL);
      }
    },
    credentials: true
  })
);


// Request parsing
app.use(
  express.json({
    limit: "10kb"
  })
);

app.use(
  express.urlencoded({
    extended: true,
    limit: "10kb"
  })
);

// Custom Request/Response logger
app.use(requestResponseLogger);


// Cookies
app.use(cookieParser());


// Logging
if (env.NODE_ENV === "development") {
  app.use(morgan("dev"));
}



// Health check
app.get(
  "/api/v1/health",
  (req, res) => {
    res.status(200).json({
      success: true,
      message: "KavachX API is running",
      timestamp: new Date().toISOString()
    });
  }
);


// API routes
app.use(
  "/api/v1",
  routes
);




// Error handler
app.use(
  errorHandler
);

// Water intake reminders - every hour
cron.schedule("0 * * * *", async () => {
  console.log("[Cron] Running water intake reminders...");
  await sendWaterReminders();
});

// Membership expiry reminders - daily at 9 AM
cron.schedule("0 9 * * *", async () => {
  console.log("[Cron] Running membership expiry check...");
  await sendMembershipExpiryReminders();
});

export default app;