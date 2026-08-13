import User from "../../models/User.js";

// POST /api/v1/members/onboarding
export const completeOnboarding = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const {
      age,
      height,
      currentWeightKg,
      targetWeightKg,
      targetWaterLitres,
      gender,
      fitnessGoal,
      waterIntakeReminder,
      waterReminderIntervalHours,
    } = req.body;

    const updateData = { isOnboarded: true };

    if (age !== undefined) updateData.age = age;
    if (height !== undefined) updateData.height = height;
    if (currentWeightKg !== undefined)
      updateData.currentWeightKg = currentWeightKg;
    if (targetWeightKg !== undefined)
      updateData.targetWeightKg = targetWeightKg;
    if (targetWaterLitres !== undefined)
      updateData.targetWaterLitres = targetWaterLitres;

    // Normalize gender to lowercase to match Mongoose schema enum ['male', 'female', 'other', '']
    if (gender !== undefined && typeof gender === "string") {
      updateData.gender = gender.toLowerCase().trim();
    }

    if (fitnessGoal !== undefined) updateData.fitnessGoal = fitnessGoal;
    if (waterIntakeReminder !== undefined)
      updateData.waterIntakeReminder = waterIntakeReminder;
    if (waterReminderIntervalHours !== undefined)
      updateData.waterReminderIntervalHours = waterReminderIntervalHours;

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true },
    ).select("-password");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Onboarding completed successfully",
      data: user,
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/members/fcm-token
export const updateFcmToken = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res
        .status(400)
        .json({ success: false, message: "FCM token is required" });
    }

    await User.findByIdAndUpdate(userId, { fcmToken });

    return res
      .status(200)
      .json({ success: true, message: "FCM token updated" });
  } catch (error) {
    next(error);
  }
};
