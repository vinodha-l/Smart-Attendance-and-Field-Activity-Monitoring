# Student 1: Mobile application integration

Student 1 owns the Android Flutter app: OTP login, Tamil and English user interface, GPS and selfie attendance, photo evidence, offline SQLite queue, tasks, history and profile.

## How the modules connect

| Student | Integration with the mobile app |
|---|---|
| 2 — FastAPI | Provide `/auth/otp/request`, `/auth/otp/verify`, `/tasks/today`, `/attendance`, and `/activities`. OTP verify returns the same JWT and worker profile structure as password login. |
| 3 — Database/auth | Store registered phone numbers, worker profiles, tokens and stable worker/task/record identifiers. |
| 4 — Face AI | Receive attendance selfie plus worker ID and return face-verification status, confidence and reason. |
| 5 — GPS/GIS | Provide assigned site latitude, longitude, radius/polygon and geofence rules. The app sends latitude, longitude, accuracy and capture time. |
| 6 — Dashboard | Read the same attendance/activity records from the backend database; no direct mobile-to-dashboard connection is needed. |

## OTP contract

`POST /auth/otp/request` accepts `{ "phone_number": "+919876543210" }` and sends an SMS without returning the OTP. `POST /auth/otp/verify` accepts the phone number and OTP, and returns `access_token`, `expires_in`, and `worker`.

Android OTP autofill is enabled in the UI. Fully automatic retrieval needs an SMS Retriever-compatible SMS containing the Android app hash; Student 2's OTP provider must supply it. No SMS-read permission is required.

## Demo

1. Run FastAPI and Flutter with `--dart-define=API_BASE_URL=http://YOUR_LAN_IP:8000/api/v1`.
2. Sign in with a registered mobile number and OTP.
3. Mark attendance: allow GPS, take selfie, submit geofence status.
4. Report a field activity with a rear-camera photo.
5. Turn off the network, submit another record, show it in Sync Queue, restore network and tap Sync now.
6. Show History, Tamil language switch, then the shared Supervisor dashboard.
