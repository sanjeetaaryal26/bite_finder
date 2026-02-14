import 'package:flutter/foundation.dart';

import '../../core/utils/hash_utils.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../sources/local_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService storage;

  AuthRepositoryImpl(this.storage);

  @override
  Future<UserModel> register({required String name, required String email, required String password}) async {
    final users = storage.readUsers().map(UserModel.fromJson).toList();
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
    );

    users.add(user);
    await storage.writeUsers(users.map((u) => u.toJson()).toList());
    await storage.writeSessionUserId(user.id);
    return user;
  }

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final users = storage.readUsers().map(UserModel.fromJson).toList();
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

    final users = storage.readUsers().map(UserModel.fromJson).toList();
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
}
