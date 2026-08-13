import ApiError from "../utils/ApiError.js";

export const validateRegisterOwner = (req, res, next) => {
  const { name, email, phone, password, gymName } = req.body || {};

  if (!name || !email || !phone || !password || !gymName) {
    return next(
      new ApiError(
        400,
        "name, email, phone, password and gymName are required",
      ),
    );
  }

  if (password.length < 8) {
    return next(new ApiError(400, "Password must be at least 8 characters"));
  }

  return next();
};

export const validateRegisterMember = (req, res, next) => {
  const { name, email, phone, password } = req.body || {};

  if (!name || !email || !phone || !password) {
    return next(
      new ApiError(400, "name, email, phone and password are required"),
    );
  }

  if (password.length < 8) {
    return next(new ApiError(400, "Password must be at least 8 characters"));
  }

  if (req.body.role || req.body.gymId || req.body.ownerId) {
    return next(
      new ApiError(400, "role, gymId and ownerId cannot be set by client"),
    );
  }

  return next();
};

export const validateLogin = (req, res, next) => {
  const { email, password } = req.body || {};

  if (!email || !password) {
    return next(new ApiError(400, "Email and password are required"));
  }

  return next();
};

export const validateForgotPassword = (req, res, next) => {
  if (!req.body || !req.body.email) {
    return next(new ApiError(400, "Please provide a valid email"));
  }
  return next();
};

export const validateResetPassword = (req, res, next) => {
  if (!req.body || !req.body.password || req.body.password.length < 8) {
    return next(
      new ApiError(
        400,
        "Password is required and must be at least 8 characters",
      ),
    );
  }
  return next();
};

export const validateChangePassword = (req, res, next) => {
  const { oldPassword, newPassword } = req.body || {};
  if (!oldPassword || !newPassword) {
    return next(new ApiError(400, "oldPassword and newPassword are required"));
  }
  if (newPassword.length < 8) {
    return next(
      new ApiError(400, "New password must be at least 8 characters"),
    );
  }
  return next();
};
