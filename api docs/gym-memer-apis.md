# KavachX Gym Member APIs

> This file contains all API endpoints related to gym members (e.g., attendance).
> **Frontend Developer: Chetan Chaudhary**

## Base URL

```text
http://localhost:5000/api/v1
```

---

## Attendance System

All attendance endpoints require an authenticated `gym_member` user.

**POST** `http://localhost:5000/api/v1/attendance/check-in`
Authentication: Required (Bearer access token, Role: `gym_member`)
Body:
```json
{}
```
Description: Marks the member as checked in for the current local day at their assigned gym. Calculates consecutive streak days.

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "Checked in successfully",
  "data": {
    "isCheckedIn": true,
    "checkInTime": "2026-04-10T08:30:00.000Z",
    "streakDays": 6
  }
}
```

**Possible Errors:**
- `400 Bad Request`: Already checked in for today.
- `401 Unauthorized`: Missing or invalid token.
- `403 Forbidden`: User role is not `gym_member`.
- `404 Not Found`: Member or associated gym not found.

---

**POST** `http://localhost:5000/api/v1/attendance/check-out`
Authentication: Required (Bearer access token, Role: `gym_member`)
Body:
```json
{}
```
Description: Marks the member as checked out for the current local day. Requires a previous check-in on the same day.

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "Checked out successfully",
  "data": {
    "isCheckedIn": false,
    "checkOutTime": "2026-04-10T10:15:00.000Z"
  }
}
```

**Possible Errors:**
- `400 Bad Request`: No check-in record found for today.
- `400 Bad Request`: Already checked out for today.
- `401 Unauthorized`: Missing or invalid token.
- `403 Forbidden`: User role is not `gym_member`.

---

## Exercise Management

**PATCH** `http://localhost:5000/api/v1/exercises/:exerciseId/progress`
Authentication: Required (Bearer access token, Role: `gym_member`)
Body:
```json
{
  "completedSets": 3
}
```
Description: Updates the `completedSets` of a specific exercise assigned to the authenticated member for today's routine. It calculates if the exercise `isCompleted` based on the predefined `totalSets`.

**Expected Response (Success):**
```json
{
  "success": true,
  "message": "Exercise progress updated",
  "data": {
    "exerciseId": "661a2b3c4d5e6f7a8b9c0d1f",
    "completedSets": 3,
    "isCompleted": false
  }
}
```

**Possible Errors:**
- `400 Bad Request`: Validation error (e.g., negative sets) or attempting to update an exercise that is not part of today's routine.
- `401 Unauthorized`: Missing or invalid token.
- `403 Forbidden`: Attempting to update another member's exercise, or user role is not `gym_member`.
- `404 Not Found`: Exercise ID does not exist.
