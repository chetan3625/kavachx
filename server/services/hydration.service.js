import Hydration from "../models/Hydration.js";

const startOfDay = (date = new Date()) => {
  const d = new Date(date);
  d.setUTCHours(0, 0, 0, 0);
  return d;
};

const endOfDay = (date = new Date()) => {
  const d = startOfDay(date);
  d.setUTCDate(d.getUTCDate() + 1);
  return d;
};

export const upsertHydration = async (userId, waterLitres) => {
  const dayStart = startOfDay();
  const dayEnd = endOfDay();

  const hydration = await Hydration.findOneAndUpdate(
    { user: userId, date: { $gte: dayStart, $lt: dayEnd } },
    { waterLitres, date: dayStart },
    { new: true, upsert: true }
  );

  return hydration;
};
