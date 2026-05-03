import 'package:flutter/material.dart';
import 'package:sonic_vault/core/services/biometric_service.dart';
import 'package:sonic_vault/core/services/sound_service.dart';

// ChangeNotifier means this class can notify the view
// whenever something changes (state changes)
class BiometricViewModel extends ChangeNotifier {

  // ── STATE ──────────────────────────────────────
  // these variables describe what the UI should show
  // at any given moment

  bool _isLoading = false;      // are we currently scanning?
  bool _isAuthenticated = false; // did the scan succeed?
  String? _errorMessage;         // is there an error to show?

  // Getters — the view reads these, never the private variables directly
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  // ── SERVICE ─────────────────────────────────────
  // the viewmodel USES the service, it doesn't replace it
  final BiometricService _biometricService = BiometricService();
  final SoundService _soundService = SoundService();

  // ── MAIN METHOD ─────────────────────────────────
  // this is called when the app opens or when user taps retry
  Future<void> authenticate() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // tell the view "hey update yourself"

    // Step 1 — is a fingerprint registered on this phone?
    final bool available = await _biometricService.isBiometricAvailable();

    if (!available) {
      // No fingerprint registered → send user to settings
      await _biometricService.openBiometricSettings();
      _isLoading = false;
      notifyListeners();
      return; // stop here, wait for user to come back
    }

    // Step 2 — fingerprint exists → show the scan prompt
    final bool result = await _biometricService.authenticate();

    if (result) {
      // SUCCESS → PLAY SOUND HIHI , mark as authenticated, view will navigate forward
      await _soundService.playSuccessSound();
      _isAuthenticated = true;
      _errorMessage = null;
    } else {
      // FAILED → show retry message, do NOT close the app
      _isAuthenticated = false;
      _errorMessage = 'Fingerprint not recognized. Please try again.';
    }

    _isLoading = false;
    notifyListeners(); // tell the view to rebuild with new state
  }
}