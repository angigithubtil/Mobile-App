# Employee Shift Management

Employee Shift Management is a Flutter + Node.js application for handling employee scheduling, shift assignment, and attendance tracking.

## Tech Stack

- Frontend: Flutter
- Backend: Node.js + Express
- Database: MongoDB (with local/mock fallback behavior in backend)

## Current Features

- Login flow with role-based navigation (Admin / Employee)
- Admin employee management
- Admin shift assignment, update, and delete
- Employee shift calendar view
- Employee clock in / clock out
- Attendance views for admin and employee dashboards
- UI theme for a cleaner, responsive experience

## Project Structure

- `frontend/` Flutter app
- `backend/` Node.js API

## Setup

### 1. Backend

```powershell
cd backend
npm.cmd install
npm.cmd start
```

Backend runs on `http://localhost:3000` and API routes are served under `/api`.

### 2. Frontend

```powershell
cd frontend
flutter.bat pub get
flutter.bat run -d windows
```

You can also run on Chrome:

```powershell
flutter.bat run -d chrome
```

## Environment Variables (Backend)

Create/update `backend/.env`:

```env
MONGO_URI=<your-atlas-or-mongo-uri>
MONGO_URI_FALLBACK=mongodb://127.0.0.1:27017/employee_shift_management
MOCK_DB=false
PORT=3000
NODE_ENV=dev
```

Notes:

- If MongoDB is unavailable, backend starts but protected API endpoints can return `503` until DB is reachable.
- For full functionality, use a reachable MongoDB instance.

## Testing and Health

- Flutter toolchain check:

```powershell
cd frontend
flutter.bat doctor -v
```

```powershell
curl http://localhost:3000/api/employees
```

## Recent Completed Work

- Fixed backend startup and DB bootstrap flow
- Added safer DB connection fallback handling
- Fixed frontend/backend API contract mismatches for shift and employee operations
- Improved admin and login UI consistency
- Added shared Flutter app theme

