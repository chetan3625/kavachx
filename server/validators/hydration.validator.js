import ApiError from "../utils/ApiError.js";

export const validateHydration = (req, res, next) => {
  const { waterLitres } = req.body;

  if (waterLitres === undefined || waterLitres === null) {
    return next(new ApiError(400, "waterLitres is required"));
  }

  if (typeof waterLitres !== "number" || Number.isNaN(waterLitres)) {
    return next(new ApiError(400, "waterLitres must be a valid number"));
  }

  if (waterLitres < 0) {
    return next(new ApiError(400, "waterLitres cannot be negative"));
  }

  if (!Number.isFinite(waterLitres)) {
    return next(new ApiError(400, "waterLitres must be a finite number"));
  }

  next();
};
