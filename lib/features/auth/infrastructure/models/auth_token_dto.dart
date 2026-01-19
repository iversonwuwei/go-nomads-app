import 'package:go_nomads_app/features/auth/domain/entities/auth_token.dart';

/// 认证令牌DTO
class AuthTokenDto {
  final String accessToken;
  final String? refreshToken;
  final int? expiresIn; // 秒数
  final DateTime? expiresAt;

  AuthTokenDto({
    required this.accessToken,
    this.refreshToken,
    this.expiresIn,
    this.expiresAt,
  });

  factory AuthTokenDto.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expiresIn'] as int?;
    DateTime? expiresAt;

    if (expiresIn != null) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    } else if (json['expiresAt'] != null) {
      expiresAt = DateTime.parse(json['expiresAt'] as String);
    }

    return AuthTokenDto(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String?,
      expiresIn: expiresIn,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      if (refreshToken != null) 'refreshToken': refreshToken,
      if (expiresIn != null) 'expiresIn': expiresIn,
      if (expiresAt != null) 'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  AuthToken toDomain() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  factory AuthTokenDto.fromDomain(AuthToken token) {
    return AuthTokenDto(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
    );
  }
}
