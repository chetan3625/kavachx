# KavachX — AI Agent Development Guide

## 1. Project Overview

KavachX is a SaaS platform for gym owners and gym members.

The primary goal is to help gym owners:

- Manage gym members
- Track memberships
- Track attendance
- Manage monthly fee collection
- Identify expired and expiring memberships
- Reduce missed payments
- Communicate with inactive members
- Send SMS/email notifications
- Track gym revenue
- Generate reports
- Manage multiple gyms from a centralized system

Gym members can:

- View their membership
- Track attendance
- Track fitness progress
- View payment history
- Receive reminders
- Receive gym notifications

KavachX should be designed as a scalable multi-tenant SaaS application.

---

## 2. Backend Technology

The backend uses:

- Node.js
- Express.js
- MongoDB
- Mongoose
- JWT authentication
- bcryptjs
- REST APIs
- Nodemailer
- Cloudinary
- Multer
- node-cron

Development:

- Nodemon
- ESLint when introduced
- Prettier when introduced

---

## 3. Architecture

Use a modular MVC/service architecture.

Recommended structure:

server/
│
├── config/
├── controllers/
│   ├── auth/
│   ├── gym/
│   ├── gymers/
│   ├── memberships/
│   ├── payments/
│   ├── attendance/
│   ├── notifications/
│   └── reports/
│
├── middleware/
├── models/
├── routes/
├── services/
├── utils/
├── validators/
├── jobs/
├── templates/
├── uploads/
│
├── server.js
├── app.js
├── package.json
└── .env

---

## 4. Core Domain Entities

The application will eventually contain entities such as:

- User
- Gym
- GymMember
- Membership
- MembershipPlan
- Payment
- Attendance
- Notification
- FitnessProfile
- FitnessProgress
- Workout
- Exercise
- Invoice
- Subscription
- Staff
- Role
- AuditLog

Do not create unnecessary models.

Before creating a new model, check whether the existing domain model can represent the requirement.

---

## 5. Multi-Tenant Architecture

KavachX is a SaaS application.

A gym owner must only be able to access data belonging to their gym.

Every gym-specific resource should be associated with a `gymId`.

Example:

```js
{
  gymId: ObjectId,
  name: "John Doe",
  phone: "XXXXXXXXXX"
}