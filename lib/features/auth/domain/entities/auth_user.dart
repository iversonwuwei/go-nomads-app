/// 认证用户实体
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final DateTime? emailVerifiedAt;

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.emailVerifiedAt,
  });

  bool get isEmailVerified => emailVerifiedAt != null;
}
