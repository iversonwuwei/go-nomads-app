import 'package:go_nomads_app/core/application/use_case.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_token.dart';
import 'package:go_nomads_app/features/auth/domain/entities/auth_user.dart';
import 'package:go_nomads_app/features/auth/domain/repositories/iauth_repository.dart';

/// 登录用例
class LoginUseCase extends UseCase<AuthToken, LoginParams> {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  @override
  Future<Result<AuthToken>> execute(LoginParams params) async {
    return await _repository.login(
      email: params.email,
      password: params.password,
    );
  }
}

class LoginParams {
  final String email;
  final String password;

  LoginParams({
    required this.email,
    required this.password,
  });
}

/// 注册用例
class RegisterUseCase extends UseCase<AuthToken, RegisterParams> {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  @override
  Future<Result<AuthToken>> execute(RegisterParams params) async {
    // 验证密码确认
    if (params.password != params.confirmPassword) {
      return Failure(ValidationException('两次输入的密码不一致'));
    }

    return await _repository.register(
      name: params.name,
      email: params.email,
      password: params.password,
      verificationCode: params.verificationCode,
      phone: params.phone,
    );
  }
}

class RegisterParams {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;
  final String verificationCode;
  final String? phone;

  RegisterParams({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.verificationCode,
    this.phone,
  });
}

/// 登出用例
class LogoutUseCase extends UseCase<void, NoParams> {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  @override
  Future<Result<void>> execute(NoParams params) async {
    return await _repository.logout();
  }
}

/// 刷新令牌用例
class RefreshTokenUseCase extends UseCase<AuthToken, String> {
  final IAuthRepository _repository;

  RefreshTokenUseCase(this._repository);

  @override
  Future<Result<AuthToken>> execute(String refreshToken) async {
    return await _repository.refreshToken(refreshToken);
  }
}

/// 获取当前用户用例
class GetCurrentUserUseCase extends UseCase<AuthUser, NoParams> {
  final IAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<Result<AuthUser>> execute(NoParams params) async {
    return await _repository.getCurrentUser();
  }
}

/// 更新用户资料用例
class UpdateUserProfileUseCase extends UseCase<AuthUser, UpdateUserProfileParams> {
  final IAuthRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  @override
  Future<Result<AuthUser>> execute(UpdateUserProfileParams params) async {
    return await _repository.updateUserProfile(
      name: params.name,
      phone: params.phone,
      avatar: params.avatar,
    );
  }
}

class UpdateUserProfileParams {
  final String? name;
  final String? phone;
  final String? avatar;

  UpdateUserProfileParams({
    this.name,
    this.phone,
    this.avatar,
  });
}

/// 检查认证状态用例
class CheckAuthStatusUseCase extends UseCase<bool, NoParams> {
  final IAuthRepository _repository;

  CheckAuthStatusUseCase(this._repository);

  @override
  Future<Result<bool>> execute(NoParams params) async {
    final isAuth = await _repository.isAuthenticated();
    return Success(isAuth);
  }
}

/// 自动刷新令牌用例(如果需要)
class AutoRefreshTokenUseCase extends UseCase<AuthToken?, NoParams> {
  final IAuthRepository _repository;

  AutoRefreshTokenUseCase(this._repository);

  @override
  Future<Result<AuthToken?>> execute(NoParams params) async {
    final tokenResult = await _repository.getPersistedToken();

    return tokenResult.fold(
      onSuccess: (token) async {
        if (token == null) return Success(null);

        if (token.needsRefresh && token.refreshToken != null) {
          return await _repository.refreshToken(token.refreshToken!);
        }

        return Success(token);
      },
      onFailure: (error) => Failure(error),
    );
  }
}

/// 社交登录用例
class SocialLoginUseCase extends UseCase<AuthToken, SocialLoginParams> {
  final IAuthRepository _repository;

  SocialLoginUseCase(this._repository);

  @override
  Future<Result<AuthToken>> execute(SocialLoginParams params) async {
    return await _repository.socialLogin(
      provider: params.provider,
      code: params.code,
      accessToken: params.accessToken,
      openId: params.openId,
    );
  }
}

class SocialLoginParams {
  final SocialAuthProvider provider;
  final String? code;
  final String? accessToken;
  final String? openId;

  SocialLoginParams({
    required this.provider,
    this.code,
    this.accessToken,
    this.openId,
  });
}
