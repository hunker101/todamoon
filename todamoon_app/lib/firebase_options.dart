// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDeIDIlQYTLTK14XiC4OYSZjZ0Sy56vtj8',
    appId: '1:54429953328:web:a76c0e7d47eb3c30df6cf5',
    messagingSenderId: '54429953328',
    projectId: 'todamoon-app',
    authDomain: 'todamoon-app.firebaseapp.com',
    storageBucket: 'todamoon-app.firebasestorage.app',
    measurementId: 'G-XZP1N99ER6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuxybMm_NOda_mCWxPt6p7XGNU9Nax8IM',
    appId: '1:54429953328:android:d13b7d47f5cacca9df6cf5',
    messagingSenderId: '54429953328',
    projectId: 'todamoon-app',
    storageBucket: 'todamoon-app.firebasestorage.app',
  );
}
