import Attendance from "../models/Attendance.js";
import User from "../models/User.js";
import ApiError from "../utils/ApiError.js";

// Helper to get local date string YYYY-MM-DD in IST
const getLocalDateString = (date = new Date()) => {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit"
  }).format(date);
};

export const checkInMember = async (memberId) => {
  const user = await User.findById(memberId);
  if (!user || !user.gymId) {
    throw new ApiError(404, "Member or associated gym not found");
  }

  const dateString = getLocalDateString();

  // Check if already checked in today
  const existingAttendance = await Attendance.findOne({ memberId, dateString });
  if (existingAttendance) {
    throw new ApiError(400, "Already checked in for today");
  }

  // Determine yesterday's date string for streak calculation
  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayString = getLocalDateString(yesterday);

  // Find yesterday's attendance
  const yesterdayAttendance = await Attendance.findOne({
    memberId,
    dateString: yesterdayString
  });

  const streakDays = yesterdayAttendance ? yesterdayAttendance.streakDays + 1 : 1;
  const checkInTime = new Date();

  const attendance = await Attendance.create({
    gymId: user.gymId,
    memberId,
    dateString,
    checkInTime,
    streakDays
  });

  return {
    isCheckedIn: true,
    checkInTime: attendance.checkInTime.toISOString(),
    streakDays: attendance.streakDays
  };
};

export const checkOutMember = async (memberId) => {
  const dateString = getLocalDateString();

  const attendance = await Attendance.findOne({ memberId, dateString });
  if (!attendance) {
    throw new ApiError(400, "No check-in record found for today");
  }

  if (attendance.checkOutTime) {
    throw new ApiError(400, "Already checked out for today");
  }

  attendance.checkOutTime = new Date();
  await attendance.save();

  return {
    isCheckedIn: false,
    checkOutTime: attendance.checkOutTime.toISOString()
  };
};
