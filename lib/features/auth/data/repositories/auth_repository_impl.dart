import 'package:flutter/foundation.dart';

import 'package:birdle/core/utils/hash_utils.dart';
import 'package:birdle/core/utils/id_generator.dart';
import 'package:birdle/features/auth/domain/repositories/auth_repository.dart';
import 'package:birdle/features/auth/data/models/user_model.dart';
import 'package:birdle/core/services/local_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService storage;
  static const String _defaultAdminEmail = 'admin@bitefinder.app';
  static const String _defaultAdminPassword = 'Admin@12345';

  AuthRepositoryImpl(this.storage);

  List<UserModel> _users() => storage.readUsers().map(UserModel.fromJson).toList();

  @override
  Future<void> ensureAdminAccount() async {
    final users = _users();
    final exists = users.any((u) => u.email.toLowerCase() == _defaultAdminEmail.toLowerCase());
    if (exists) {
      return;
    }

    final admin = UserModel(
      id: 'u_admin',
      name: 'Bite Admin',
      email: _defaultAdminEmail,
      passwordHash: HashUtils.hashPassword(_defaultAdminPassword),
      createdAt: DateTime.now().toIso8601String(),
      role: UserRole.admin,
      photoPath: null,
    );
    users.add(admin);
    await storage.writeUsers(users.map((u) => u.toJson()).toList());
  }

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    final users = _users();
    final existing = users.where((u) => u.email.toLowerCase() == email.toLowerCase()).toList();

    if (existing.isNotEmpty) {
      throw Exception('Email already registered');
    }

    final user = UserModel(
      id: IdGenerator.next('u'),
      name: name,
      email: email.trim().toLowerCase(),
      passwordHash: HashUtils.hashPassword(password),
      createdAt: DateTime.now().toIso8601String(),
      role: UserRole.user,
      photoPath: null,
    );

    users.add(user);
    await storage.writeUsers(users.map((u) => u.toJson()).toList());
    return user;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final users = _users();
    final targetEmail = email.trim().toLowerCase();
    final hash = HashUtils.hashPassword(password);

    try {
      final user = users.firstWhere(
        (u) => u.email == targetEmail && u.passwordHash == hash,
      );
      await storage.writeSessionUserId(user.id);
      return user;
    } catch (_) {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<void> logout() async {
    await storage.clearSessionUserId();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final sessionId = storage.readSessionUserId();
    if (sessionId == null) {
      return null;
    }

    final users = _users();
    final matches = users.where((u) => u.id == sessionId).toList();

    if (matches.isEmpty) {
      if (kDebugMode) {
        debugPrint('Session user not found, clearing invalid session.');
      }
      await storage.clearSessionUserId();
      return null;
    }

    return matches.first;
  }

  @override
  Future<List<UserModel>> getUsers() async {
    final users = _users();
    users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return users;
  }

  @override
  Future<void> updateUserRole({required String userId, required UserRole role}) async {
    final users = _users();
    final index = users.indexWhere((u) => u.id == userId);
    if (index < 0) {
      throw Exception('User not found');
    }
    users[index] = users[index].copyWith(role: role);
    await storage.writeUsers(users.map((u) => u.toJson()).toList());
  }

  @override
  Future<void> deleteUser(String userId) async {
    final users = _users();
    final matches = users.where((u) => u.id == userId).toList();
    if (matches.isEmpty) {
      return;
    }
    final user = matches.first;
    final adminCount = users.where((u) => u.role == UserRole.admin).length;
    if (user.role == UserRole.admin && adminCount <= 1) {
      throw Exception('Cannot delete the last admin user');
    }

    users.removeWhere((u) => u.id == userId);
    await storage.writeUsers(users.map((u) => u.toJson()).toList());

    final sessionUserId = storage.readSessionUserId();
    if (sessionUserId == userId) {
      await storage.clearSessionUserId();
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? photoPath,
    bool removePhoto = false,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw Exception('Name is required');
    }
    if (normalizedEmail.isEmpty) {
      throw Exception('Email is required');
    }

    final users = _users();
    final index = users.indexWhere((u) => u.id == userId);
    if (index < 0) {
      throw Exception('User not found');
    }

    final duplicateEmail = users.any((u) => u.id != userId && u.email.toLowerCase() == normalizedEmail);
    if (duplicateEmail) {
      throw Exception('Email already registered');
    }

    final current = users[index];
    users[index] = current.copyWith(
      name: trimmedName,
      email: normalizedEmail,
      photoPath: photoPath,
      clearPhotoPath: removePhoto,
    );
    await storage.writeUsers(users.map((u) => u.toJson()).toList());
    return users[index];
  }
}
