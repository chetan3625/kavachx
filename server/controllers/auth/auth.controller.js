import User from "../models/User.js";
import jwt from "jsonwebtoken";

const generateToken = (userId, role) => {
  return jwt.sign({ userId, role }, process.env.JWT_SECRET, {
    expiresIn: "30d",
  });
};

export const register = async (req, res, next) => {
  try {
    const { name, email, password, role } = req.body;
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res
        .status(400)
        .json({
          success: false,
          message: "User already exists with this email.",
        });
    }

    const user = await User.create({ name, email, password, role });
    const token = generateToken(user._id, user.role);

    return res.status(201).json({
      success: true,
      token,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
      },
    });
  } catch (error) {
    next(error);
  }
};

export const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email });

    if (!user || !(await user.matchPassword(password))) {
      return res
        .status(401)
        .json({ success: false, message: "Invalid email or password." });
    }

    user.lastActiveAt = new Date();
    await user.save();

    const token = generateToken(user._id, user.role);

    return res.status(200).json({
      success: true,
      token,
      data: {
        id: user._id,
        name: user.name,
        email: user.email,
        role: user.role,
        gymId: user.gymId,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/auth/me
export const getMe = async (req, res, next) => {
  try {
    // Check both req.user.userId and req.user._id safely
    const targetId = req.user?.userId || req.user?._id || req.user?.id;

    if (!targetId) {
      return res.status(401).json({
        success: false,
        message: "Invalid token payload — user ID missing",
      });
    }

    const user = await User.findById(targetId).select("-password");

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User account not found",
      });
    }

    return res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    next(error);
  }
};