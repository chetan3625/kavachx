import jwt from "jsonwebtoken";

import { env } from "../config/env.js";
import ApiError from "../utils/ApiError.js";

export const protect = (
  req,
  res,
  next
) => {
  try {
    const authHeader =
      req.headers.authorization;

    if (
      !authHeader ||
      !authHeader.startsWith("Bearer ")
    ) {
      return next(
        new ApiError(
          401,
          "Authentication required"
        )
      );
    }

    const token =
      authHeader.split(" ")[1];

    const decoded = jwt.verify(
      token,
      env.JWT_ACCESS_SECRET
    );

    req.user = decoded;

    next();
  } catch (error) {
    return next(
      new ApiError(
        401,
        "Invalid or expired access token"
      )
    );
  }
};

export const authorize = (
  ...allowedRoles
) => {
  return (req, res, next) => {
    if (!req.user) {
      return next(
        new ApiError(
          401,
          "Authentication required"
        )
      );
    }

    if (
      !allowedRoles.includes(
        req.user.role
      )
    ) {
      return next(
        new ApiError(
          403,
          "You do not have permission to perform this action"
        )
      );
    }

    next();
  };
};