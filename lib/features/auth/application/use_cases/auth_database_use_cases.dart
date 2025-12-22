import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_database_repository.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_repository.dart';

/// 保存 Token 到数据库用例
class SaveTokenToDatabaseUseCase
    extends UseCase<void, SaveTokenToDatabaseParams> {
  final IAuthDatabaseRepository _databaseRepository;

  SaveTokenToDatabaseUseCase(this._databaseRepository);

  @override
  Future<Result<void>> execute(SaveTokenToDatabaseParams params) async {
    return await _databaseRepository.saveTokenToDatabase(
      token: params.token,
      user: params.user,
    );
  }
}

class SaveTokenToDatabaseParams {
  final AuthToken token;
  final AuthUser user;

  SaveTokenToDatabaseParams({
    required this.token,
    required this.user,
  });
}

/// 从数据库恢复 Token 用例
/// 
/// 注意: 此用例不会自动刷新过期的 token
/// 如果 token 已过期，会清除数据并返回 null
class RestoreTokenFromDatabaseUseCase extends UseCase<AuthToken?, NoParams> {
  final IAuthDatabaseRepository _databaseRepository;
  final IAuthRepository _authRepository;

  RestoreTokenFromDatabaseUseCase(
    this._databaseRepository,
    this._authRepository,
  );

  @override
  Future<Result<AuthToken?>> execute(NoParams params) async {
    try {
      // 1. 获取最新的 Token
      final tokenResult = await _databaseRepository.getLatestToken();

      return tokenResult.fold(
        onSuccess: (tokenData) async {
          if (tokenData == null) {
            return Result.success(null);
          }

          // 2. 检查是否过期
          final expiredResult =
              await _databaseRepository.isTokenExpired(tokenData.userId);

          return expiredResult.fold(
            onSuccess: (isExpired) async {
              if (isExpired) {
                // Token 已过期，清除数据并返回 null
                // 不自动刷新，让用户手动重新登录
                await _databaseRepository.deleteTokenByUserId(tokenData.userId);
                await _authRepository.clearPersistedToken();
                return Result.success(null);
              }

              // 3. 未过期,返回现有 Token
              final token = AuthToken(
                accessToken: tokenData.accessToken,
                refreshToken: tokenData.refreshToken,
              );

              // 4. 持久化到内存 (TokenStorageService)
              await _authRepository.persistToken(token);

              return Result.success(token);
            },
            onFailure: (error) => Result.failure(error),
          );
        },
        onFailure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(const BusinessLogicException('从数据库恢复Token失败'));
    }
  }
}

/// 检查登录状态 (优先从数据库)
/// 
/// 注意: 此用例在应用启动时调用，不会自动刷新过期的 token
/// 如果 token 已过期，会清除数据并返回 false（需要用户重新登录）
class CheckLoginStatusWithDatabaseUseCase extends UseCase<bool, NoParams> {
  final IAuthDatabaseRepository _databaseRepository;
  final IAuthRepository _authRepository;

  CheckLoginStatusWithDatabaseUseCase(
    this._databaseRepository,
    this._authRepository,
  );

  @override
  Future<Result<bool>> execute(NoParams params) async {
    try {
      // 1. 先检查内存中的 Token
      final isAuthInMemory = await _authRepository.isAuthenticated();

      if (isAuthInMemory) {
        return Result.success(true);
      }

      // 2. 内存中没有,尝试从数据库恢复
      final tokenResult = await _databaseRepository.getLatestToken();

      return tokenResult.fold(
        onSuccess: (tokenData) async {
          if (tokenData == null) {
            return Result.success(false);
          }

          // 3. 检查是否过期
          final expiredResult =
              await _databaseRepository.isTokenExpired(tokenData.userId);

          return expiredResult.fold(
            onSuccess: (isExpired) async {
              if (isExpired) {
                // Token 已过期，清除数据并返回未登录
                // 不自动刷新，让用户手动重新登录
                await _databaseRepository.deleteTokenByUserId(tokenData.userId);
                await _authRepository.clearPersistedToken();
                return Result.success(false);
              }

              // 5. 未过期,恢复到内存
              final token = AuthToken(
                accessToken: tokenData.accessToken,
                refreshToken: tokenData.refreshToken,
              );

              await _authRepository.persistToken(token);
              return Result.success(true);
            },
            onFailure: (error) => Result.failure(error),
          );
        },
        onFailure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(const BusinessLogicException('检查登录状态失败'));
    }
  }
}
