import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      default: throw UnsupportedError('Platform not supported');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PASTE_YOUR_WEB_API_KEY_HERE', // From Project Settings
    appId: 'PASTE_THE_NEW_ANDROID_APP_ID', // Starts with 1:...
    messagingSenderId: 'PASTE_SENDER_ID',
    projectId: 'mezmurbet-bdu',
    storageBucket: 'mezmurbet-bdu.appspot.com',
  );
}