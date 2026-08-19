import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgqX6uCufW1kENxj13kuHD2L6SO7vEvQo',
    appId: '1:21502516857:web:96d2e2cf13c63594cc3ea8',
    messagingSenderId: '21502516857',
    projectId: 'senior-social-india',
    authDomain: 'senior-social-india.firebaseapp.com',
    storageBucket: 'senior-social-india.firebasestorage.app',
    measurementId: 'G-4WHDCFZX46',
  );

  // Replace these values after adding the Android app in Firebase Console.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'PASTE_ANDROID_API_KEY',
    appId: 'PASTE_ANDROID_APP_ID',
    messagingSenderId: '21502516857',
    projectId: 'senior-social-india',
    storageBucket: 'senior-social-india.firebasestorage.app',
  );

  // Replace these values after adding the iOS app in Firebase Console.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'PASTE_IOS_API_KEY',
    appId: 'PASTE_IOS_APP_ID',
    messagingSenderId: '21502516857',
    projectId: 'senior-social-india',
    storageBucket: 'senior-social-india.firebasestorage.app',
    iosBundleId: 'in.seniorsocial.app',
  );
}
