import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';

/// Token 数据库数据
class TokenDatabaseData {
  final String userId;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final DateTime? expiresAt;
  final String userName;
  final String userEmail;

  TokenDatabaseData({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    this.expiresAt,
    required this.userName,
    required this.userEmail,
  });

  /// 检查 token 是否已过期
  bool get isExpired {
    if (expiresAt == null) return true; // 没有过期时间视为需要刷新
    return DateTime.now().isAfter(expiresAt!);
  }
}

/// 认证数据库仓储接口
///
/// 负责 Token 的数据库持久化操作
abstract class IAuthDatabaseRepository {
  /// 保存 Token 到数据库
  ///
  /// 参数:
  /// - token: 认证令牌
  /// - user: 用户信息
  Future<Result<void>> saveTokenToDatabase({
    required AuthToken token,
    required AuthUser user,
  });

  /// 从数据库获取最新的 Token
  ///
  /// 返回: TokenDatabaseData 或 null
  Future<Result<TokenDatabaseData?>> getLatestToken();

  /// 根据用户ID获取 Token
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回: TokenDatabaseData 或 null
  Future<Result<TokenDatabaseData?>> getTokenByUserId(String userId);

  /// 检查 Token 是否过期
  ///
  /// 参数:
  /// - userId: 用户ID
  ///
  /// 返回: true=已过期, false=未过期
  Future<Result<bool>> isTokenExpired(String userId);

  /// 更新指定用户的 Token
  ///
  /// 参数:
  /// - userId: 用户ID
  /// - token: 新的认证令牌
  Future<Result<void>> updateTokenByUserId(String userId, AuthToken token);

  /// 删除所有 Token
  Future<Result<void>> deleteAllTokens();

  /// 删除指定用户的 Token
  ///
  /// 参数:
  /// - userId: 用户ID
  Future<Result<void>> deleteTokenByUserId(String userId);
}
