// ⚠️ PLACEHOLDER FILE — replace this by running the FlutterFire CLI.
//
// This project can't ship real Firebase config because that config is tied
// to YOUR Firebase project (project ID, API keys, app IDs, etc).
//
// To generate the real version of this file:
//   1. dart pub global activate flutterfire_cli
//   2. firebase login
//   3. flutterfire configure
//      (pick/create your Firebase project, select Android/iOS/Web platforms)
// This OVERWRITES this file with your real, working configuration.
// Full guide: https://firebase.google.com/docs/flutter/setup
//
// Until you do that, the app will build but Firebase calls will fail.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
        return web;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBX1NHqM_2tbsT-B7wnK8kF8F3fJ060Egs',
    appId: '1:462265068883:web:45a77df9a98cd238f445a6',
    messagingSenderId: '462265068883',
    projectId: 'upi-scam',
    authDomain: 'upi-scam.firebaseapp.com',
    storageBucket: 'upi-scam.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBX1NHqM_2tbsT-B7wnK8kF8F3fJ060Egs',
    appId: '1:462265068883:web:45a77df9a98cd238f445a6',
    messagingSenderId: '462265068883',
    projectId: 'upi-scam',
    storageBucket: 'upi-scam.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'REPLACE_WITH_YOUR_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_YOUR_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.upiScamAnalyzer',
  );
}
