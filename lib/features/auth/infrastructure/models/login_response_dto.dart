import '../../domain/entities/login_response.dart';

/// LoginResponse DTO
class LoginResponseDto {
  final bool success;
  final String message;
  final LoginDataDto? data;
  final List<String> errors;

  LoginResponseDto({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? LoginDataDto.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      errors: (json['errors'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  LoginResponse toDomain() {
    return LoginResponse(
      success: success,
      message: message,
      data: data?.toDomain(),
      errors: errors,
    );
  }
}

/// LoginData DTO
class LoginDataDto {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserInfoDto user;

  LoginDataDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
      'user': user.toJson(),
    };
  }

  factory LoginDataDto.fromJson(Map<String, dynamic> json) {
    return LoginDataDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserInfoDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  LoginData toDomain() {
    return LoginData(
      tokens: AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: tokenType,
        expiresIn: expiresIn,
      ),
      user: user.toDomain(),
    );
  }
}

/// UserInfo DTO
class UserInfoDto {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 用户角色
  final String createdAt;
  final String updatedAt;

  UserInfoDto({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  UserInfo toDomain() {
    return UserInfo(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}
