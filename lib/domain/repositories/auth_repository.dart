import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> ensureAdminAccount();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<List<UserModel>> getUsers();
  Future<void> updateUserRole({required String userId, required UserRole role});
  Future<void> deleteUser(String userId);
  Future<UserModel> updateProfile({
    required String userId,
    required String name,
    required String email,
    String? photoPath,
    bool removePhoto = false,
  });

  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}
