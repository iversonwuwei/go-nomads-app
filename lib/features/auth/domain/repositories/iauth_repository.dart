import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_token.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_user.dart';

/// 社交登录类型
enum SocialAuthProvider {
  wechat,
  alipay,
  qq,
  apple,
  google,
}

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

  /// 社交登录
  /// [provider] 社交平台类型
  /// [code] 授权码（微信、QQ 等使用）
  /// [accessToken] 直接的访问令牌（部分平台使用）
  /// [openId] 用户唯一标识
  Future<Result<AuthToken>> socialLogin({
    required SocialAuthProvider provider,
    String? code,
    String? accessToken,
    String? openId,
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
