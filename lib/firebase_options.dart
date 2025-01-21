import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Web platformu için DefaultFirebaseOptions.web kullanın.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS platformu için DefaultFirebaseOptions.ios kullanın.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'MacOS platformu için DefaultFirebaseOptions.macos kullanın.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Windows platformu henüz desteklenmiyor.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Linux platformu henüz desteklenmiyor.',
        );
      default:
        throw UnsupportedError(
          'Desteklenmeyen platform: ${defaultTargetPlatform}',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBqvTLxaNozScuh0JIwJJTxwiBPPS-W_T4',
    appId: '1:1060467981154:android:19dba6fa2687b9fa298a3b',
    messagingSenderId: '1060467981154',
    projectId: 'yapayzeka-cizim',
    storageBucket: 'yapayzeka-cizim.firebasestorage.app',
  );
}
