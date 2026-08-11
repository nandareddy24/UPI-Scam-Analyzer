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

### Step 3: Start your local Python Backend & ADB Reverse
1. Start your Flask server on host machine:
   ```bash
   python app.py
   ```
   *(Server listens on `http://127.0.0.1:3000`)*

2. Connect your Android phone via USB cable and enable **USB Debugging** in Developer Options.

3. Run ADB reverse port forwarding in terminal:
   ```bash
   adb reverse tcp:3000 tcp:3000
   ```
   > 💡 **Why ADB Reverse?** This forwards all requests from `http://127.0.0.1:3000` inside your phone's WebView directly to `http://127.0.0.1:3000` on your Windows PC over the USB cable! No Wi-Fi or LAN IP required.

---

### Step 4: Run on USB Physical Phone or Android Emulator
1. In Android Studio, select your target device (e.g. your connected physical Android phone or Emulator) from the top toolbar device dropdown.
2. Click the green **Run ▶️** button (or press `Shift + F10`).
3. The app will build, install, and open the real **ScamShield** web application on your Android phone!

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
