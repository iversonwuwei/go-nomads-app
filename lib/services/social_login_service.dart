import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:fluwx/fluwx.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tencent_kit/tencent_kit.dart';
import 'package:tobias/tobias.dart';
import 'package:url_launcher/url_launcher.dart';

import 'http_service.dart';
import 'social_sdk_service.dart';

/// 社交登录类型
enum SocialLoginType {
  wechat,
  alipay,
  qq,
  apple,
  google,
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
/// 封装微信、支付宝、QQ 等第三方登录的 SDK 调用
/// 注意：微信 SDK 的初始化由 SocialSdkService 在 main.dart 中完成
class SocialLoginService {
  final Fluwx _fluwx = Fluwx();
  final Tobias _tobias = Tobias();
  Completer<SocialLoginResult>? _authCompleter;
  Function(WeChatResponse response)? _authListener;
  StreamSubscription<TencentResp>? _qqLoginSubscription;

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
      // 检查微信是否已安装
      final isInstalled = await isWechatInstalled();
      if (!isInstalled) {
        return const SocialLoginResult.failure('请先安装微信');
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

  /// 检查支付宝是否已安装
  Future<bool> isAlipayInstalled() async {
    try {
      final installed = await _tobias.isAliPayInstalled;
      log('📱 [SocialLogin] 支付宝安装检测结果: $installed');
      return installed;
    } catch (e) {
      log('⚠️ [SocialLogin] 检测支付宝安装状态失败: $e');
      // 检测失败时返回 true，让 SDK 自己处理
      return true;
    }
  }

  /// 支付宝登录
  /// 使用 tobias 插件唤起支付宝授权
  Future<SocialLoginResult> loginWithAlipay() async {
    try {
      // 检查支付宝是否已安装
      final isInstalled = await isAlipayInstalled();
      log('📱 [SocialLogin] 支付宝安装状态: $isInstalled');

      if (!isInstalled) {
        return const SocialLoginResult.failure('请先安装支付宝');
      }

      log('📱 [SocialLogin] 开始支付宝登录...');

      // 从后端获取授权信息字符串
      final authInfo = await _getAlipayAuthInfo();
      if (authInfo == null) {
        return const SocialLoginResult.failure('获取支付宝授权信息失败');
      }

      log('📱 [SocialLogin] 获取到授权信息, 调起支付宝...');

      // 调用支付宝授权
      final result = await _tobias.auth(authInfo);

      log('📱 [SocialLogin] 支付宝授权返回: $result');

      // 解析授权结果
      final resultStatus = result['resultStatus']?.toString() ?? '';
      final resultStr = result['result']?.toString();

      if (resultStatus == '9000' && resultStr != null) {
        // 授权成功，解析 auth_code
        final authCode = _parseAlipayAuthCode(resultStr);
        if (authCode != null) {
          log('✅ [SocialLogin] 支付宝登录成功, auth_code=$authCode');
          return SocialLoginResult.success(code: authCode);
        } else {
          return const SocialLoginResult.failure('解析支付宝授权码失败');
        }
      } else if (resultStatus == '6001') {
        // 用户取消授权
        return const SocialLoginResult.cancelled();
      } else if (resultStatus == '4000') {
        return SocialLoginResult.failure(result['memo']?.toString() ?? '支付宝授权失败');
      } else {
        return SocialLoginResult.failure('支付宝授权失败: $resultStatus');
      }
    } catch (e) {
      log('❌ [SocialLogin] 支付宝登录异常: $e');
      return SocialLoginResult.failure('支付宝登录失败: $e');
    }
  }

  /// 从后端获取支付宝授权信息
  Future<String?> _getAlipayAuthInfo() async {
    try {
      final httpService = Get.find<HttpService>();
      final response = await httpService.get('/auth/alipay/auth-info');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['authInfo'] as String?;
      }
      return null;
    } catch (e) {
      log('❌ [SocialLogin] 获取支付宝授权信息失败: $e');
      return null;
    }
  }

  /// 解析支付宝授权结果中的 auth_code
  String? _parseAlipayAuthCode(String resultStr) {
    try {
      // 结果格式: success=true&auth_code=xxx&user_id=xxx
      final params = Uri.splitQueryString(resultStr);
      return params['auth_code'];
    } catch (e) {
      log('❌ [SocialLogin] 解析支付宝 auth_code 失败: $e');
      return null;
    }
  }

  /// 检查 QQ 是否已安装
  Future<bool> isQQInstalled() async {
    try {
      if (!SocialSdkService.isQQInitialized) {
        // 检查是否可以打开 QQ URL Scheme
        final qqUri = Uri.parse('mqq://');
        return await canLaunchUrl(qqUri);
      }
      return await TencentKitPlatform.instance.isQQInstalled();
    } catch (e) {
      return false;
    }
  }

  /// QQ 登录
  Future<SocialLoginResult> loginWithQQ() async {
    try {
      log('📱 [SocialLogin] 开始 QQ 登录...');

      // 检查 QQ SDK 是否初始化
      if (!SocialSdkService.isQQInitialized) {
        log('⚠️ [SocialLogin] QQ SDK 未初始化');
        return const SocialLoginResult.failure('QQ SDK 未初始化，请稍后重试');
      }

      // 检查 QQ 是否安装
      final isInstalled = await isQQInstalled();
      if (!isInstalled) {
        return const SocialLoginResult.failure('请先安装 QQ');
      }

      // 创建 Completer 等待登录结果
      _authCompleter = Completer<SocialLoginResult>();

      // 监听登录回调
      _qqLoginSubscription = TencentKitPlatform.instance.respStream().listen((resp) {
        if (resp is TencentLoginResp) {
          _onQQLoginResponse(resp);
        }
      });

      // 发起 QQ 登录
      await TencentKitPlatform.instance.login(scope: <String>[TencentScope.kGetSimpleUserInfo]);

      // 等待结果，设置超时
      final result = await _authCompleter!.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => const SocialLoginResult.failure('QQ 登录超时'),
      );

      // 清理监听器
      await _qqLoginSubscription?.cancel();
      _qqLoginSubscription = null;

      return result;
    } catch (e) {
      log('❌ [SocialLogin] QQ 登录异常: $e');
      await _qqLoginSubscription?.cancel();
      _qqLoginSubscription = null;
      return SocialLoginResult.failure('QQ 登录失败: $e');
    }
  }

  /// 处理 QQ 登录回调
  void _onQQLoginResponse(TencentLoginResp resp) {
    log('📱 [SocialLogin] QQ 登录回调: ret=${resp.ret}, msg=${resp.msg}');

    if (_authCompleter == null || _authCompleter!.isCompleted) {
      return;
    }

    // ret == 0 表示成功
    if (resp.ret == 0) {
      log('✅ [SocialLogin] QQ 登录成功: openid=${resp.openid}');
      _authCompleter!.complete(SocialLoginResult.success(
        openId: resp.openid,
        accessToken: resp.accessToken,
      ));
    } else if (resp.ret == -2) {
      // 用户取消
      log('ℹ️ [SocialLogin] 用户取消 QQ 登录');
      _authCompleter!.complete(const SocialLoginResult.cancelled());
    } else {
      log('❌ [SocialLogin] QQ 登录失败: ${resp.msg}');
      _authCompleter!.complete(SocialLoginResult.failure(resp.msg ?? 'QQ 登录失败'));
    }
  }

  /// Apple 登录 (仅 iOS)
  Future<SocialLoginResult> loginWithApple() async {
    if (!Platform.isIOS) {
      return const SocialLoginResult.failure('Apple 登录仅支持 iOS');
    }

    try {
      log('📱 [SocialLogin] Apple 登录功能开发中...');
      // 需要使用 sign_in_with_apple 插件
      return const SocialLoginResult.failure('Apple 登录功能开发中');
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
      case SocialLoginType.alipay:
        return loginWithAlipay();
      case SocialLoginType.qq:
        return loginWithQQ();
      case SocialLoginType.apple:
        return loginWithApple();
      case SocialLoginType.google:
        return loginWithGoogle();
    }
  }
}
