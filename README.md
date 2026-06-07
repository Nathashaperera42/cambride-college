# Governess Full-Stack App

A complete auth + RBAC + CRUD stack:

- **Backend** — Node.js, Express, MongoDB/Mongoose, JWT, bcrypt
- **Frontend** — Flutter (Material 3), Riverpod, Dio, flutter_secure_storage, go_router

Two roles: **admin** (manages clients) and **client** (manages own profile).

---

## 1. Project Architecture

**Backend (layered):**

```
routes  ->  middleware (auth / role / validate)  ->  controllers  ->  services  ->  Mongoose models
```

- `config/`       MongoDB connection + env config
- `models/`       Mongoose `User` schema (password hashing, unique email, timestamps)
- `validations/`  express-validator rules for register / login / user CRUD
- `middleware/`   `auth` (JWT verify), `role` (RBAC), `validate`, `error` (central handler)
- `services/`     business logic (DB access, token issuing)
- `controllers/`  thin request/response handlers
- `routes/`       endpoint wiring
- `utils/`        JWT helpers, `ApiError`, admin seed script

**Frontend (clean architecture + Riverpod):**

```
screens  ->  providers (state)  ->  repositories (API calls)  ->  DioClient  ->  backend
```

- `core/network`    `DioClient` with token + error interceptors
- `core/services`   `StorageService` (secure JWT storage)
- `models/`         `UserModel`, `AuthResult`, `PaginatedUsers`
- `repositories/`   `AuthRepository`, `UserRepository`
- `providers/`      `authProvider` (auth state + auto-login), `userListProvider` (CRUD + search + pagination)
- `routes/`         `go_router` with redirect-based route protection
- `screens/`        auth, admin, client, profile

---

## 2. Backend Folder Structure

```
backend/
├── src/
│   ├── config/        db.js, index.js
│   ├── controllers/   authController, userController, profileController
│   ├── middleware/     auth, role, validate, error
│   ├── models/        User.js
│   ├── routes/        authRoutes, userRoutes, profileRoutes, index
│   ├── services/      authService, userService
│   ├── utils/         jwt, ApiError, seedAdmin
│   ├── validations/   authValidation, userValidation
│   └── app.js
├── server.js
├── .env.example
└── package.json
```

---

## STEP 1 — Install backend dependencies

```bash
cd backend
npm install
```

## STEP 2 — Setup MongoDB

Use a local server (`mongod`) or MongoDB Atlas. Local default URI:

```
mongodb://127.0.0.1:27017/governess
```

The unique-email index is created automatically from the schema on first run.

## STEP 3 — Configure .env

```bash
cp .env.example .env
```

Then edit `.env` and set a strong `JWT_SECRET` and your `MONGO_URI`.

## STEP 4 — Run backend

```bash
npm run dev          # auto-reload (nodemon)
# or
npm start            # plain node

# optional: create the first admin (admin@governess.lk / admin1234)
npm run seed:admin
```

Server runs at `http://localhost:5000`.

## STEP 5 — Install Flutter packages

```bash
cd ../flutter_app
flutter pub get
```

## STEP 6 — Configure API Base URL

Edit `lib/core/constants/api_constants.dart` -> `baseUrl`:

| Where you run the app      | baseUrl                        |
|----------------------------|--------------------------------|
| Android emulator           | `http://10.0.2.2:5000/api`     |
| iOS simulator / desktop    | `http://localhost:5000/api`    |
| Flutter web                | `http://localhost:5000/api`    |
| Real phone (same Wi-Fi)    | `http://<your-LAN-IP>:5000/api`|

## STEP 7 — Run Flutter app

```bash
flutter run
```

## STEP 8 — Test Register API

```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Jane Client","email":"jane@example.com","password":"secret123","confirmPassword":"secret123","role":"client"}'
```

Response:

```json
{
  "success": true,
  "message": "Registered successfully",
  "data": {
    "user": { "_id": "66b1...", "name": "Jane Client", "email": "jane@example.com", "role": "client", "createdAt": "...", "updatedAt": "..." },
    "token": "eyJhbGciOiJI..."
  }
}
```

## STEP 9 — Test Login API

```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"jane@example.com","password":"secret123"}'
```

Returns the same `{ user, token }` envelope. Save the token as `TOKEN`.

## STEP 10 — Test CRUD Operations

```bash
# List users (admin only) with pagination + search
curl "http://localhost:5000/api/users?page=1&limit=10&search=jane" \
  -H "Authorization: Bearer $TOKEN"

# Create a user (admin only)
curl -X POST http://localhost:5000/api/users \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"New User","email":"new@example.com","password":"secret123","role":"client"}'

# Update a user
curl -X PUT http://localhost:5000/api/users/<id> \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"Updated Name"}'

# Delete a user
curl -X DELETE http://localhost:5000/api/users/<id> \
  -H "Authorization: Bearer $TOKEN"

# Own profile
curl http://localhost:5000/api/profile -H "Authorization: Bearer $TOKEN"
curl -X PUT http://localhost:5000/api/profile \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"name":"My New Name"}'
```

Example error response (validation):

```json
{ "success": false, "message": "Password must be at least 8 characters" }
```

---

## API Endpoints

| Method | Path                  | Access          | Purpose                          |
|--------|-----------------------|-----------------|----------------------------------|
| POST   | /api/auth/register    | public          | Register (client/admin)          |
| POST   | /api/auth/login       | public          | Login, returns JWT               |
| POST   | /api/auth/logout      | authenticated   | Stateless logout                 |
| GET    | /api/users            | admin           | List + search + pagination       |
| POST   | /api/users            | admin           | Create user                      |
| GET    | /api/users/:id        | admin           | Get one                          |
| PUT    | /api/users/:id        | admin           | Update user                      |
| DELETE | /api/users/:id        | admin           | Delete user                      |
| GET    | /api/profile          | authenticated   | Own profile                      |
| PUT    | /api/profile          | authenticated   | Update own profile               |
| DELETE | /api/profile          | authenticated   | Delete own account               |

---

## Security notes

- The public Register screen exposes a role dropdown for demo convenience.
  In production, **remove the admin option** from registration and create
  admins only via `seed:admin` or an existing admin — otherwise anyone can
  self-register as admin.
- Always set a long, random `JWT_SECRET` and keep `.env` out of version control.
