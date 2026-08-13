import User from "../../models/User.js";
import Attendance from "../../models/Attendance.js";
import Exercise from "../../models/Exercise.js";
import WorkoutLog from "../../models/WorkoutLog.js";
import Membership from "../../models/Membership.js";
import MembershipPlan from "../../models/MembershipPlan.js";
import Notification from "../../models/Notification.js";
import Gym from "../../models/Gym.js";
import { uploadBufferToCloudinary } from "../../utils/cloudinary.js";

// Helper: Format date to YYYY-MM-DD
const getTodayDateStr = () => new Date().toISOString().split("T")[0];

// Helper: Get Monday to Sunday date strings for current week
const getCurrentWeekDates = () => {
  const now = new Date();
  const dayOfWeek = now.getDay();
  const distanceToMon = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
  const monday = new Date(now);
  monday.setDate(now.getDate() + distanceToMon);

  const dates = [];
  for (let i = 0; i < 7; i++) {
    const d = new Date(monday);
    d.setDate(monday.getDate() + i);
    dates.push(d.toISOString().split("T")[0]);
  }
  return dates;
};

// GET /api/v1/members/dashboard/summary
export const getDashboardSummary = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const todayStr = getTodayDateStr();

    // 1. Fetch member user profile
    const user = await User.findById(userId);
    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    // 2. Check attendance status for today
    const todayAttendance = await Attendance.findOne({
      memberId: userId,
      $or: [{ dateStr: todayStr }, { dateString: todayStr }],
    });

    const isCheckedIn = todayAttendance?.status === "checked_in";
    const hasCompletedTodayAttendance =
      todayAttendance?.status === "checked_out";

    // 3. Dynamic Weekly Activity calculation (Mon - Sun)
    const weekDates = getCurrentWeekDates();
    const weeklyAttendances = await Attendance.find({
      memberId: userId,
      $or: [
        { dateStr: { $in: weekDates } },
        { dateString: { $in: weekDates } },
      ],
    });

    const attendedDateSet = new Set(
      weeklyAttendances.map((a) => a.dateStr || a.dateString),
    );
    const weeklyActivity = weekDates.map((dStr) => attendedDateSet.has(dStr));

    // 4. Calculate streak days dynamically
    const allAttendances = await Attendance.find({ memberId: userId })
      .sort({ createdAt: -1 })
      .select("dateStr dateString");
    const uniqueDates = [
      ...new Set(
        allAttendances.map((a) => a.dateStr || a.dateString).filter(Boolean),
      ),
    ];

    let streakDays = 0;
    let checkDate = new Date();
    for (let i = 0; i < 30; i++) {
      const dStr = checkDate.toISOString().split("T")[0];
      if (uniqueDates.includes(dStr)) {
        streakDays++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else if (i === 0) {
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    // 5. Fetch exercises for today (pure dynamic from DB)
    const exercises = await Exercise.find({
      memberId: userId,
      dateStr: todayStr,
    });

    // 6. Fetch workout log if present
    const workoutLog = await WorkoutLog.findOne({
      memberId: userId,
      dateStr: todayStr,
    });

    return res.status(200).json({
      success: true,
      data: {
        isCheckedIn,
        hasCompletedTodayAttendance,
        streakDays: streakDays || user.streakDays || 0,
        todayTargetPart:
          workoutLog?.targetPart || user.todayTargetPart || "Chest & Triceps",
        waterLitres: user.waterLitres ?? 2.5,
        targetWaterLitres: user.targetWaterLitres ?? 4.0,
        currentWeightKg: user.currentWeightKg ?? 74.5,
        targetWeightKg: user.targetWeightKg ?? 70.0,
        totalDurationMinutes:
          workoutLog?.totalDurationMinutes ||
          exercises.reduce((sum, e) => sum + (e.durationMinutes || 0), 0),
        caloriesBurned: workoutLog?.caloriesBurned || 300,
        weeklyActivity,
        exercises: exercises.map((ex) => ({
          id: ex._id.toString(),
          name: ex.name,
          muscleGroup: ex.muscleGroup,
          weightInKg: ex.weightInKg,
          repsPerSet: ex.repsPerSet,
          totalSets: ex.totalSets,
          completedSets: ex.completedSets,
          durationMinutes: ex.durationMinutes || 15,
          notes: ex.notes || "",
        })),
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/members/check-in (STRICT 1 PER DAY)
export const memberCheckIn = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { dateStr } = req.body || {};
    const checkInDateStr = dateStr || getTodayDateStr();

    // Check if attendance record already exists for today
    const existingAttendance = await Attendance.findOne({
      memberId: userId,
      $or: [{ dateStr: checkInDateStr }, { dateString: checkInDateStr }],
    });

    if (existingAttendance) {
      if (existingAttendance.status === "checked_in") {
        return res.status(400).json({
          success: false,
          message: "You are already checked in for today!",
        });
      } else if (existingAttendance.status === "checked_out") {
        return res.status(400).json({
          success: false,
          message:
            "You have already completed your check-in and check-out for today!",
        });
      }
    }

    const user = await User.findById(userId);
    const gymId = user?.gymId || null;

    const attendance = await Attendance.create({
      memberId: userId,
      gymId,
      checkInTime: new Date(),
      dateStr: checkInDateStr,
      dateString: checkInDateStr,
      status: "checked_in",
    });

    return res.status(200).json({
      success: true,
      message: "Checked in successfully",
      data: {
        isCheckedIn: true,
        dateStr: checkInDateStr,
        checkInTime: attendance.checkInTime,
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/members/check-out
export const memberCheckOut = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const todayStr = getTodayDateStr();

    const attendance = await Attendance.findOneAndUpdate(
      {
        memberId: userId,
        status: "checked_in",
        $or: [{ dateStr: todayStr }, { dateString: todayStr }],
      },
      { checkOutTime: new Date(), status: "checked_out" },
      { returnDocument: "after" },
    );

    if (!attendance) {
      // Fallback update any active checked_in attendance
      await Attendance.findOneAndUpdate(
        { memberId: userId, status: "checked_in" },
        { checkOutTime: new Date(), status: "checked_out" },
        { returnDocument: "after" },
      );
    }

    return res.status(200).json({
      success: true,
      message: "Checked out successfully",
      data: {
        isCheckedIn: false,
        hasCompletedTodayAttendance: true,
        checkOutTime: new Date(),
      },
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/members/exercises - Create new exercise in workout routine
export const createExercise = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const {
      name,
      muscleGroup,
      weightInKg,
      repsPerSet,
      totalSets,
      completedSets,
      durationMinutes,
      notes,
      dateStr,
    } = req.body;

    if (!name || !muscleGroup) {
      return res.status(400).json({
        success: false,
        message: "Exercise name and muscle group are required",
      });
    }

    const exercise = await Exercise.create({
      memberId: userId,
      name,
      muscleGroup,
      weightInKg: parseFloat(weightInKg) || 0,
      repsPerSet: parseInt(repsPerSet, 10) || 10,
      totalSets: parseInt(totalSets, 10) || 4,
      completedSets: parseInt(completedSets, 10) || 0,
      durationMinutes: parseInt(durationMinutes, 10) || 15,
      notes: notes || "",
      dateStr: dateStr || getTodayDateStr(),
    });

    return res.status(201).json({
      success: true,
      message: "Exercise added successfully",
      data: {
        id: exercise._id.toString(),
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        weightInKg: exercise.weightInKg,
        repsPerSet: exercise.repsPerSet,
        totalSets: exercise.totalSets,
        completedSets: exercise.completedSets,
        durationMinutes: exercise.durationMinutes,
        notes: exercise.notes,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/exercises - Fetch exercises for date
export const getExercises = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const targetDateStr = req.query.dateStr || getTodayDateStr();

    const exercises = await Exercise.find({
      memberId: userId,
      dateStr: targetDateStr,
    });

    return res.status(200).json({
      success: true,
      data: exercises.map((ex) => ({
        id: ex._id.toString(),
        name: ex.name,
        muscleGroup: ex.muscleGroup,
        weightInKg: ex.weightInKg,
        repsPerSet: ex.repsPerSet,
        totalSets: ex.totalSets,
        completedSets: ex.completedSets,
        durationMinutes: ex.durationMinutes,
        notes: ex.notes,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/members/profile
export const updateProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const updateData = {};

    const fields = [
      "name",
      "phone",
      "dateOfBirth",
      "gender",
      "emergencyContact",
      "bloodGroup",
      "address",
      "fitnessGoal",
      "medicalConditions",
      "currentWeightKg",
      "targetWeightKg",
      "targetWaterLitres",
      "height",
      "heightCm",
      "todayTargetPart",
    ];

    fields.forEach((field) => {
      if (req.body[field] !== undefined) {
        updateData[field] = req.body[field];
      }
    });

    // Normalize gender to lowercase to match Mongoose schema enum ['male', 'female', 'other', '']
    if (typeof updateData.gender === "string") {
      updateData.gender = updateData.gender.toLowerCase().trim();
    }

    // Sync height / heightCm aliases
    if (req.body.heightCm !== undefined) {
      updateData.height = req.body.heightCm;
    }

    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updateData },
      { new: true, runValidators: true },
    )
      .select("-password")
      .populate("gymId", "name phone address");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    return res.status(200).json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/members/exercises/:id - Update exercise details
export const updateExercise = async (req, res, next) => {
  try {
    const { id } = req.params;
    const {
      name,
      muscleGroup,
      weightInKg,
      repsPerSet,
      totalSets,
      completedSets,
      durationMinutes,
      notes,
    } = req.body;

    const updateFields = {};
    if (name !== undefined) updateFields.name = name;
    if (muscleGroup !== undefined) updateFields.muscleGroup = muscleGroup;
    if (weightInKg !== undefined)
      updateFields.weightInKg = parseFloat(weightInKg);
    if (repsPerSet !== undefined)
      updateFields.repsPerSet = parseInt(repsPerSet, 10);
    if (totalSets !== undefined)
      updateFields.totalSets = parseInt(totalSets, 10);
    if (completedSets !== undefined)
      updateFields.completedSets = parseInt(completedSets, 10);
    if (durationMinutes !== undefined)
      updateFields.durationMinutes = parseInt(durationMinutes, 10);
    if (notes !== undefined) updateFields.notes = notes;

    const exercise = await Exercise.findByIdAndUpdate(id, updateFields, {
      returnDocument: "after",
    });
    if (!exercise) {
      return res
        .status(404)
        .json({ success: false, message: "Exercise not found" });
    }

    return res.status(200).json({
      success: true,
      message: "Exercise updated",
      data: {
        id: exercise._id.toString(),
        name: exercise.name,
        muscleGroup: exercise.muscleGroup,
        weightInKg: exercise.weightInKg,
        repsPerSet: exercise.repsPerSet,
        totalSets: exercise.totalSets,
        completedSets: exercise.completedSets,
        durationMinutes: exercise.durationMinutes,
        notes: exercise.notes,
      },
    });
  } catch (error) {
    next(error);
  }
};

// DELETE /api/v1/members/exercises/:id - Delete exercise
export const deleteExercise = async (req, res, next) => {
  try {
    const { id } = req.params;
    const userId = req.user.userId;

    if (id === "all") {
      const todayStr = getTodayDateStr();
      await Exercise.deleteMany({ memberId: userId, dateStr: todayStr });
      return res.status(200).json({
        success: true,
        message: "All exercises deleted successfully",
      });
    }

    const exercise = await Exercise.findOneAndDelete({
      _id: id,
      memberId: userId,
    });
    if (!exercise) {
      await Exercise.findByIdAndDelete(id);
    }

    return res.status(200).json({
      success: true,
      message: "Exercise deleted successfully",
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/members/workout-summary - Save daily workout log summary
export const logWorkoutSummary = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { targetPart, totalDurationMinutes, caloriesBurned, notes, dateStr } =
      req.body;
    const targetDateStr = dateStr || getTodayDateStr();

    const workoutLog = await WorkoutLog.findOneAndUpdate(
      { memberId: userId, dateStr: targetDateStr },
      {
        memberId: userId,
        targetPart: targetPart || "Chest & Triceps",
        totalDurationMinutes: parseInt(totalDurationMinutes, 10) || 45,
        caloriesBurned: parseInt(caloriesBurned, 10) || 300,
        notes: notes || "",
        dateStr: targetDateStr,
      },
      { upsert: true, returnDocument: "after" },
    );

    if (targetPart) {
      await User.findByIdAndUpdate(userId, { todayTargetPart: targetPart });
    }

    return res.status(200).json({
      success: true,
      message: "Workout summary logged successfully",
      data: workoutLog,
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/members/hydration
export const updateHydration = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { waterLitres } = req.body;

    const user = await User.findByIdAndUpdate(
      userId,
      { waterLitres: parseFloat(waterLitres) || 0 },
      { returnDocument: "after" },
    );

    return res.status(200).json({
      success: true,
      data: {
        waterLitres: user.waterLitres,
      },
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/members/exercises/:exerciseId/progress
export const updateExerciseProgress = async (req, res, next) => {
  try {
    const { exerciseId } = req.params;
    const { completedSets } = req.body;

    const exercise = await Exercise.findByIdAndUpdate(
      exerciseId,
      { completedSets: parseInt(completedSets, 10) },
      { returnDocument: "after" },
    );

    if (!exercise) {
      return res
        .status(404)
        .json({ success: false, message: "Exercise not found" });
    }

    return res.status(200).json({
      success: true,
      data: {
        id: exercise._id.toString(),
        completedSets: exercise.completedSets,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/subscription/current
export const getCurrentSubscription = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const membership = await Membership.findOne({
      memberId: userId,
      status: "active",
    }).populate("gymId", "name");

    if (membership) {
      return res.status(200).json({
        success: true,
        data: {
          id: membership._id.toString(),
          planName: membership.planName || "Active Membership",
          price: membership.price || 0,
          durationInMonths: membership.durationInMonths || 1,
          startDate: membership.createdAt || membership.joinedAt || new Date(),
          endDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
          status: membership.status || "active",
          features: membership.features || [
            "Gym Equipment Access",
            "Locker Room",
            "Trainer Assistance",
          ],
        },
      });
    }

    return res.status(200).json({
      success: true,
      data: null,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/plans
export const getAvailablePlans = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    let enrolledGymId = null;

    if (userId) {
      const user = await User.findById(userId).select("gymId");
      if (user && user.gymId) {
        enrolledGymId = user.gymId;
      } else {
        const membership = await Membership.findOne({
          memberId: userId,
        }).select("gymId");
        if (membership && membership.gymId) {
          enrolledGymId = membership.gymId;
          await User.findByIdAndUpdate(userId, { gymId: enrolledGymId });
        } else {
        }
      }
    }

    let plans = [];
    if (enrolledGymId) {
      plans = await MembershipPlan.find({ gymId: enrolledGymId }).sort({
        price: 1,
      });
    }

    if (!plans || plans.length === 0) {
      plans = await MembershipPlan.find({}).sort({ price: 1 });
    }

    return res.status(200).json({
      success: true,
      data: plans.map((plan) => ({
        id: plan._id.toString(),
        name: plan.name,
        price: plan.price,
        durationInMonths: plan.durationInMonths,
        features: plan.features,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// POST /api/v1/members/subscription/subscribe
export const subscribeToPlan = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const { planId, paymentMethod, amount } = req.body;

    const plan = await MembershipPlan.findById(planId);

    if (userId && plan) {
      await Membership.findOneAndUpdate(
        { memberId: userId, gymId: plan.gymId },
        {
          memberId: userId,
          gymId: plan.gymId,
          planName: plan.name,
          price: plan.price,
          durationInMonths: plan.durationInMonths,
          features: plan.features,
          status: "active",
          joinedAt: new Date(),
        },
        { upsert: true, returnDocument: "after" },
      );

      await User.findByIdAndUpdate(userId, { gymId: plan.gymId });
    }

    return res.status(200).json({
      success: true,
      message: "Subscribed successfully",
      data: {
        id: `sub_${Date.now()}`,
        planId,
        paymentMethod,
        amount: amount || plan?.price || 0,
        status: "active",
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/profile
export const getProfile = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId)
      .select("-password")
      .populate("gymId", "name phone address");

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found" });
    }

    return res.status(200).json({ success: true, data: user });
  } catch (error) {
    next(error);
  }
};

// PUT /api/v1/members/profile/image
export const uploadProfileImage = async (req, res, next) => {
  try {
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: "No image file provided" });
    }

    const userId = req.user.userId;
    const uploadResult = await uploadBufferToCloudinary(
      req.file.buffer,
      "kavachx/profiles",
    );

    const user = await User.findByIdAndUpdate(
      userId,
      { profileImage: uploadResult.secure_url },
      { new: true },
    );

    return res.status(200).json({
      success: true,
      profileImage: user.profileImage,
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/attendance/history
export const getAttendanceHistory = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const attendances = await Attendance.find({ memberId: userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const totalCount = await Attendance.countDocuments({ memberId: userId });

    const data = attendances.map((record) => {
      let durationMinutes = 0;
      if (record.checkInTime && record.checkOutTime) {
        durationMinutes = Math.round(
          (new Date(record.checkOutTime) - new Date(record.checkInTime)) /
            60000,
        );
      }
      return {
        ...record.toObject(),
        durationMinutes,
      };
    });

    return res.status(200).json({
      success: true,
      data,
      totalCount,
      page,
      totalPages: Math.ceil(totalCount / limit),
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/attendance/stats
export const getAttendanceStats = async (req, res, next) => {
  try {
    const userId = req.user.userId;

    const now = new Date();
    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const attendances = await Attendance.find({
      memberId: userId,
      createdAt: { $gte: startOfMonth },
    });

    let totalDurationMinutes = 0;
    let completedSessions = 0;

    attendances.forEach((record) => {
      if (record.checkInTime && record.checkOutTime) {
        totalDurationMinutes += Math.round(
          (new Date(record.checkOutTime) - new Date(record.checkInTime)) /
            60000,
        );
        completedSessions++;
      }
    });

    const averageDurationMinutes =
      completedSessions > 0
        ? Math.round(totalDurationMinutes / completedSessions)
        : 0;

    const user = await User.findById(userId).select("streakDays");

    return res.status(200).json({
      success: true,
      data: {
        totalDaysAttended: attendances.length,
        averageDurationMinutes,
        longestStreak: user?.streakDays || 0,
      },
    });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/notifications
export const getNotifications = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const notifications = await Notification.find({ userId })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const totalCount = await Notification.countDocuments({ userId });
    const unreadCount = await Notification.countDocuments({
      userId,
      isRead: false,
    });

    return res.status(200).json({
      success: true,
      data: notifications,
      unreadCount,
      totalCount,
      page,
      totalPages: Math.ceil(totalCount / limit),
    });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/members/notifications/:id/read
export const markNotificationRead = async (req, res, next) => {
  try {
    const { id } = req.params;
    const notification = await Notification.findByIdAndUpdate(
      id,
      { isRead: true },
      { new: true },
    );

    if (!notification) {
      return res
        .status(404)
        .json({ success: false, message: "Notification not found" });
    }

    return res.status(200).json({ success: true, data: notification });
  } catch (error) {
    next(error);
  }
};

// PATCH /api/v1/members/notifications/read-all
export const markAllNotificationsRead = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    await Notification.updateMany({ userId, isRead: false }, { isRead: true });

    return res
      .status(200)
      .json({ success: true, message: "All notifications marked as read" });
  } catch (error) {
    next(error);
  }
};

// GET /api/v1/members/gym
export const getGymDetails = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const user = await User.findById(userId);

    if (!user || !user.gymId) {
      return res
        .status(404)
        .json({ success: false, message: "No gym associated with this user" });
    }

    const gym = await Gym.findById(user.gymId);
    if (!gym) {
      return res.status(404).json({ success: false, message: "Gym not found" });
    }

    return res.status(200).json({ success: true, data: gym });
  } catch (error) {
    next(error);
  }
};
