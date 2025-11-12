/// 认证用户实体
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role; // 用户角色: user, admin, etc.
  final DateTime? emailVerifiedAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.role = 'user', // 默认为普通用户
    this.emailVerifiedAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;
  
  /// 是否为管理员
  bool get isAdmin => role == 'admin';

  /// 是否为普通用户
  bool get isUser => role == 'user';
}
