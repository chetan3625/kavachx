import Exercise from "../models/Exercise.js";
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

export const updateExerciseProgress = async (memberId, exerciseId, completedSets) => {
  const exercise = await Exercise.findById(exerciseId);

  if (!exercise) {
    throw new ApiError(404, "Exercise not found");
  }

  // Ensure member is updating their own exercise
  if (exercise.memberId.toString() !== memberId.toString()) {
    throw new ApiError(403, "You do not have permission to update this exercise");
  }

  // Ensure updating today's routine
  const todayString = getLocalDateString();
  if (exercise.dateString !== todayString) {
    throw new ApiError(400, "You can only update progress for today's routine");
  }

  exercise.completedSets = completedSets;
  exercise.isCompleted = completedSets >= exercise.totalSets;

  await exercise.save();

  return {
    exerciseId: exercise._id,
    completedSets: exercise.completedSets,
    isCompleted: exercise.isCompleted
  };
};
