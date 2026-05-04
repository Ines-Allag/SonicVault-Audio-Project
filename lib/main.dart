import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/biometric/viewmodels/biometric_viewmodel.dart';
import 'package:sonic_vault/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:sonic_vault/features/player/viewmodels/player_viewmodel.dart';
import 'package:sonic_vault/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => BiometricViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => PlayerViewModel()),
      ],
      child: const SonicVaultApp(),
    ),
  );
}