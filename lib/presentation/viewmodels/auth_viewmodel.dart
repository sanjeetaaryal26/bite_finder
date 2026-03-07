import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_logger.dart';
import '../../data/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;
  String? _fingerprintEnabledUserId;
  bool _fingerprintUnlocked = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  String? get fingerprintEnabledUserId => _fingerprintEnabledUserId;
  bool get fingerprintUnlocked => _fingerprintUnlocked;

  void setFingerprintUnlocked(bool unlocked) {
    _fingerprintUnlocked = unlocked;
    notifyListeners();
  }

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.ensureAdminAccount();
      _currentUser = await _authRepository.getCurrentUser();
      _error = null;
      final prefs = await SharedPreferences.getInstance();
      _fingerprintEnabledUserId = prefs.getString('fingerprint_enabled_user');
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.initialize');
      _error = null;
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setFingerprintEnabledForUser(String? userId) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId == null) {
      await prefs.remove('fingerprint_enabled_user');
    } else {
      await prefs.setString('fingerprint_enabled_user', userId);
    }
    _fingerprintEnabledUserId = userId;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser =
          await _authRepository.login(email: email.trim(), password: password);
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.login');
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      {required String name,
      required String email,
      required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.register(
          name: name.trim(), email: email.trim(), password: password);
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.register');
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _authRepository.logout();
    _currentUser = null;
    // Reset biometric unlocked state on logout
    _fingerprintUnlocked = false;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    final current = _currentUser;
    if (current == null) {
      _error = 'Please login again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.updateProfile(
        userId: current.id,
        name: name,
        email: email,
        photoPath: photoPath,
        removePhoto: removePhoto,
      );
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.updateProfile');
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
