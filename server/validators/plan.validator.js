import ApiError from "../utils/ApiError.js";

export const validateCreatePlan = (req, res, next) => {
  const { name, price, durationInMonths } = req.body;

  if (!name || price === undefined || durationInMonths === undefined) {
    return next(
      new ApiError(400, "name, price, and durationInMonths are required")
    );
  }

  if (typeof price !== "number" || price < 0) {
    return next(new ApiError(400, "price must be a non-negative number"));
  }

  if (typeof durationInMonths !== "number" || durationInMonths < 1) {
    return next(
      new ApiError(400, "durationInMonths must be a positive integer (minimum 1)")
    );
  }

  next();
};

export const validateUpdatePlan = (req, res, next) => {
  const { price, durationInMonths } = req.body;

  if (price !== undefined && (typeof price !== "number" || price < 0)) {
    return next(new ApiError(400, "price must be a non-negative number"));
  }

  if (
    durationInMonths !== undefined &&
    (typeof durationInMonths !== "number" || durationInMonths < 1)
  ) {
    return next(
      new ApiError(400, "durationInMonths must be a positive integer (minimum 1)")
    );
  }

  next();
};
