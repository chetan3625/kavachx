
### `CLAUDE.md`

```md
# KavachX — Claude Instructions

## Project

KavachX is a multi-tenant SaaS gym management platform.

It connects:

- Gym owners
- Gym members

The system manages:

- Members
- Memberships
- Payments
- Attendance
- Notifications
- Fitness progress
- Reports
- Gym operations

The backend is built with:

- Node.js
- Express.js
- MongoDB
- Mongoose
- JWT
- bcryptjs

---

# Primary Development Rules

## 1. Inspect Before Editing

Before changing code:

- Inspect the existing file.
- Inspect related models.
- Inspect related routes.
- Inspect related controllers.
- Inspect services and middleware.
- Understand existing conventions.

Do not assume the architecture.

---

## 2. Keep Controllers Thin

Use:

```text
Route
 ↓
Middleware
 ↓
Controller
 ↓
Service
 ↓
Model