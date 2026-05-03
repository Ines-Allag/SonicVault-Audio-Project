import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/biometric/viewmodels/biometric_viewmodel.dart';
import 'package:sonic_vault/app.dart';

import 'features/auth/viewmodels/auth_viewmodel.dart';

void main() async {
  // Makes sure Flutter is fully ready before we do anything
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase — must happen before runApp
  await Firebase.initializeApp();

  runApp(
    // MultiProvider is how we make viewmodels available
    // to the entire app — think of it as a backpack
    // that every screen can reach into
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const SonicVaultApp(),
    ),
  );
}