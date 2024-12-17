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
        return ios;
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
    apiKey: 'AIzaSyBwZhVpp_bLdP0jugVoIUBdKRR3QdQ6zgw',
    appId: '1:912971592578:web:e6991ee353db94cb96d59b',
    messagingSenderId: '912971592578',
    projectId: 'hairar',
    authDomain: 'hairar.firebaseapp.com',
    storageBucket: 'hairar.firebasestorage.app',
    measurementId: 'G-ZW7C6GH51X',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAVgpNaK9tenOPM0uf_s0BU8VyqK4DwSew',
    appId: '1:912971592578:android:d66bb1b9b52fc4b096d59b',
    messagingSenderId: '912971592578',
    projectId: 'hairar',
    storageBucket: 'hairar.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAupVSLrALvnZ7Q89Y9oWaeYJcXEkowmrU',
    appId: '1:912971592578:ios:6b90444835f3485496d59b',
    messagingSenderId: '912971592578',
    projectId: 'hairar',
    storageBucket: 'hairar.firebasestorage.app',
    iosBundleId: 'com.snaplens.hairar.hairAr',
  );
}