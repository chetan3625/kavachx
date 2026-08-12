import asyncHandler from "../../utils/AsyncHandler.js";
import { checkInMember, checkOutMember } from "../../services/attendance.service.js";

export const checkIn = asyncHandler(async (req, res) => {
  const data = await checkInMember(req.user.userId);
  
  res.status(200).json({
    success: true,
    message: "Checked in successfully",
    data
  });
});

export const checkOut = asyncHandler(async (req, res) => {
  const data = await checkOutMember(req.user.userId);
  
  res.status(200).json({
    success: true,
    message: "Checked out successfully",
    data
  });
});
