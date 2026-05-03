import 'package:local_auth/local_auth.dart';
import 'package:app_settings/app_settings.dart';

class BiometricService {
  // We create one instance of LocalAuth — this is the package
  // that talks to the phone's fingerprint sensor
  final LocalAuthentication _auth = LocalAuthentication();

  // ─────────────────────────────────────────
  // CHECK: does the phone have any fingerprint
  // registered in its settings?
  // ─────────────────────────────────────────
  Future<bool> isBiometricAvailable() async {
    try {
      // First check if the hardware supports biometrics at all
      final bool canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;

      // Then check if the user has actually enrolled a fingerprint
      final List<BiometricType> availableBiometrics =
      await _auth.getAvailableBiometrics();

      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────
  // REDIRECT: send user to phone settings
  // so they can register a fingerprint
  // ─────────────────────────────────────────
  Future<void> openBiometricSettings() async {
    await AppSettings.openAppSettings(
      type: AppSettingsType.security,
    );
  }

  // ─────────────────────────────────────────
  // AUTHENTICATE: show the fingerprint prompt
  // returns true if scan succeeded
  // returns false if scan failed or cancelled
  // ─────────────────────────────────────────
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan your fingerprint to access Sonic Vault',
        options: const AuthenticationOptions(
          stickyAuth: true,   // keeps prompt open if user switches apps
          biometricOnly: true, // fingerprint only, no PIN fallback
        ),
      );
    } catch (e) {
      return false;
    }
  }
}