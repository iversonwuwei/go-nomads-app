import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;

import 'package:crypto/crypto.dart';
import 'package:fluwx/fluwx.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tencent_kit/tencent_kit.dart';
import 'package:url_launcher/url_launcher.dart';

/// 社交登录类型
enum SocialLoginType {
  wechat,
  qq,
  apple,
  google,
  twitter,
}

/// 社交登录结果
class SocialLoginResult {
  final bool success;
  final String? code; // 授权码 (用于换取 access token)
  final String? openId; // 用户唯一标识
  final String? unionId; // 微信 UnionID (跨应用唯一标识)
  final String? accessToken; // 部分平台直接返回 token
  final String? nickname; // 昵称
  final String? avatarUrl; // 头像
  final String? errorMessage;
  final bool isCancelled; // 用户主动取消授权

  const SocialLoginResult({
    required this.success,
    this.code,
    this.openId,
    this.unionId,
    this.accessToken,
    this.nickname,
    this.avatarUrl,
    this.errorMessage,
    this.isCancelled = false,
  });

  const SocialLoginResult.success({
    this.code,
    this.openId,
    this.unionId,
    this.accessToken,
    this.nickname,
    this.avatarUrl,
  })  : success = true,
        errorMessage = null,
        isCancelled = false;

  const SocialLoginResult.failure(String message)
      : success = false,
        code = null,
        openId = null,
        unionId = null,
        accessToken = null,
        nickname = null,
        avatarUrl = null,
        errorMessage = message,
        isCancelled = false;

  /// 用户取消授权
  const SocialLoginResult.cancelled()
      : success = false,
        code = null,
        openId = null,
        unionId = null,
        accessToken = null,
        nickname = null,
        avatarUrl = null,
        errorMessage = '用户取消授权',
        isCancelled = true;
}

/// 社交登录服务
/// 封装微信、QQ 等第三方登录的 SDK 调用
/// 注意：微信 SDK 的初始化由 SocialSdkService 在 main.dart 中完成
class SocialLoginService {
  final Fluwx _fluwx = Fluwx();
  Completer<SocialLoginResult>? _authCompleter;
  Function(WeChatResponse response)? _authListener;

  /// 检查微信是否已安装
  Future<bool> isWechatInstalled() async {
    try {
      return await _fluwx.isWeChatInstalled;
    } catch (e) {
      return false;
    }
  }

  /// 微信登录
  /// 返回授权码 (code)，需要后端换取 access_token
  Future<SocialLoginResult> loginWithWechat() async {
    try {
      if (Platform.isIOS) {
        return const SocialLoginResult.failure('IOS_EXTERNAL_LOGIN_DISABLED');
      }

      // 检查微信是否已安装
      final isInstalled = await isWechatInstalled();
      if (!isInstalled) {
        log('⚠️ [SocialLogin] 微信未安装，终止登录流程');
        return const SocialLoginResult.failure('WECHAT_NOT_INSTALLED');
      }

      log('📱 [SocialLogin] 开始微信登录...');

      // 创建 Completer 等待授权结果
      _authCompleter = Completer<SocialLoginResult>();

      // 监听授权回调
      _authListener = (response) {
        if (response is WeChatAuthResponse) {
          _onWeChatAuthResponse(response);
        }
      };
      _fluwx.addSubscriber(_authListener!);

      // 发送授权请求
      final result = await _fluwx.authBy(
        which: NormalAuth(
          scope: 'snsapi_userinfo', // 获取用户信息权限
          state: 'gonomads_wechat_login_${DateTime.now().millisecondsSinceEpoch}',
        ),
      );

      if (!result) {
        _removeAuthListener();
        return const SocialLoginResult.failure('微信授权请求失败');
      }

      // 等待授权结果 (最长等待60秒)
      final authResult = await _authCompleter!.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          _removeAuthListener();
          return const SocialLoginResult.failure('微信授权超时');
        },
      );

      return authResult;
    } catch (e) {
      log('❌ [SocialLogin] 微信登录异常: $e');
      _removeAuthListener();
      return SocialLoginResult.failure('微信登录失败: $e');
    }
  }

  /// 处理微信授权回调
  void _onWeChatAuthResponse(WeChatAuthResponse authResponse) {
    log('📱 [SocialLogin] 微信授权回调: errCode=${authResponse.errCode}, errStr=${authResponse.errStr}');

    _removeAuthListener();

    if (_authCompleter == null || _authCompleter!.isCompleted) return;

    if (authResponse.errCode == 0 && authResponse.code != null) {
      log('✅ [SocialLogin] 微信登录成功, code=${authResponse.code}');
      _authCompleter!.complete(SocialLoginResult.success(code: authResponse.code));
    } else if (authResponse.errCode == -4) {
      // 用户拒绝授权
      _authCompleter!.complete(const SocialLoginResult.cancelled());
    } else if (authResponse.errCode == -2) {
      // 用户取消授权
      _authCompleter!.complete(const SocialLoginResult.cancelled());
    } else {
      _authCompleter!.complete(SocialLoginResult.failure(authResponse.errStr ?? '微信授权失败'));
    }
  }

  /// 移除授权监听器
  void _removeAuthListener() {
    if (_authListener != null) {
      _fluwx.removeSubscriber(_authListener!);
      _authListener = null;
    }
  }

  // ==================== QQ SDK (tencent_kit) ====================

  /// QQ SDK 配置
  static const String _qqAppId = '102822014';
  static const String _qqUniversalLink = 'https://go-nomads.com/universal_link/gonomads/qq_conn/102822014/';

  /// QQ SDK 登录响应订阅
  StreamSubscription<TencentResp>? _qqRespSubscription;

  /// QQ 登录结果 Completer
  Completer<SocialLoginResult>? _qqLoginCompleter;

  /// 初始化 QQ SDK
  /// 必须在使用 QQ 登录前调用（通常在 SocialSdkService.init() 中调用）
  Future<void> initQQSdk() async {
    try {
      // 3.1.0 之后的版本必须先获取权限/同意隐私协议
      await TencentKitPlatform.instance.setIsPermissionGranted(granted: true);
      await TencentKitPlatform.instance.registerApp(
        appId: _qqAppId,
        universalLink: _qqUniversalLink,
      );
      log('✅ [SocialLogin] QQ SDK 初始化成功');
    } catch (e) {
      log('❌ [SocialLogin] QQ SDK 初始化失败: $e');
    }
  }

  /// 检查 QQ 是否已安装
  Future<bool> isQQInstalled() async {
    try {
      final installed = await TencentKitPlatform.instance.isQQInstalled();
      log('📱 [SocialLogin] QQ 安装检测结果: $installed');
      return installed;
    } catch (e) {
      log('⚠️ [SocialLogin] 检测 QQ 安装状态失败: $e');
      return false;
    }
  }

  /// QQ 登录
  /// 使用官方 QQ SDK (tencent_kit) 进行登录
  /// SDK 会自动唤起 QQ App 进行授权，返回 accessToken + openId
  Future<SocialLoginResult> loginWithQQ() async {
    try {
      if (Platform.isIOS) {
        return const SocialLoginResult.failure('IOS_EXTERNAL_LOGIN_DISABLED');
      }

      log('📱 [SocialLogin] 开始 QQ 登录 (SDK)...');

      // 检查 QQ 是否已安装
      final isInstalled = await isQQInstalled();
      log('📱 [SocialLogin] QQ 安装状态: $isInstalled');

      if (!isInstalled) {
        log('⚠️ [SocialLogin] QQ 未安装，终止登录流程');
        return const SocialLoginResult.failure('QQ_NOT_INSTALLED');
      }

      // 创建 Completer 等待 SDK 回调
      _qqLoginCompleter = Completer<SocialLoginResult>();

      // 监听 QQ SDK 响应
      _qqRespSubscription?.cancel();
      _qqRespSubscription = TencentKitPlatform.instance.respStream().listen(
        _onQQLoginResponse,
        onError: (error) {
          log('❌ [SocialLogin] QQ SDK 响应流错误: $error');
          if (_qqLoginCompleter != null && !_qqLoginCompleter!.isCompleted) {
            _qqLoginCompleter!.complete(SocialLoginResult.failure('QQ SDK 错误: $error'));
          }
          _cleanupQQLogin();
        },
      );

      // 调用 QQ SDK 登录
      await TencentKitPlatform.instance.login(
        scope: <String>[TencentScope.kGetSimpleUserInfo],
      );

      // 等待 SDK 回调结果（最长等待 3 分钟）
      final result = await _qqLoginCompleter!.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          _cleanupQQLogin();
          return const SocialLoginResult.failure('QQ 授权超时');
        },
      );

      return result;
    } catch (e) {
      log('❌ [SocialLogin] QQ 登录异常: $e');
      _cleanupQQLogin();
      return SocialLoginResult.failure('QQ 登录失败: $e');
    }
  }

  /// 处理 QQ SDK 登录响应
  void _onQQLoginResponse(TencentResp resp) {
    log('📱 [SocialLogin] QQ SDK 响应: ${resp.runtimeType}');

    if (resp is TencentLoginResp) {
      if (_qqLoginCompleter == null || _qqLoginCompleter!.isCompleted) {
        log('⚠️ [SocialLogin] QQ 登录 Completer 不存在或已完成');
        return;
      }

      if (resp.isSuccessful) {
        log('✅ [SocialLogin] QQ SDK 登录成功, openId=${resp.openid}, accessToken=${resp.accessToken != null ? '已获取' : '无'}');
        _qqLoginCompleter!.complete(SocialLoginResult.success(
          accessToken: resp.accessToken,
          openId: resp.openid,
        ));
      } else if (resp.isCancelled) {
        log('📱 [SocialLogin] 用户取消 QQ 授权');
        _qqLoginCompleter!.complete(const SocialLoginResult.cancelled());
      } else {
        log('❌ [SocialLogin] QQ SDK 登录失败: ret=${resp.ret}, msg=${resp.msg}');
        _qqLoginCompleter!.complete(
          SocialLoginResult.failure('QQ 登录失败: ${resp.msg ?? '未知错误'}'),
        );
      }

      _cleanupQQLogin();
    }
  }

  /// 清理 QQ 登录相关资源
  void _cleanupQQLogin() {
    _qqRespSubscription?.cancel();
    _qqRespSubscription = null;
    _qqLoginCompleter = null;
  }

  /// Apple 登录 (仅 iOS)
  ///
  /// 使用 Sign in with Apple SDK 进行 OAuth 授权。
  /// Apple 首次登录返回 identityToken + authorizationCode + 用户信息(name/email)，
  /// 后续登录只返回 identityToken + authorizationCode，不再返回用户信息。
  Future<SocialLoginResult> loginWithApple() async {
    if (!Platform.isIOS) {
      return const SocialLoginResult.failure('Apple 登录仅支持 iOS');
    }

    try {
      log('📱 [SocialLogin] 开始 Apple 登录...');

      // 检查 Apple Sign In 是否可用
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        log('⚠️ [SocialLogin] Apple Sign In 不可用');
        return const SocialLoginResult.failure('Apple Sign In 不可用');
      }

      // 发起 Apple 授权请求
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      log('✅ [SocialLogin] Apple 授权成功, userIdentifier=${credential.userIdentifier}');

      // 拼接用户名（Apple 仅在首次授权时返回姓名）
      String? displayName;
      if (credential.givenName != null || credential.familyName != null) {
        displayName = [credential.familyName, credential.givenName]
            .where((s) => s != null && s.isNotEmpty)
            .join(' ')
            .trim();
        if (displayName.isEmpty) displayName = null;
      }

      return SocialLoginResult.success(
        code: credential.authorizationCode, // 授权码，后端用于验证/换取 token
        accessToken: credential.identityToken, // JWT identity token
        openId: credential.userIdentifier, // Apple 用户唯一标识
        nickname: displayName,
      );
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        log('📱 [SocialLogin] 用户取消 Apple 授权');
        return const SocialLoginResult.cancelled();
      }
      log('❌ [SocialLogin] Apple 授权异常: ${e.code} - ${e.message}');
      return SocialLoginResult.failure('Apple 登录失败: ${e.message}');
    } catch (e) {
      log('❌ [SocialLogin] Apple 登录异常: $e');
      return SocialLoginResult.failure('Apple 登录失败: $e');
    }
  }

  /// Google 登录
  Future<SocialLoginResult> loginWithGoogle() async {
    try {
      log('📱 [SocialLogin] 开始 Google 登录...');

      // 初始化 GoogleSignIn
      // Android: 使用 web client ID 作为 serverClientId（后端验证用）
      // iOS: 使用 iOS client ID 作为 clientId，web client ID 作为 serverClientId
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? '856428781735-al5ljiii3u1i3dk3jj60sfsbntusc5of.apps.googleusercontent.com' : null,
        serverClientId: '856428781735-fpunl6qfqeajp9a5ol7lkpk6485u765c.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      // 先尝试静默登录
      GoogleSignInAccount? account = await googleSignIn.signInSilently();
      account ??= await googleSignIn.signIn();

      if (account == null) {
        // 用户取消了登录
        return const SocialLoginResult.cancelled();
      }

      log('✅ [SocialLogin] Google 授权成功: ${account.email}');

      // 获取认证信息
      final GoogleSignInAuthentication auth = await account.authentication;
      final String? idToken = auth.idToken;
      final String? accessToken = auth.accessToken;

      if (idToken == null && accessToken == null) {
        return const SocialLoginResult.failure('获取 Google 授权令牌失败');
      }

      log('✅ [SocialLogin] Google 登录成功, idToken=${idToken != null ? '已获取' : '无'}, accessToken=${accessToken != null ? '已获取' : '无'}');

      return SocialLoginResult.success(
        code: idToken, // idToken 发送给后端验证
        accessToken: accessToken,
        openId: account.id,
        nickname: account.displayName,
        avatarUrl: account.photoUrl,
      );
    } catch (e) {
      log('❌ [SocialLogin] Google 登录异常: $e');
      return SocialLoginResult.failure('Google 登录失败: $e');
    }
  }

  /// 通用社交登录入口
  Future<SocialLoginResult> login(SocialLoginType type) async {
    switch (type) {
      case SocialLoginType.wechat:
        return loginWithWechat();
      case SocialLoginType.qq:
        return loginWithQQ();
      case SocialLoginType.apple:
        return loginWithApple();
      case SocialLoginType.google:
        return loginWithGoogle();
      case SocialLoginType.twitter:
        return loginWithTwitter();
    }
  }

  // ==================== Twitter OAuth 2.0 PKCE ====================

  /// Twitter OAuth 2.0 配置
  static const String _twitterClientId = 'IS69TLExRq4TnkQNx3BELNHmq';
  static const String _twitterRedirectUri = 'gonomads://twitter-callback';
  static const String _twitterAuthUrl = 'https://twitter.com/i/oauth2/authorize';
  static const String _twitterScopes = 'tweet.read%20users.read%20offline.access';

  /// 临时存储 PKCE code_verifier，在回调时使用
  String? _twitterCodeVerifier;

  /// Twitter 登录
  /// 使用 OAuth 2.0 Authorization Code with PKCE 流程
  Future<SocialLoginResult> loginWithTwitter() async {
    try {
      log('📦 [SocialLogin] 开始 Twitter 登录 (OAuth 2.0 PKCE)...');

      // 1. 生成 PKCE 参数
      final codeVerifier = _generateCodeVerifier();
      final codeChallenge = _generateCodeChallenge(codeVerifier);
      _twitterCodeVerifier = codeVerifier;

      // 2. 生成 state 参数（防止 CSRF）
      final state = 'gonomads_twitter_${DateTime.now().millisecondsSinceEpoch}';

      // 3. 构建授权 URL
      final authorizationUrl = Uri.parse(
        '$_twitterAuthUrl'
        '?response_type=code'
        '&client_id=$_twitterClientId'
        '&redirect_uri=${Uri.encodeComponent(_twitterRedirectUri)}'
        '&scope=$_twitterScopes'
        '&state=$state'
        '&code_challenge=$codeChallenge'
        '&code_challenge_method=S256',
      );

      log('📦 [SocialLogin] Twitter 授权 URL: $authorizationUrl');

      // 4. 打开浏览器进行授权
      if (!await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication)) {
        return const SocialLoginResult.failure('Failed to open Twitter authorization page');
      }

      // 5. 等待回调（通过 deep link 返回）
      // 回调将通过 handleTwitterCallback 处理
      // 创建 Completer 等待回调结果
      _twitterAuthCompleter = Completer<SocialLoginResult>();

      final result = await _twitterAuthCompleter!.future.timeout(
        const Duration(minutes: 3),
        onTimeout: () {
          _twitterCodeVerifier = null;
          _twitterAuthCompleter = null;
          return const SocialLoginResult.failure('Twitter 授权超时');
        },
      );

      return result;
    } catch (e) {
      log('❌ [SocialLogin] Twitter 登录异常: $e');
      _twitterCodeVerifier = null;
      _twitterAuthCompleter = null;
      return SocialLoginResult.failure('Twitter 登录失败: $e');
    }
  }

  /// Twitter OAuth 回调 Completer
  Completer<SocialLoginResult>? _twitterAuthCompleter;

  /// 处理 Twitter OAuth 回调
  /// 当 app 通过 deep link 收到 gonomads://twitter-callback?code=xxx&state=xxx 时调用
  void handleTwitterCallback(Uri uri) {
    log('📦 [SocialLogin] Twitter 回调: $uri');

    if (_twitterAuthCompleter == null || _twitterAuthCompleter!.isCompleted) {
      log('⚠️ [SocialLogin] Twitter 回调无效: Completer 不存在或已完成');
      return;
    }

    final code = uri.queryParameters['code'];
    final error = uri.queryParameters['error'];

    if (error != null) {
      log('❌ [SocialLogin] Twitter 授权失败: $error');
      if (error == 'access_denied') {
        _twitterAuthCompleter!.complete(const SocialLoginResult.cancelled());
      } else {
        _twitterAuthCompleter!.complete(SocialLoginResult.failure('Twitter 授权失败: $error'));
      }
      _twitterCodeVerifier = null;
      _twitterAuthCompleter = null;
      return;
    }

    if (code == null || code.isEmpty) {
      _twitterAuthCompleter!.complete(const SocialLoginResult.failure('未获取到 Twitter 授权码'));
      _twitterCodeVerifier = null;
      _twitterAuthCompleter = null;
      return;
    }

    log('✅ [SocialLogin] Twitter 授权码获取成功');

    // code 放在 code 字段，code_verifier 放在 accessToken 字段
    // 后端会用 code + code_verifier 换取 access_token 并获取用户信息
    _twitterAuthCompleter!.complete(SocialLoginResult.success(
      code: code,
      accessToken: _twitterCodeVerifier, // 复用 accessToken 字段传递 code_verifier
    ));

    _twitterCodeVerifier = null;
    _twitterAuthCompleter = null;
  }

  /// 生成 PKCE code_verifier (43-128 字符的随机字符串)
  String _generateCodeVerifier() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  /// 生成 PKCE code_challenge (S256)
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }
}
