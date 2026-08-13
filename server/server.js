import http from "http";
import app from "./app.js";
import connectDB from "./config/db.js";
import { initSocket } from "./config/socket.js";
const server = http.createServer(app);

// Initialize DB & Socket.io
connectDB();
initSocket(server);

// Base route test
app.get("/", (req, res) => {
  res.status(200).json({
    success: true,
    message: "KavachX Backend API is running smoothly 🚀",
  });
});

const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(
    `[Server] Running on port ${PORT} in ${process.env.NODE_ENV || "development"} mode`,
  );
});
