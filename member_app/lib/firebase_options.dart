import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBWdjbLXlJn1Wkad1G-oBRTwu0GBVYfxPc',
    appId: '1:195819373754:android:d6d9c4d4833b557ea8ae83', // Updated to your new App ID
    messagingSenderId: '195819373754', // Updated to your Project Number
    projectId: 'mezmurbet-bdu',
    storageBucket: 'mezmurbet-bdu.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBWdjbLXlJn1Wkad1G-oBRTwu0GBVYfxPc',
    appId: '1:195819373754:ios:d6d9c4d4833b557ea8ae83', // Adjusted to match project sequence
    messagingSenderId: '195819373754',
    projectId: 'mezmurbet-bdu',
    storageBucket: 'mezmurbet-bdu.firebasestorage.app',
    iosBundleId: 'com.example.mezmurbet_member_final1', // Updated to match your new Package Name
  );
}