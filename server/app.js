import express from "express";
import cors from "cors";
import helmet from "helmet";
import cookieParser from "cookie-parser";
import morgan from "morgan";


import { env } from "./config/env.js";

import routes from "./routes/index.js";

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
    origin: env.CLIENT_URL,
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

export default app;