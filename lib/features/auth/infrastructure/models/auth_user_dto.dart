import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';

/// 认证用户DTO
class AuthUserDto {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String role; // 用户角色
  final String? emailVerifiedAt;

  AuthUserDto({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.role = 'user',
    this.emailVerifiedAt,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'user',
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
      'role': role,
      if (emailVerifiedAt != null) 'emailVerifiedAt': emailVerifiedAt,
    };
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      name: name,
      phone: phone,
      avatar: avatar,
      role: role,
      emailVerifiedAt:
          emailVerifiedAt != null ? DateTime.tryParse(emailVerifiedAt!) : null,
    );
  }

  factory AuthUserDto.fromDomain(AuthUser user) {
    return AuthUserDto(
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      avatar: user.avatar,
      role: user.role,
      emailVerifiedAt: user.emailVerifiedAt?.toIso8601String(),
    );
  }
}
