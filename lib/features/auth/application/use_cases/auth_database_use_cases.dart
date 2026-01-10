import 'dart:developer';

import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_token.dart';
import 'package:df_admin_mobile/features/auth/domain/entities/auth_user.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_database_repository.dart';
import 'package:df_admin_mobile/features/auth/domain/repositories/iauth_repository.dart';

/// 保存 Token 到数据库用例
class SaveTokenToDatabaseUseCase extends UseCase<void, SaveTokenToDatabaseParams> {
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
/// ⭐ 优化：当 access_token 过期时，会尝试使用 refresh_token 自动刷新
/// 只有在刷新失败时才会清除数据并返回 null
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
          final expiredResult = await _databaseRepository.isTokenExpired(tokenData.userId);

          return expiredResult.fold(
            onSuccess: (isExpired) async {
              if (isExpired) {
                // ⭐ Token 已过期，尝试使用 refresh_token 自动刷新
                if (tokenData.refreshToken.isNotEmpty) {
                  final refreshResult = await _authRepository.refreshToken(tokenData.refreshToken);

                  return refreshResult.fold(
                    onSuccess: (newToken) async {
                      // 刷新成功，更新持久化存储（SharedPreferences）
                      await _authRepository.persistToken(newToken);
                      // 同时更新数据库（SQLite）
                      await _databaseRepository.updateTokenByUserId(tokenData.userId, newToken);
                      return Result.success(newToken);
                    },
                    onFailure: (_) async {
                      // 刷新失败，清除数据并返回 null
                      await _databaseRepository.deleteTokenByUserId(tokenData.userId);
                      await _authRepository.clearPersistedToken();
                      return Result.success(null);
                    },
                  );
                }

                // 没有 refresh_token，清除数据并返回 null
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
/// ⭐ 优化：当 access_token 过期时，会尝试使用 refresh_token 自动刷新
/// 只有在刷新失败时才会清除数据并返回 false（需要用户重新登录）
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
      log('🔐 [CheckLoginStatus] 开始检查登录状态...');
      
      // 1. 先检查内存中的 Token
      final isAuthInMemory = await _authRepository.isAuthenticated();
      log('   内存中是否有有效 Token: $isAuthInMemory');

      if (isAuthInMemory) {
        log('✅ [CheckLoginStatus] 内存中 Token 有效，已登录');
        return Result.success(true);
      }

      // 2. 内存中没有,尝试从数据库恢复
      log('   内存中无 Token，尝试从 SQLite 恢复...');
      final tokenResult = await _databaseRepository.getLatestToken();

      return tokenResult.fold(
        onSuccess: (tokenData) async {
          if (tokenData == null) {
            log('⚠️ [CheckLoginStatus] SQLite 中没有 Token，用户未登录');
            return Result.success(false);
          }

          log('   从 SQLite 找到 Token: userId=${tokenData.userId}');
          log('   expiresAt: ${tokenData.expiresAt}');
          
          // 3. 使用 TokenDatabaseData 自带的 isExpired 检查
          final isExpired = tokenData.isExpired;
          log('   Token 是否过期: $isExpired');

          if (isExpired) {
            log('   Token 已过期，尝试使用 refresh_token 刷新...');
            // ⭐ Token 已过期，尝试使用 refresh_token 自动刷新
            if (tokenData.refreshToken.isNotEmpty) {
              final refreshResult = await _authRepository.refreshToken(tokenData.refreshToken);

              return refreshResult.fold(
                onSuccess: (newToken) async {
                  log('✅ [CheckLoginStatus] Token 刷新成功');
                  // 刷新成功，更新持久化存储（SharedPreferences）
                  await _authRepository.persistToken(newToken);
                  // 同时更新数据库（SQLite）
                  await _databaseRepository.updateTokenByUserId(tokenData.userId, newToken);
                  return Result.success(true);
                },
                onFailure: (error) async {
                  log('❌ [CheckLoginStatus] Token 刷新失败: $error');
                  // 刷新失败，清除数据并返回未登录
                  await _databaseRepository.deleteTokenByUserId(tokenData.userId);
                  await _authRepository.clearPersistedToken();
                  return Result.success(false);
                },
              );
            }

            log('   无 refresh_token，清除数据');
            // 没有 refresh_token，清除数据并返回未登录
            await _databaseRepository.deleteTokenByUserId(tokenData.userId);
            await _authRepository.clearPersistedToken();
            return Result.success(false);
          }

          // 4. 未过期,恢复到内存（包含完整的过期时间信息）
          log('✅ [CheckLoginStatus] Token 未过期，恢复到内存');
          final token = AuthToken(
            accessToken: tokenData.accessToken,
            refreshToken: tokenData.refreshToken,
            tokenType: tokenData.tokenType,
            expiresIn: tokenData.expiresIn,
            expiresAt: tokenData.expiresAt,
          );

          await _authRepository.persistToken(token);
          log('✅ [CheckLoginStatus] Token 已恢复，用户已登录');
          return Result.success(true);
        },
        onFailure: (error) {
          log('❌ [CheckLoginStatus] 从 SQLite 获取 Token 失败: $error');
          return Result.failure(error);
        },
      );
    } catch (e) {
      log('❌ [CheckLoginStatus] 检查登录状态异常: $e');
      return Result.failure(const BusinessLogicException('检查登录状态失败'));
    }
  }
}
