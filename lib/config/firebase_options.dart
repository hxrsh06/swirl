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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:106590952825:web:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:1065909528825:android:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:1065909528825:ios:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:1065909528825:macos:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:1065909528825:windows:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDDq4p3W0QbBx423ZJQ7QJw8S6yS8N7f8E',
    appId: '1:1065909528825:linux:5b4e63fe6e8f1488e8a7c2',
    messagingSenderId: '1065909528825',
    projectId: 'swirl-f4db5',
    authDomain: 'swirl-f4db5.firebaseapp.com',
    databaseURL: 'https://swirl-f4db5-default-rtdb.firebaseio.com',
    storageBucket: 'swirl-f4db5.appspot.com',
  );
}