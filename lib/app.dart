import 'package:flutter/material.dart';
import 'package:sonic_vault/features/biometric/views/biometric_gate.dart';
import 'package:sonic_vault/features/auth/views/login_page.dart';
import 'package:sonic_vault/features/stats/views/stats_page.dart';
import 'package:sonic_vault/features/settings/views/settings_page.dart';
import 'package:sonic_vault/features/explorer/views/explorer_page.dart'; // ← added

class SonicVaultApp extends StatelessWidget {
  const SonicVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonic Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF6C63FF),
        ),
        fontFamily: 'Roboto',
      ),
      home: const BiometricGate(),
      routes: {
        '/auth': (context) => const LoginPage(),
        '/home': (context) => const StatsPage(),
        '/settings': (context) => const SettingsPage(),
        '/explorer': (context) => const ExplorerPage(), // ← added
      },
    );
  }
}