import 'package:flutter/material.dart';

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

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get initialized => _initialized;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.ensureAdminAccount();
      _currentUser = await _authRepository.getCurrentUser();
      _error = null;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.initialize');
      _error = null;
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authRepository.login(email: email.trim(), password: password);
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.login');
      _error = null;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register({required String name, required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authRepository.register(name: name.trim(), email: email.trim(), password: password);
      return true;
    } catch (e, st) {
      AppLogger.error(e, st, context: 'AuthViewModel.register');
      _error = null;
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
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
