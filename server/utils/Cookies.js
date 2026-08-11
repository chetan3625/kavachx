import { env } from "../config/env.js";

export const setRefreshTokenCookie = (
  res,
  refreshToken
) => {
  res.cookie("refreshToken", refreshToken, {
    httpOnly: true,

    secure: env.NODE_ENV === "production",

    sameSite:
      env.NODE_ENV === "production"
        ? "none"
        : "lax",

    maxAge: 7 * 24 * 60 * 60 * 1000,

    path: "/"
  });
};

export const clearRefreshTokenCookie = (res) => {
  res.clearCookie("refreshToken", {
    httpOnly: true,

    secure: env.NODE_ENV === "production",

    sameSite:
      env.NODE_ENV === "production"
        ? "none"
        : "lax",

    path: "/"
  });
};