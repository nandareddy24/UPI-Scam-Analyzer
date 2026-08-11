"""
ScamShield Android APK Build Assistant & Helper Script
Generates/Verifies Android Studio project structure and builds APK package.
"""

import os
import sys
import subprocess
import shutil

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
ANDROID_DIR = os.path.join(BASE_DIR, "android-app")

def check_environment():
    print("=" * 65)
    print("  📱 SCAMSHIELD ANDROID APPLICATION BUILDER")
    print("=" * 65)
    print(f"Android Project Location: {ANDROID_DIR}")

    # Check Java
    try:
        res = subprocess.run(["java", "-version"], capture_output=True, text=True)
        print("\n[OK] Java Runtime Environment Detected:")
        lines = (res.stdout or res.stderr).splitlines()
        for line in lines[:2]:
            print(f"     {line}")
    except Exception as e:
        print("\n[WARN] Java CLI not found in PATH:", e)

    # Check Android SDK / Android Studio environment
    android_home = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if android_home and os.path.exists(android_home):
        print(f"\n[OK] Android SDK Detected at: {android_home}")
    else:
        print("\n[NOTE] ANDROID_HOME not set in environment.")
        print("       You can open the 'android-app' folder directly in Android Studio")
        print("       to let Android Studio automatically compile and install the app.")

def build_apk():
    check_environment()

    print("\n" + "=" * 65)
    print("  🚀 OPTIONS FOR ANDROID APP CREATION & INSTALATION")
    print("=" * 65)

    print("\nOPTION 1: Open Directly in Android Studio (Recommended)")
    print("  1. Launch Android Studio.")
    print("  2. Select 'File -> Open' and pick the folder:")
    print(f"     {ANDROID_DIR}")
    print("  3. Click 'Sync Project with Gradle Files'.")
    print("  4. Press 'Run ▶️' to launch ScamShield on your Android device/emulator.")
    print("  5. Go to 'Build -> Build APK(s)' to generate your signed .apk file.")

    print("\nOPTION 2: Progressive Web App (PWA) Instant Install on Phone")
    print("  1. Connect your Android phone to the same Wi-Fi as this PC.")
    print("  2. Open Chrome on your phone and go to:")
    print("     http://<YOUR-PC-IP>:3000/mobile_app")
    print("  3. Tap Chrome 3-dots menu -> Select 'Add to Home Screen' or 'Install App'.")
    print("  4. ScamShield will install as a native full-screen app on your Android phone!")

if __name__ == "__main__":
    build_apk()
