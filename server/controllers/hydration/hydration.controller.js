import asyncHandler from "../../utils/AsyncHandler.js";

import { upsertHydration } from "../../services/hydration.service.js";

export const updateHydration = asyncHandler(async (req, res) => {
  const { waterLitres } = req.body;

  const hydration = await upsertHydration(req.user.userId, waterLitres);

  res.status(200).json({
    success: true,
    message: "Hydration updated",
    data: {
      waterLitres: hydration.waterLitres
    }
  });
});
