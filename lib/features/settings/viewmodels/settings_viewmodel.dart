import 'package:flutter/material.dart';
import 'package:sonic_vault/shared/models/user_model.dart';
import 'package:sonic_vault/shared/repositories/firebase_repo.dart';

class SettingsViewModel extends ChangeNotifier {

  // ── STATE ──────────────────────────────────────
  bool _isLoading = false;
  bool _isSaving = false;
  UserModel? _user;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  final FirebaseRepository _repo = FirebaseRepository();

  // ── LOAD USER ───────────────────────────────────
  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();

    _user = await _repo.getCurrentUserData();

    _isLoading = false;
    notifyListeners();
  }

  // ── UPDATE NAME ─────────────────────────────────
  Future<bool> updateUserInfo({
    required String firstName,
    required String lastName,
  }) async {
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      _errorMessage = 'First name and last name cannot be empty.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.updateUserInfo(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      // update local user object too
      if (_user != null) {
        _user = UserModel(
          uid: _user!.uid,
          firstName: firstName.trim(),
          lastName: lastName.trim(),
          birthDate: _user!.birthDate,
          email: _user!.email,
          gender: _user!.gender,
        );
      }

      _successMessage = 'Profile updated successfully!';
      _isSaving = false;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = 'Failed to update profile. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── RESET PASSWORD ──────────────────────────────
  // reuses Firebase repo — sends reset email
  Future<bool> sendPasswordReset() async {
    if (_user == null) return false;

    _isSaving = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repo.resetPassword(_user!.email);
      _successMessage = 'Password reset email sent to ${_user!.email}';
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to send reset email. Please try again.';
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── LOGOUT ──────────────────────────────────────
  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  // ── CLEAR MESSAGES ──────────────────────────────
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}