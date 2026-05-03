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
  }

  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1DB954).withOpacity(0.15),
                border: Border.all(
                  color: const Color(0xFF1DB954),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF1DB954),
                size: 60,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Identity Verified!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Welcome to Sonic Vault',
              style: TextStyle(
                color: Color(0xFF1DB954),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BiometricViewModel>(
      builder: (context, viewModel, child) {

        // ── SUCCESS SOUND PLAYING ──────────────────
        if (viewModel.showSuccess) {
          return _buildSuccessScreen();
        }

        // ── AUTHENTICATED → keep success screen + navigate
        if (viewModel.isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/auth');
            }
          });
          return _buildSuccessScreen(); // ← no flash, stays green
        }

        // ── MAIN BIOMETRIC SCREEN ──────────────────
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          // resizeToAvoidBottomInset fixes the page shifting left
          // when system dialogs appear
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            // maintainBottomViewPadding prevents layout shifts
            maintainBottomViewPadding: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [

                  const Spacer(flex: 2),

                  // ── TOP LOGO AREA ────────────────
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1DB954).withOpacity(0.1),
                      border: Border.all(
                        color: const Color(0xFF1DB954).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 50,
                      color: Color(0xFF1DB954),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── APP NAME ─────────────────────
                  const Text(
                    'Sonic Vault',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Your secure audio player',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white38,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // ── FINGERPRINT ICON ─────────────
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: viewModel.errorMessage != null
                          ? Colors.red.withOpacity(0.08)
                          : const Color(0xFF1DB954).withOpacity(0.08),
                      border: Border.all(
                        color: viewModel.errorMessage != null
                            ? Colors.red.withOpacity(0.3)
                            : const Color(0xFF1DB954).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint_rounded,
                      size: 80,
                      color: viewModel.errorMessage != null
                          ? Colors.redAccent
                          : const Color(0xFF1DB954),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── STATUS TEXT ──────────────────
                  Text(
                    viewModel.isLoading
                        ? 'Scanning...'
                        : viewModel.errorMessage != null
                        ? 'Not recognized'
                        : 'Scan your fingerprint',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: viewModel.errorMessage != null
                          ? Colors.redAccent
                          : Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    viewModel.isLoading
                        ? 'Place your finger on the sensor'
                        : viewModel.errorMessage != null
                        ? 'Please try again'
                        : 'Tap the button below to verify your identity',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // ── LOADING OR BUTTON ────────────
                  if (viewModel.isLoading)
                    const CircularProgressIndicator(
                      color: Color(0xFF1DB954),
                      strokeWidth: 2.5,
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => viewModel.errorMessage != null
                            ? context.read<BiometricViewModel>().authenticate()
                            : context.read<BiometricViewModel>().startAuthentication(),
                        icon: Icon(
                          viewModel.errorMessage != null
                              ? Icons.refresh_rounded
                              : Icons.fingerprint_rounded,
                        ),
                        label: Text(
                          viewModel.errorMessage != null
                              ? 'Try Again'
                              : 'Scan Fingerprint',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1DB954),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── BOTTOM HINT ──────────────────
                  const Text(
                    'Secured by biometric authentication',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white24,
                    ),
                  ),

                  const Spacer(),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}