import dotenv from "dotenv";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

dotenv.config();
dotenv.config({ path: path.resolve(__dirname, "../.env") });
dotenv.config({ path: path.resolve(__dirname, "../../.env") });

const requiredEnv = [
  "MONGO_URI",
  "JWT_ACCESS_SECRET",
  "JWT_REFRESH_SECRET"
];

for (const key of requiredEnv) {
  if (!process.env[key]) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
}

export const env = {
  NODE_ENV: process.env.NODE_ENV || "development",

  PORT: Number(process.env.PORT) || 5000,

  MONGO_URI: process.env.MONGO_URI,

  JWT_ACCESS_SECRET: process.env.JWT_ACCESS_SECRET,
  JWT_REFRESH_SECRET: process.env.JWT_REFRESH_SECRET,

  JWT_ACCESS_EXPIRES:
    process.env.JWT_ACCESS_EXPIRES ||
    process.env.JWT_ACCESS_EXPIRES_IN ||
    "1d",
  JWT_REFRESH_EXPIRES:
    process.env.JWT_REFRESH_EXPIRES ||
    process.env.JWT_REFRESH_EXPIRES_IN ||
    "30d",

  CLIENT_URL: process.env.CLIENT_URL || "http://localhost:5173",

  // WhatsApp Business API Credentials
  WHATSAPP_API_KEY: process.env.WHATSAPP_API_KEY || "",
  WHATSAPP_PHONE_NUMBER_ID: process.env.WHATSAPP_PHONE_NUMBER_ID || "",
  WHATSAPP_TEMPLATE_NAME: process.env.WHATSAPP_TEMPLATE_NAME || "gym_member_reactivation_v1",

  // Twilio SMS API Credentials
  TWILIO_ACCOUNT_SID: process.env.TWILIO_ACCOUNT_SID || "",
  TWILIO_AUTH_TOKEN: process.env.TWILIO_AUTH_TOKEN || "",
  TWILIO_PHONE_NUMBER: process.env.TWILIO_PHONE_NUMBER || "",

  // AI Voice Call API Credentials
  AI_CALL_API_KEY: process.env.AI_CALL_API_KEY || "",
  AI_CALL_AGENT_ID: process.env.AI_CALL_AGENT_ID || ""
};