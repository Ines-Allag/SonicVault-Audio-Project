import 'package:flutter/material.dart';
import 'package:sonic_vault/core/services/biometric_service.dart';
import 'package:sonic_vault/core/services/sound_service.dart';

class BiometricViewModel extends ChangeNotifier {

  // ── STATE ──────────────────────────────────────
  bool _hasStarted = false;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  bool _showSuccess = false;
  String? _errorMessage;


  // Getters
  bool get hasStarted => _hasStarted;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  bool get showSuccess => _showSuccess;
  String? get errorMessage => _errorMessage;

  // ── SERVICES ────────────────────────────────────
  final BiometricService _biometricService = BiometricService();
  final SoundService _soundService = SoundService();

  // ── CALLED WHEN USER TAPS THE BUTTON ────────────
  // this is the entry point from the view
  Future<void> startAuthentication() async {
    _hasStarted = true;
    notifyListeners();
    await authenticate();
  }

  // ── CALLED ON RETRY TOO ──────────────────────────
  Future<void> authenticate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Step 1 — is a fingerprint registered on this phone?
    final bool available = await _biometricService.isBiometricAvailable();

    if (!available) {
      _biometricService.openBiometricSettings();
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Step 2 — show the scan prompt
    final bool result = await _biometricService.authenticate();

    if (result) {
      _showSuccess = true;
      notifyListeners();
      await _soundService.playSuccessSound();
      // SET BOTH at the same time — only ONE rebuild
      _showSuccess = false;
      _isAuthenticated = true;
      _errorMessage = null;
      notifyListeners(); // single rebuild → goes straight to auth
    }
    else {
      // FAILED
      _isAuthenticated = false;
      _errorMessage = 'Fingerprint not recognized. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }
}