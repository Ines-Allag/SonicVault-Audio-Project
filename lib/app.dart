import 'package:flutter/material.dart';
import 'package:sonic_vault/features/biometric/views/biometric_gate.dart';
import 'package:sonic_vault/features/auth/views/login_page.dart';
import 'package:sonic_vault/features/explorer/views/explorer_page.dart';

class SonicVaultApp extends StatelessWidget {
  const SonicVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sonic Vault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF22C55E),
        scaffoldBackgroundColor: const Color(0xFF080808),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF22C55E),
          secondary: const Color(0xFF22C55E),
        ),
        fontFamily: 'Roboto',
      ),
      home: const BiometricGate(),
      routes: {
        '/auth': (context) => const LoginPage(),
        '/home': (context) => const ExplorerPage(),
      },
    );
  }
}