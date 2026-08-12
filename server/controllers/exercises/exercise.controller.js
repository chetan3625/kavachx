import asyncHandler from "../../utils/AsyncHandler.js";
import { updateExerciseProgress } from "../../services/exercise.service.js";

export const updateProgress = asyncHandler(async (req, res) => {
  const { exerciseId } = req.params;
  const { completedSets } = req.body;
  
  const data = await updateExerciseProgress(req.user.userId, exerciseId, completedSets);
  
  res.status(200).json({
    success: true,
    message: "Exercise progress updated",
    data
  });
});
