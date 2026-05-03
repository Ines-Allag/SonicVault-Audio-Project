import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/biometric/viewmodels/biometric_viewmodel.dart';

class BiometricGate extends StatefulWidget {
  const BiometricGate({super.key});

  @override
  State<BiometricGate> createState() => _BiometricGateState();
}

class _BiometricGateState extends State<BiometricGate> {

  @override
  void initState() {
    super.initState();
    // As soon as this screen opens, automatically trigger the scan
    // We use Future.microtask so the widget is fully built before we call anything
    Future.microtask(() =>
        context.read<BiometricViewModel>().authenticate()
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumer listens to the viewmodel — anytime notifyListeners()
    // is called, this rebuilds automatically
    return Consumer<BiometricViewModel>(
      builder: (context, viewModel, child) {

        // If authentication succeeded → navigate to next screen
        if (viewModel.isAuthenticated) {
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, '/auth');
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0A), // dark background
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    // ── APP LOGO / ICON ──────────────────────
                    const Icon(
                      Icons.fingerprint,
                      size: 100,
                      color: Color(0xFF6C63FF), // purple accent
                    ),

                    const SizedBox(height: 32),

                    // ── APP NAME ─────────────────────────────
                    const Text(
                      'Sonic Vault',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── SUBTITLE ──────────────────────────────
                    const Text(
                      'Verify your identity to continue',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 60),

                    // ── LOADING or ERROR STATE ────────────────
                    if (viewModel.isLoading)
                    // Show spinner while scanning
                      const CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      )
                    else ...[

                      // Show error message if scan failed
                      if (viewModel.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade800),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── RETRY BUTTON ────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              context.read<BiometricViewModel>().authenticate(),
                          icon: const Icon(Icons.fingerprint),
                          label: Text(
                            viewModel.errorMessage != null
                                ? 'Try Again'    // after a failure
                                : 'Scan Fingerprint', // first time
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],

                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}