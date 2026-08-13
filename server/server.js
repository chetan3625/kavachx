import http from "http";
import { env } from "./config/env.js";
import app from "./app.js";
import connectDB from "./config/db.js";
import { initSocket } from "./config/socket.js";

const startServer = async () => {
  try {
    await connectDB();

    const server = http.createServer(app);
    initSocket(server);

    server.listen(env.PORT, () => {
      console.log(`KavachX server running on port ${env.PORT}`);
      console.log(`Environment: ${env.NODE_ENV}`);
      console.log(`http://localhost:${env.PORT}`);
    });
  } catch (error) {
    console.error("Server startup failed:", error);
    process.exit(1);
  }
};

startServer();