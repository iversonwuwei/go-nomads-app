import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_token.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_user.dart';
import 'package:go_nomads_app/features/auth/domain/repositories/iauth_database_repository.dart';
import 'package:go_nomads_app/services/database/token_dao.dart';

/// 认证数据库仓储实现
///
/// 封装 TokenDao,提供 DDD 风格的数据库操作
class AuthDatabaseRepository implements IAuthDatabaseRepository {
  final TokenDao _tokenDao;

  AuthDatabaseRepository({TokenDao? tokenDao}) : _tokenDao = tokenDao ?? TokenDao();

  /// 执行数据库操作的通用方法
  Future<Result<T>> _execute<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Result.success(result);
    } catch (e) {
      return Result.failure(BusinessLogicException('数据库操作失败: $e'));
    }
  }

  @override
  Future<Result<void>> saveTokenToDatabase({
    required AuthToken token,
    required AuthUser user,
  }) async {
    return _execute(() async {
      await _tokenDao.saveToken(
        userId: user.id,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken ?? '',
        tokenType: token.tokenType,
        expiresIn: token.expiresIn,
        userName: user.name,
        userEmail: user.email,
      );
    });
  }

  @override
  Future<Result<TokenDatabaseData?>> getLatestToken() async {
    return _execute(() async {
      final tokenData = await _tokenDao.getLatestToken();
      if (tokenData == null) {
        return null;
      }
      return _mapToTokenDatabaseData(tokenData);
    });
  }

  @override
  Future<Result<TokenDatabaseData?>> getTokenByUserId(String userId) async {
    return _execute(() async {
      final tokenData = await _tokenDao.getTokenByUserId(userId);
      if (tokenData == null) {
        return null;
      }
      return _mapToTokenDatabaseData(tokenData);
    });
  }

  @override
  Future<Result<bool>> isTokenExpired(String userId) async {
    return _execute(() async {
      return await _tokenDao.isTokenExpired(userId);
    });
  }

  @override
  Future<Result<void>> deleteAllTokens() async {
    return _execute(() async {
      await _tokenDao.deleteAllTokens();
    });
  }

  @override
  Future<Result<void>> deleteTokenByUserId(String userId) async {
    return _execute(() async {
      await _tokenDao.deleteTokenByUserId(userId);
    });
  }

  @override
  Future<Result<void>> updateTokenByUserId(String userId, AuthToken token) async {
    return _execute(() async {
      await _tokenDao.updateToken(
        userId: userId,
        accessToken: token.accessToken,
        refreshToken: token.refreshToken ?? '',
        expiresIn: token.expiresIn,
      );
    });
  }

  /// 映射数据库数据到领域对象
  TokenDatabaseData _mapToTokenDatabaseData(Map<String, dynamic> data) {
    DateTime? expiresAt;
    final expiresAtStr = data['expires_at'] as String?;
    if (expiresAtStr != null && expiresAtStr.isNotEmpty) {
      try {
        expiresAt = DateTime.parse(expiresAtStr);
      } catch (e) {
        // 解析失败，保持为 null
      }
    }

    return TokenDatabaseData(
      userId: data['user_id'] as String,
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String? ?? '',
      tokenType: data['token_type'] as String? ?? 'Bearer',
      expiresIn: data['expires_in'] as int? ?? 3600,
      expiresAt: expiresAt,
      userName: data['user_name'] as String? ?? '',
      userEmail: data['user_email'] as String? ?? '',
    );
  }
}
