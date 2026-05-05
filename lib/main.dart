import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'package:sonic_vault/app.dart';
import 'features/auth/viewmodels/auth_viewmodel.dart';
import 'features/biometric/viewmodels/biometric_viewmodel.dart';
import 'features/settings/viewmodels/settings_viewmodel.dart';
import 'features/stats/viewmodels/stats_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'AIzaSyAR36rWi8raFz3Nw3d8aQ9L7K0wBf_a47U',
        appId: '1:358759832482:android:97ed8ca8eaa429973270fb',
        messagingSenderId: '358759832482',
        projectId: 'audio-project-ce962',
        databaseURL: 'https://audio-project-ce962-default-rtdb.europe-west1.firebasedatabase.app',  // Force it here
        storageBucket: 'audio-project-ce962.firebasestorage.app',
      ),
    );
    print("✅ Firebase initialized with EUROPE URL");
  } catch (e) {
    print("Firebase init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => StatsViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
      ],
      child: const SonicVaultApp(),
    ),
  );
}