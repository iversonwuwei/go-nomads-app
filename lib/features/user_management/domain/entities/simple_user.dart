/// Simple User Entity for User Management
/// 简化的用户实体，用于管理员进行用户管理
class SimpleUser {
  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String role;
  final DateTime createdAt;

  SimpleUser({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    required this.role,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isModerator => role == 'moderator';
  bool get isUser => role == 'user';

  SimpleUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? role,
    DateTime? createdAt,
  }) {
    return SimpleUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
