# UPI Scam Analyzer — Final Year Project

A scam-detection project with **two separate frontends** sharing the same
backend and Firebase project — a Flutter mobile app, and a standalone React
website with its own UI:
- **Email OTP + password signup**, then **password login**
- **Message analyzer** — scans SMS/WhatsApp/email text for scam patterns
- **UPI ID checker** — flags suspicious/invalid UPI handles
- **URL analyzer** — flags phishing-style links
- **Scan history** per user (Firestore)

```
upi-scam-analyzer/
├── backend-otp-server/   Node/Express server — sends & verifies email OTPs
├── flutter_app/           Flutter mobile app (Android/iOS)
├── web_app/               Standalone React website (its own UI, not Flutter web)
└── firestore.rules       Security rules (each user sees only their own scans)
```

Both `flutter_app` and `web_app` are independent frontends that talk to the
**same Firebase project** (so a user's login and scan history are shared
between the app and the website) and the **same OTP server**. The scam-
scoring rules are duplicated in each (`analyzer_service.dart` and
`analyzer.js`) so both work fully offline with no shared backend needed for
that part — just keep the two files in sync if you change the scoring logic.

---

## 0. Before you start

You'll need, on your own machine:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed (`flutter doctor` should pass)
- [Node.js](https://nodejs.org) 18+ installed
- A free [Firebase](https://console.firebase.google.com) account
- A Gmail account with an **App Password** (not your normal password) —
  generate one at https://myaccount.google.com/apppasswords (requires
  2-Step Verification turned on)

**Never paste your real Gmail app password or Firebase keys into a chat
with anyone, including an AI.** Put them only in the `.env` file on your
own computer, described below.

---

## 1. Set up the OTP email server

```bash
cd backend-otp-server
npm install
cp .env.example .env
```

Open `.env` and fill in:
```
EMAIL_USER=your_gmail_address@gmail.com
EMAIL_PASS=your_16_character_app_password
```

Run it:
```bash
npm start
```
You should see `OTP server running on http://localhost:4000`.
Test it's alive: open http://localhost:4000/health in a browser.

---

## 2. Set up Firebase (used by BOTH frontends)

1. Go to the [Firebase console](https://console.firebase.google.com) → **Add project**.
2. In the project, enable:
   - **Authentication** → Sign-in method → **Email/Password** → Enable
   - **Firestore Database** → Create database (start in test mode is fine while developing)
3. In Firestore, go to the **Rules** tab and paste the contents of `firestore.rules` from this folder, then Publish.
4. Register a **Web app** in Project settings → General → "Your apps" → `</>` icon.
   You'll get a `firebaseConfig` object — you need these same values for
   both the Flutter web platform and the React app below.

---

## 3. Set up the Flutter mobile app

```bash
cd flutter_app
flutter create .          # generates android/ios/web platform folders
                           # (safe — it will NOT overwrite your lib/ or pubspec.yaml)
flutter pub get

dart pub global activate flutterfire_cli
firebase login
flutterfire configure     # pick the Firebase project you just made,
                           # select Android + iOS
```

`flutterfire configure` overwrites `lib/firebase_options.dart` with your
real project's keys — that's expected and correct.

Point it at your OTP server — open `flutter_app/lib/services/otp_api_service.dart`
and check `baseUrl`:

| Running on...                    | Use this baseUrl               |
|-----------------------------------|----------------------------------|
| Android emulator                  | `http://10.0.2.2:4000`          |
| Physical phone / deployed server  | `http://YOUR_COMPUTER_IP:4000`  |

Run it:
```bash
# with backend-otp-server (step 1) running in another terminal
flutter run
```

---

## 4. Set up the React website (separate from the Flutter app)

```bash
cd web_app
npm install
cp .env.example .env
```

Open `.env` and fill in the same Firebase **web app** config from step 2.4,
plus where your OTP server runs:
```
VITE_FIREBASE_API_KEY=...
VITE_FIREBASE_AUTH_DOMAIN=...
VITE_FIREBASE_PROJECT_ID=...
VITE_FIREBASE_STORAGE_BUCKET=...
VITE_FIREBASE_MESSAGING_SENDER_ID=...
VITE_FIREBASE_APP_ID=...
VITE_OTP_API_BASE=http://localhost:4000
```

Run it:
```bash
# with backend-otp-server (step 1) running in another terminal
npm run dev        # opens a dev server, usually http://localhost:5173
npm run build       # produces the deployable site in web_app/dist
```

---

## How the signup flow works

1. User enters email + password on **Sign Up** → app calls `POST /api/send-otp` on the Node server.
2. Server generates a 6-digit code, emails it via Gmail SMTP, stores it in memory for 5 minutes.
3. User enters the code on the **OTP screen** → app calls `POST /api/verify-otp`.
4. Only if that succeeds does the app call Firebase's `createUserWithEmailAndPassword` — so the account is only created once the email is confirmed real.
5. From then on, **Login** just uses Firebase email/password directly (no OTP needed again).

## Where the "AI" scam analysis lives

- Flutter: `flutter_app/lib/services/analyzer_service.dart`
- React: `web_app/src/services/analyzer.js`

Both are the same transparent, rule/keyword-based scoring engine (message
keywords, UPI ID pattern checks, URL heuristics like shorteners/IP
links/hyphen count), just written twice — once in Dart, once in JS — so
neither frontend needs the other to be running. It's deliberately not a
black-box model so:
- it always works with zero setup (no model file, no GPU, no server call)
- you can explain every score in your project viva/demo
- you can swap in a trained scikit-learn/NLP model later behind the same
  interface if your course wants a real ML component — just update both files

## Known limitations (worth mentioning in your report)

- OTPs are stored in server memory, so they're lost if the OTP server restarts, and it won't scale across multiple server instances — fine for a college project; a real product would use Redis or a Firestore collection with a TTL.
- The scam analyzer is rule-based, not a trained ML model — accurate enough for common patterns but not adversarially robust.
- The scoring rules live in two places (Dart + JS) — if you tune one, tune the other to keep both frontends consistent.
- Firestore rules only lock down `/users/{uid}/scans` — review before adding more collections.
- The React app's Result page relies on in-memory navigation state, so refreshing the browser on `/result` (not `/history`) sends you back to the dashboard — click through from History again if that happens.
