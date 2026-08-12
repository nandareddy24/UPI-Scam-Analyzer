# 📱 Scam Shield AI - Native Android Client

Welcome to the **full native Android project** for Scam Shield AI!

This app is a native Kotlin client built with **Jetpack Compose**, interacting with the Scam Shield Flask backend via REST APIs.

---

## 🚀 Key Features

- **100% Native UI**: Built with Jetpack Compose for a smooth, high-performance experience.
- **Shared Authentication**: Same user accounts and passwords as the web platform.
- **Real-time AI Scanning**: UPI, Phone, SMS, and URL scanning powered by backend ML models.
- **Native Hardware Access**: 
    - **Camera QR Scanner**: High-speed QR detection using CameraX and ML Kit.
    - **Image Picker**: Secure gallery access for OCR screenshot analysis.
- **Secure Token Storage**: JWT tokens stored using EncryptedSharedPreferences.
- **Full Sync**: Scan history, community reports, and profile data stay in sync across all devices.

---

## 🛠️ Architecture

The app follows a modern Android architectural pattern:
- **UI Layer**: Jetpack Compose Screens.
- **State Management**: ViewModels with StateFlow/mutableState.
- **Data Layer**: Repository pattern with Retrofit for API calls.
- **Network**: OkHttp with JSON logging and JWT interceptor.
- **Security**: Android Keystore backed encryption for session data.

---

## ⚙️ Configuration

The app points to the production backend by default. To modify the backend URL:
1. Open `app/src/main/res/values/strings.xml`.
2. Update the `server_url` value:
   ```xml
   <string name="server_url">https://your-backend-api.com</string>
   ```

---

## 📦 How to Build

1. Open the `android-app` folder in Android Studio.
2. Let Gradle Sync complete.
3. Build APK: **Build -> Build Bundle(s) / APK(s) -> Build APK(s)**.
4. Output location: `app/build/outputs/apk/debug/app-debug.apk`.

---

## 🔒 Security Note

- No passwords or sensitive data are stored in plain text.
- All network communication is conducted over HTTPS in release builds.
- Cleartext traffic is disabled by default for production safety.
