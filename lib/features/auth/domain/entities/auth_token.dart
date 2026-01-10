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

  /// 检查 token 是否已过期
  /// 
  /// 注意：如果 expiresAt 为 null，会基于 accessToken 是否为空来判断
  /// - 有 token 但无过期时间：视为未过期（兼容旧数据）
  /// - 无 token：视为过期
  bool get isExpired {
    if (accessToken.isEmpty) return true;
    if (expiresAt == null) {
      // 如果有 refresh token，视为可能需要刷新但不算过期
      // 让 needsRefresh 来处理刷新逻辑
      return false;
    }
    return DateTime.now().isAfter(expiresAt!);
  }

  /// 检查 token 是否需要刷新
  /// 
  /// 在以下情况返回 true：
  /// 1. expiresAt 为 null（无法确定过期时间）
  /// 2. 距离过期时间不足 5 分钟
  bool get needsRefresh {
    // 如果没有过期时间信息，需要刷新以获取新 token（带正确的过期时间）
    if (expiresAt == null) return true;
    // 提前5分钟刷新
    final refreshTime = expiresAt!.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(refreshTime);
  }

  /// 检查是否有有效的 refresh token
  bool get hasValidRefreshToken => 
    refreshToken != null && refreshToken!.isNotEmpty;

  @override
  String toString() {
    return 'AuthToken(accessToken: ${accessToken.substring(0, accessToken.length > 10 ? 10 : accessToken.length)}..., expiresAt: $expiresAt, needsRefresh: $needsRefresh)';
  }
}
