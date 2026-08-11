# 📱 ScamShield Android Studio Project

Welcome to the **native Android Studio project** for ScamShield AI!

This folder (`android-app/`) is a complete, production-ready **Android Studio project** configured with Gradle, Kotlin, AndroidX, Material Design 3, WebView WebChromeClient (supporting file/camera upload for QR & OCR scans), SwipeRefreshLayout, FileProvider, and permissions.

---

## 🚀 How to Open and Sync in Android Studio

### Step 1: Open Android Studio
1. Launch **Android Studio** on your computer.
2. Click **Open** (or `File -> Open...`).
3. Browse to your project directory and select the **`android-app`** folder:
   ```text
   C:\Users\DELL\Documents\UPI-Scam-Analyzer\android-app
   ```
4. Click **OK**.

---

### Step 2: Sync Gradle Project
1. Android Studio will automatically start **Gradle Sync** (downloading Kotlin & Android build dependencies).
2. If prompted, click **"Sync Project with Gradle Files"** (or click the elephant icon 🐘 in the top right).
3. Wait for the sync status at the bottom to say:
   `BUILD SUCCESSFUL in Xs`

---

### Step 3: Start your local Python Backend
Make sure your Flask server is running locally on your computer:
```bash
python app.py
```
> 💡 **Note on Localhost IP:** Inside the Android Emulator, `http://10.0.2.2:5000` automatically connects to `http://127.0.0.1:5000` on your host PC!
> If you are testing on a **physical Android phone connected via USB or Wi-Fi**, change `http://10.0.2.2:5000` in `app/src/main/res/values/strings.xml` to your PC's local Wi-Fi IP (e.g. `http://192.168.1.100:5000`).

---

### Step 4: Run on Android Emulator or Physical Device
1. In Android Studio, select your target device (e.g. **Pixel 7 API 34** emulator or connected physical Android phone) from the top toolbar device dropdown.
2. Click the green **Run ▶️** button (or press `Shift + F10`).
3. The app will build, install, and open **ScamShield** on your Android device!

---

### 📦 How to Build APK or AAB for Release

To generate an installable `.apk` file:
1. In Android Studio, go to top menu: **Build -> Build Bundle(s) / APK(s) -> Build APK(s)**
2. Once build finishes, click **"locate"** in the popup notification to find your output file:
   `app/build/outputs/apk/debug/app-debug.apk`

---

## 🛠️ Project Structure Overview

```text
android-app/
├── build.gradle              <-- Root Project Gradle File
├── settings.gradle           <-- Project Settings
├── gradle.properties         <-- Build performance configuration
├── app/
│   ├── build.gradle          <-- App Module Gradle Dependencies
│   ├── proguard-rules.pro    <-- ProGuard code obfuscation rules
│   └── src/
│       └── main/
│           ├── AndroidManifest.xml   <-- App Permissions & Intent Filters
│           ├── java/com/scamshield/ai/
│           │   └── MainActivity.kt    <-- Native Kotlin WebView Activity + File Chooser Bridge
│           ├── res/
│           │   ├── layout/activity_main.xml  <-- SwipeRefreshLayout + WebView Layout
│           │   ├── values/colors.xml
│           │   ├── values/strings.xml
│           │   ├── values/styles.xml
│           │   └── xml/file_paths.xml
│           └── assets/       <-- Embedded web app fallback assets
```

---

## ✨ Features Included in Native Android App

- 🛡️ **Full-screen WebView** with Android hardware back-button integration.
- 📸 **Camera & Gallery File Upload Chooser** for scanning QR codes and uploading OCR screenshots.
- 🔄 **Swipe-to-Refresh** native gesture layout.
- ⚡ **Offline Resilience Page** displayed automatically if backend server is unreachable.
- 🔐 **Android Security Permissions** (Camera, Storage, Media, Internet).
- 🌉 **Native JavaScript Interface (`ScamShieldNative`)** to bridge web and Kotlin functions.
