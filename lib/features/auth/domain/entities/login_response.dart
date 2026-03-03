/// LoginResponse 领域实体
class LoginResponse {
  final bool success;
  final String message;
  final LoginData? data;
  final List<String> errors;

  LoginResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors = const [],
  });

  bool get isSuccess => success && data != null;
  bool get hasErrors => errors.isNotEmpty;
}

/// LoginData 值对象
class LoginData {
  final AuthTokens tokens;
  final UserInfo user;

  LoginData({
    required this.tokens,
    required this.user,
  });
}

/// AuthTokens 值对象
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  /// Token是否即将过期 (剩余时间<5分钟)
  bool isExpiringSoon(DateTime loginTime) {
    final now = DateTime.now();
    final elapsed = now.difference(loginTime).inSeconds;
    final remaining = expiresIn - elapsed;
    return remaining < 300; // 5分钟
  }

  /// Token是否已过期
  bool isExpired(DateTime loginTime) {
    final now = DateTime.now();
    final elapsed = now.difference(loginTime).inSeconds;
    return elapsed >= expiresIn;
  }
}

/// UserInfo 值对象
class UserInfo {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role; // 用户角色
  final DateTime createdAt;
  final DateTime updatedAt;

  UserInfo({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasPhone => phone != null && phone!.isNotEmpty;
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
