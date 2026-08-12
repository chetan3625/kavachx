import ApiError from "../utils/ApiError.js";

export const validateUpdateProgress = (req, res, next) => {
  const { completedSets } = req.body;
  
  if (completedSets === undefined || typeof completedSets !== "number" || completedSets < 0 || !Number.isInteger(completedSets)) {
    return next(new ApiError(400, "completedSets is required and must be a non-negative integer"));
  }
  
  next();
};
