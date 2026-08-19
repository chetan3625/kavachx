import { env } from "../config/env.js";

/**
 * Service to execute multi-channel broadcasts to inactive members.
 * Supports WhatsApp Cloud API (Meta), Twilio SMS API, and AI Voice Call Agent API (Bland AI/Vapi/Twilio Voice).
 * Falls back gracefully to dry-run logging when credentials are missing.
 */

// 1. WhatsApp Cloud API Broadcast (Meta Business Manager Template)
export const sendWhatsAppBroadcast = async ({ members, gymName, days }) => {
  const results = [];
  const { WHATSAPP_API_KEY, WHATSAPP_PHONE_NUMBER_ID, WHATSAPP_TEMPLATE_NAME } = env;

  const isConfigured = Boolean(WHATSAPP_API_KEY && WHATSAPP_PHONE_NUMBER_ID);

  for (const member of members) {
    const rawPhone = member.phone || "";
    let cleanPhone = rawPhone.replace(/\D/g, "");
    if (!cleanPhone.startsWith("91") && cleanPhone.length === 10) {
      cleanPhone = `91${cleanPhone}`;
    }

    if (!cleanPhone) continue;

    if (isConfigured) {
      try {
        const response = await fetch(
          `https://graph.facebook.com/v18.0/${WHATSAPP_PHONE_NUMBER_ID}/messages`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${WHATSAPP_API_KEY}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              messaging_product: "whatsapp",
              to: cleanPhone,
              type: "template",
              template: {
                name: WHATSAPP_TEMPLATE_NAME,
                language: { code: "en_US" },
                components: [
                  {
                    type: "body",
                    parameters: [
                      { type: "text", text: member.name || "Valued Member" },
                      { type: "text", text: String(member.daysAbsent || days) },
                      { type: "text", text: gymName || "KavachX Gym" },
                    ],
                  },
                ],
              },
            }),
          }
        );
        const data = await response.json();
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: response.ok, data });
      } catch (err) {
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: false, error: err.message });
      }
    } else {
      // Simulated / Dry-run execution
      console.log(`[SIMULATED WHATSAPP BROADCAST] Sent Meta Template to ${member.name} (${cleanPhone}): Gym=${gymName}, Days=${days}`);
      results.push({ memberId: member._id || member.id, phone: cleanPhone, success: true, simulated: true });
    }
  }

  return { channel: "whatsapp", totalTargeted: members.length, results };
};

// 2. Twilio SMS API Broadcast
export const sendSMSBroadcast = async ({ members, gymName, days }) => {
  const results = [];
  const { TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_PHONE_NUMBER } = env;

  const isConfigured = Boolean(TWILIO_ACCOUNT_SID && TWILIO_AUTH_TOKEN && TWILIO_PHONE_NUMBER);

  for (const member of members) {
    const rawPhone = member.phone || "";
    let cleanPhone = rawPhone.replace(/\D/g, "");
    if (!cleanPhone.startsWith("+")) {
      cleanPhone = cleanPhone.startsWith("91") ? `+${cleanPhone}` : `+91${cleanPhone}`;
    }

    if (!cleanPhone || cleanPhone.length < 10) continue;

    const messageText = `Hi ${member.name}! We miss seeing you at ${gymName}. You have been away for ${member.daysAbsent || days} days. Drop by today to resume your workout!`;

    if (isConfigured) {
      try {
        const auth = Buffer.from(`${TWILIO_ACCOUNT_SID}:${TWILIO_AUTH_TOKEN}`).toString("base64");
        const bodyParams = new URLSearchParams({
          From: TWILIO_PHONE_NUMBER,
          To: cleanPhone,
          Body: messageText,
        });

        const response = await fetch(
          `https://api.twilio.com/2010-04-01/Accounts/${TWILIO_ACCOUNT_SID}/Messages.json`,
          {
            method: "POST",
            headers: {
              Authorization: `Basic ${auth}`,
              "Content-Type": "application/x-www-form-urlencoded",
            },
            body: bodyParams.toString(),
          }
        );

        const data = await response.json();
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: response.ok, data });
      } catch (err) {
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: false, error: err.message });
      }
    } else {
      // Simulated / Dry-run execution
      console.log(`[SIMULATED SMS BROADCAST] Sent SMS to ${member.name} (${cleanPhone}): "${messageText}"`);
      results.push({ memberId: member._id || member.id, phone: cleanPhone, success: true, simulated: true });
    }
  }

  return { channel: "sms", totalTargeted: members.length, results };
};

// 3. AI Voice Call Agent Broadcast (Bland AI / Vapi API)
export const sendAICallBroadcast = async ({ members, gymName, days }) => {
  const results = [];
  const { AI_CALL_API_KEY, AI_CALL_AGENT_ID } = env;

  const isConfigured = Boolean(AI_CALL_API_KEY);

  for (const member of members) {
    const rawPhone = member.phone || "";
    let cleanPhone = rawPhone.replace(/\D/g, "");
    if (!cleanPhone.startsWith("+")) {
      cleanPhone = cleanPhone.startsWith("91") ? `+${cleanPhone}` : `+91${cleanPhone}`;
    }

    if (!cleanPhone || cleanPhone.length < 10) continue;

    const taskPrompt = `You are an AI assistant calling on behalf of ${gymName}. Call ${member.name} politely and let them know they haven't visited the gym in ${member.daysAbsent || days} days. Ask if everything is okay and encourage them to return today.`;

    if (isConfigured) {
      try {
        const response = await fetch("https://api.bland.ai/v1/calls", {
          method: "POST",
          headers: {
            authorization: AI_CALL_API_KEY,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            phone_number: cleanPhone,
            task: taskPrompt,
            agent_id: AI_CALL_AGENT_ID || undefined,
            voice: "nat",
            first_sentence: `Hi ${member.name}, this is the automated AI assistant from ${gymName}! We missed seeing you at the gym!`,
          }),
        });

        const data = await response.json();
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: response.ok, data });
      } catch (err) {
        results.push({ memberId: member._id || member.id, phone: cleanPhone, success: false, error: err.message });
      }
    } else {
      // Simulated / Dry-run execution
      console.log(`[SIMULATED AI CALL BROADCAST] Initiated AI Agent call to ${member.name} (${cleanPhone}): Task="${taskPrompt}"`);
      results.push({ memberId: member._id || member.id, phone: cleanPhone, success: true, simulated: true });
    }
  }

  return { channel: "aicall", totalTargeted: members.length, results };
};
