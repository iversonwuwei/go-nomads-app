import '../../domain/entities/simple_user.dart';

/// Simple User DTO for API communication
class SimpleUserDto {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String roleId;
  final String roleName;
  final DateTime createdAt;

  SimpleUserDto({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.roleId,
    required this.roleName,
    required this.createdAt,
  });

  factory SimpleUserDto.fromJson(Map<String, dynamic> json) {
    return SimpleUserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roleId: json['roleId'] as String,
      roleName: json['roleName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'roleId': roleId,
      'roleName': roleName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  SimpleUser toEntity() {
    return SimpleUser(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      role: roleName.toLowerCase(), // 转为小写: admin, moderator, user
      createdAt: createdAt,
    );
  }
}
