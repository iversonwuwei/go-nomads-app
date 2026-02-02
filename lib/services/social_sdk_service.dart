import 'dart:developer';

import 'package:fluwx/fluwx.dart';
import 'package:tencent_kit/tencent_kit.dart';

/// 社交 SDK 初始化服务
/// 用于初始化微信、QQ、微博等社交分享 SDK
class SocialSdkService {
  // ========== 配置项（需替换为真实 AppId） ==========

  /// 微信 AppId（从微信开放平台获取）
  static const String wechatAppId = 'wx3b333eed7c75a444';
  static const String wechatAppSecret = 'f08880d46d4a045398f81cff206ef5b6'; // 仅用于后端，客户端不要直接使用
  static const String wechatUniversalLink = 'https://go-nomads.com/app/';

  /// QQ AppId（从腾讯开放平台获取）
  static const String qqAppId = '102822014';

  /// 微博 AppKey 和 UniversalLink（从微博开放平台获取）
  static const String weiboAppKey = 'YOUR_WEIBO_APP_KEY';
  static const String weiboUniversalLink = 'https://gonomads.app/weibo/';
  static const String weiboRedirectUrl = 'https://api.weibo.com/oauth2/default.html';

  /// QQ SDK 是否已初始化
  static bool _qqInitialized = false;

  // ========== 初始化方法 ==========

  /// 初始化所有社交 SDK
  static Future<void> init() async {
    await _initWechat();
    await _initQQ();
  }

  /// 初始化微信 SDK
  static Future<void> _initWechat() async {
    if (wechatAppId == 'YOUR_WECHAT_APP_ID') {
      log('⚠️ 微信 AppId 未配置，跳过初始化');
      return;
    }
    try {
      final fluwxInstance = Fluwx();
      await fluwxInstance.registerApi(
        appId: wechatAppId,
        universalLink: wechatUniversalLink,
      );
      log('✅ 微信 SDK 初始化成功');
    } catch (e) {
      log('❌ 微信 SDK 初始化失败: $e');
    }
  }

  /// 初始化 QQ SDK
  static Future<void> _initQQ() async {
    if (qqAppId == 'YOUR_QQ_APP_ID') {
      log('⚠️ QQ AppId 未配置，跳过初始化');
      return;
    }
    try {
      // 重要：必须先调用 setIsPermissionGranted，再调用 registerApp
      await TencentKitPlatform.instance.setIsPermissionGranted(granted: true);
      await TencentKitPlatform.instance.registerApp(appId: qqAppId);
      _qqInitialized = true;
      log('✅ QQ SDK 初始化成功');
    } catch (e) {
      log('❌ QQ SDK 初始化失败: $e');
    }
  }

  /// QQ SDK 是否已初始化
  static bool get isQQInitialized => _qqInitialized;

  // ========== 检查是否已安装 ==========

  /// 检查微信是否已安装
  static Future<bool> isWechatInstalled() async {
    try {
      final fluwxInstance = Fluwx();
      return await fluwxInstance.isWeChatInstalled;
    } catch (e) {
      return false;
    }
  }

  /// 检查 QQ 是否已安装
  static Future<bool> isQQInstalled() async {
    try {
      if (!_qqInitialized) {
        return false;
      }
      return await TencentKitPlatform.instance.isQQInstalled();
    } catch (e) {
      return false;
    }
  }

  /// 检查微博是否已安装（网页分享不需要检查）
  static Future<bool> isWeiboInstalled() async {
    return true; // 网页分享始终可用
  }
}
