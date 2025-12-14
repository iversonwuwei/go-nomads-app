import 'dart:developer';

import 'package:fluwx/fluwx.dart';

/// 社交 SDK 初始化服务
/// 用于初始化微信、QQ、微博等社交分享 SDK
class SocialSdkService {
  // ========== 配置项（需替换为真实 AppId） ==========

  /// 微信 AppId（从微信开放平台获取）
  static const String wechatAppId = 'wxb80dc89113bb023d';
  static const String wechatUniversalLink = 'https://gonomads.app/wechat/';

  /// QQ AppId（从腾讯开放平台获取）
  static const String qqAppId = 'Ut68vSr2ye4FJ9j6';

  /// 微博 AppKey 和 UniversalLink（从微博开放平台获取）
  static const String weiboAppKey = 'YOUR_WEIBO_APP_KEY';
  static const String weiboUniversalLink = 'https://gonomads.app/weibo/';
  static const String weiboRedirectUrl = 'https://api.weibo.com/oauth2/default.html';

  // ========== 初始化方法 ==========

  /// 初始化所有社交 SDK
  static Future<void> init() async {
    await _initWechat();
    // QQ 和微博使用网页分享，无需初始化 SDK
    log('ℹ️ QQ 和微博使用网页分享方式，无需初始化 SDK');
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

  /// 检查 QQ 是否已安装（网页分享不需要检查）
  static Future<bool> isQQInstalled() async {
    return true; // 网页分享始终可用
  }

  /// 检查微博是否已安装（网页分享不需要检查）
  static Future<bool> isWeiboInstalled() async {
    return true; // 网页分享始终可用
  }
}
