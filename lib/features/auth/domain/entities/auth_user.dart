import 'package:df_admin_mobile/features/membership/domain/entities/user_membership.dart';

/// 认证用户实体
class AuthUser {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role; // 用户角色: user, admin, etc.
  final DateTime? emailVerifiedAt;
  final UserMembership? membership; // 会员信息

  AuthUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.role = 'user', // 默认为普通用户
    this.emailVerifiedAt,
    this.membership,
  });

  bool get isEmailVerified => emailVerifiedAt != null;
  
  /// 是否为管理员
  bool get isAdmin => role == 'admin';

  /// 是否为普通用户
  bool get isUser => role == 'user';

  /// 复制并更新
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    String? role,
    DateTime? emailVerifiedAt,
    UserMembership? membership,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      membership: membership ?? this.membership,
    );
  }
}
