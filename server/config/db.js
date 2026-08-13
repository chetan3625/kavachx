import mongoose from "mongoose";
import dns from "dns";
import { env } from "./env.js";

// Override Node.js c-ares DNS resolver to use Google DNS
// Fixes SRV lookup failures on networks with restrictive local DNS
dns.setServers(["8.8.8.8", "8.8.4.4"]);

const connectDB = async () => {
  try {
    const connection = await mongoose.connect(env.MONGO_URI);

    console.log(
      `MongoDB connected: ${connection.connection.host}`
    );
  } catch (error) {
    console.error("MongoDB connection failed:");
    console.error(error.message);

    process.exit(1);
  }
};

export default connectDB;