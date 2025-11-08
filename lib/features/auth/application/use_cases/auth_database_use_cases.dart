import '../../../../core/application/use_case.dart';
import '../../../../core/domain/result.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/iauth_database_repository.dart';
import '../../domain/repositories/iauth_repository.dart';

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
                // 3. 如果过期,尝试刷新
                final refreshResult = await _authRepository.refreshToken(
                  tokenData.refreshToken,
                );

                return refreshResult.fold(
                  onSuccess: (newToken) => Result.success(newToken),
                  onFailure: (error) => Result.success(null), // 刷新失败返回 null
                );
              }

              // 4. 未过期,返回现有 Token
              final token = AuthToken(
                accessToken: tokenData.accessToken,
                refreshToken: tokenData.refreshToken,
              );

              // 5. 持久化到内存 (TokenStorageService)
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
                // 4. 过期则尝试刷新
                final refreshResult = await _authRepository.refreshToken(
                  tokenData.refreshToken,
                );

                return refreshResult.fold(
                  onSuccess: (_) => Result.success(true),
                  onFailure: (_) => Result.success(false),
                );
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
