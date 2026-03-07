enum UserRole { user, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String createdAt;
  final UserRole role;
  final String? photoPath;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
    required this.role,
    required this.photoPath,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? passwordHash,
    String? createdAt,
    UserRole? role,
    String? photoPath,
    bool clearPhotoPath = false,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      role: role ?? this.role,
      photoPath: clearPhotoPath ? null : (photoPath ?? this.photoPath),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        passwordHash: json['passwordHash'] as String,
        createdAt: json['createdAt'] as String,
        role: (json['role'] as String?) == 'admin' ? UserRole.admin : UserRole.user,
        photoPath: json['photoPath'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'passwordHash': passwordHash,
        'createdAt': createdAt,
        'role': role.name,
        'photoPath': photoPath,
      };
}
