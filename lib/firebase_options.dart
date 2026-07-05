// File generated normally by the FlutterFire CLI (`flutterfire configure`).
//
// TODO(RYO): このファイルはプレースホルダーです。実際のFirebaseプロジェクトに接続する前に
// `flutterfire configure` を実行し、本ファイルを生成し直してください
// (https://firebase.google.com/docs/flutter/setup?platform=ios を参照)。
// 現在の値はすべてダミーであり、実際のFirebaseプロジェクトへは接続できません。
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` から参照する。
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
        return ios;
      case TargetPlatform.windows:
        return android;
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

  // TODO(RYO): `flutterfire configure` 実行後にすべて実値へ置き換えてください。
  static const web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    appId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    messagingSenderId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    projectId: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    authDomain: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
    storageBucket: 'REPLACE_WITH_FLUTTERFIRE_CONFIGURE',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBR-G_gcZ4MAeQTeqTS1wNBrmTM0U-F1i0',
    appId: '1:533310859784:ios:261520d4949f4e26663fbd',
    messagingSenderId: '533310859784',
    projectId: 'flutter-camera-ryonn',
    storageBucket: 'flutter-camera-ryonn.firebasestorage.app',
    iosBundleId: 'tokyo.n-n.flutterCamera',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBH7w28MI_j1no1HAnPnDqIS0A0cZkuYro',
    appId: '1:533310859784:android:9d4ca24618d3496a663fbd',
    messagingSenderId: '533310859784',
    projectId: 'flutter-camera-ryonn',
    storageBucket: 'flutter-camera-ryonn.firebasestorage.app',
  );
}
