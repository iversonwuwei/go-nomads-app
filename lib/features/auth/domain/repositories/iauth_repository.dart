import '../../../../core/domain/result.dart';
import '../entities/auth_token.dart';
import '../entities/auth_user.dart';

/// 认证仓储接口
abstract class IAuthRepository {
  /// 登录
  Future<Result<AuthToken>> login({
    required String email,
    required String password,
  });

  /// 注册
  Future<Result<AuthToken>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  });

  /// 登出
  Future<Result<void>> logout();

  /// 刷新令牌
  Future<Result<AuthToken>> refreshToken(String refreshToken);

  /// 获取当前用户
  Future<Result<AuthUser>> getCurrentUser();

  /// 更新用户资料
  Future<Result<AuthUser>> updateUserProfile({
    String? name,
    String? phone,
    String? avatar,
  });

  /// 保存令牌到本地
  Future<Result<void>> persistToken(AuthToken token);

  /// 从本地获取令牌
  Future<Result<AuthToken?>> getPersistedToken();

  /// 清除本地令牌
  Future<Result<void>> clearPersistedToken();

  /// 检查是否已登录
  Future<bool> isAuthenticated();
}
