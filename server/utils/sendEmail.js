import nodemailer from "nodemailer";
import { env } from "../config/env.js";

const sendEmail = async (options) => {
  const transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || env.SMTP_HOST,
    port: process.env.SMTP_PORT || env.SMTP_PORT,
    auth: {
      user: process.env.SMTP_USER || env.SMTP_USER,
      pass: process.env.SMTP_PASSWORD || env.SMTP_PASSWORD,
    },
  });

  const message = {
    from: process.env.EMAIL_FROM || env.EMAIL_FROM,
    to: options.email,
    subject: options.subject,
    text: options.message,
    html: options.html,
  };

  const info = await transporter.sendMail(message);

  console.log("Message sent: %s", info.messageId);
};

export default sendEmail;
