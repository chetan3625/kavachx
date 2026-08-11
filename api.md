# KavachX API

> This file contains all API endpoints and their function to integrate with frontend.
> **Frontend Developer: Chetan Chaudhary**

## Base URL

```text
http://localhost:5000/api/v1
```

---

# Auth & Gym APIs

Base URL: `http://localhost:5000/api/v1`

All responses are JSON. Refresh tokens are sent/received via HttpOnly cookie where applicable.

---

**POST** /auth/register-owner
Authentication: No
Body:
```json
{
  "name": "Gym Owner",
  "email": "owner@gmail.com",
  "phone": "9876543210",
  "password": "password123",
  "gymName": "Kavach Fitness",
  "gymPhone": "9876543210",
  "gymAddress": "Nashik, Maharashtra"
}
```
Description: Register a gym owner, create a Gym, and return gym join token/URL.

---

**POST** /auth/register-member
Authentication: No
Body:
```json
{
  "name": "Rahul Patil",
  "email": "rahul@gmail.com",
  "phone": "9876543210",
  "password": "password123"
}
```
Description: Register a gym member (no gym assigned). Client must not send `role`, `gymId`, or `ownerId`.

---

**POST** /auth/login
Authentication: No
Body:
```json
{
  "email": "user@gmail.com",
  "password": "password123"
}
```
Description: Login (owners and members). Returns `user` (includes `role`) and `accessToken`.

---

**POST** /auth/refresh
Authentication: No (uses refresh cookie)
Body: `{}`
Description: Issue new access token using HttpOnly refresh cookie.

---

**POST** /auth/logout
Authentication: Required (Bearer access token)
Body: `{}`
Description: Logout and clear refresh cookie.

---

**GET** /auth/me
Authentication: Required (Bearer access token)
Body: `{}`
Description: Get current authenticated user.

---

## Gym Join & Membership

**POST** /gyms/join-request
Authentication: Required (Bearer access token)
Body:
```json
{
  "gymToken": "SECURE_GYM_TOKEN"
}
```
Description: Authenticated `gym_member` requests to join a gym. Creates a pending join request; does not add membership.

---

**GET** /gyms/join-requests
Authentication: Required (Bearer access token)
Description: Authenticated `gym_owner` retrieves pending join requests for their gym(s).

---

**PATCH** /gyms/join-requests/:requestId/approve
Authentication: Required (Bearer access token)
Description: Gym owner approves a specific join request. Creates a `Membership` (member is not added until approval).

---

**PATCH** /gyms/join-requests/:requestId/reject
Authentication: Required (Bearer access token)
Description: Gym owner rejects a specific join request.

