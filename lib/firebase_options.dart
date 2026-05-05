import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAR36rWi8raFz3Nw3d8aQ9L7K0wBf_a47U',
    appId: '1:358759832482:android:97ed8ca8eaa429973270fb',
    messagingSenderId: '358759832482',
    projectId: 'audio-project-ce962',

    // ← This line is the fix for your Europe region database
    databaseURL: 'https://audio-project-'
        'ce962-default-rtdb.europe-west1.firebasedatabase.app',

    storageBucket: 'audio-project-ce962.firebasestorage.app',
  );
}