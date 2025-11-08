/// 认证令牌实体
class AuthToken {
  final String accessToken;
  final String? refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime? expiresAt;

  AuthToken({
    required this.accessToken,
    this.refreshToken,
    this.tokenType = 'Bearer',
    this.expiresIn = 3600,
    this.expiresAt,
  });

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get needsRefresh {
    if (expiresAt == null) return false;
    // 提前5分钟刷新
    final refreshTime = expiresAt!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }
}
