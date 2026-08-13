import express from "express";
import http from "http";
import cors from "cors";
import dotenv from "dotenv";

import connectDB from "./config/db.js";
import { initSocket } from "./config/socket.js";
import apiRoutes from "./routes/index.js";
import { errorHandler, notFound } from "./middleware/error.middleware.js";

dotenv.config();

const app = express();
const server = http.createServer(app);

// Initialize DB & Socket.io
connectDB();
initSocket(server);

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Base Route Test
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "KavachX Backend API is running smoothly 🚀",
  });
});

// API Gateway Router
app.use("/api/v1", apiRoutes);

// Error Handling Middlewares
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(
    `[Server] Running on port ${PORT} in ${process.env.NODE_ENV || "development"} mode`,
  );
});
