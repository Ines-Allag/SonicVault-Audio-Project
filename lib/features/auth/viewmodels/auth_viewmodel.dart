import 'package:flutter/material.dart';
import 'package:sonic_vault/shared/models/user_model.dart';
import 'package:sonic_vault/shared/repositories/firebase_repo.dart';

class AuthViewModel extends ChangeNotifier {

  // ── STATE ──────────────────────────────────────
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  // ── REPOSITORY ──────────────────────────────────
  final FirebaseRepository _repo = FirebaseRepository();

  // ─────────────────────────────────────────
  // CHECK: already logged in?
  // called right after biometric succeeds
  // ─────────────────────────────────────────
  Future<bool> checkIfAlreadyLoggedIn() async {
    if (_repo.isLoggedIn) {
      // fetch user data from Firestore
      _currentUser = await _repo.getCurrentUserData();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ─────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _repo.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true; // success → view will navigate to home

    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleFirebaseError(e.toString());
      notifyListeners();
      return false; // failed → view shows error
    }
  }

  // ─────────────────────────────────────────
  // REGISTER
  // ─────────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required DateTime birthDate,
    String? gender,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // ── AGE VALIDATION ──────────────────────
    // calculate age from birthdate
    final DateTime today = DateTime.now();
    final int age = today.year - birthDate.year -
        ((today.month < birthDate.month ||
            (today.month == birthDate.month &&
                today.day < birthDate.day)) ? 1 : 0);

    if (age < 13) {
      _isLoading = false;
      _errorMessage = 'You must be at least 13 years old to register.';
      notifyListeners();
      return false; // block registration
    }

    try {
      _currentUser = await _repo.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        gender: gender,
      );
      _isLoading = false;
      notifyListeners();
      return true; // success → view navigates to home

    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleFirebaseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────
  // RESET PASSWORD
  // ─────────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repo.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true; // email sent successfully

    } catch (e) {
      _isLoading = false;
      _errorMessage = _handleFirebaseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _currentUser = null;
    notifyListeners();
  }

  // ─────────────────────────────────────────
  // HELPER: convert Firebase errors to
  // human readable messages
  // ─────────────────────────────────────────
  String _handleFirebaseError(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again.';
    } else if (error.contains('email-already-in-use')) {
      return 'An account already exists with this email.';
    } else if (error.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    } else if (error.contains('invalid-email')) {
      return 'Please enter a valid email address.';
    } else if (error.contains('network-request-failed')) {
      return 'No internet connection. Please try again.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // helper to clear errors when user starts typing
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}