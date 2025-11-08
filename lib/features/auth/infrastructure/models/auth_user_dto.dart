import '../../domain/entities/auth_user.dart';

/// 认证用户DTO
class AuthUserDto {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String? emailVerifiedAt;

  AuthUserDto({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.emailVerifiedAt,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
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
      emailVerifiedAt: user.emailVerifiedAt?.toIso8601String(),
    );
  }
}
