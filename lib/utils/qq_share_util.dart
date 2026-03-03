import 'dart:async';
import 'dart:developer';

import 'package:share_plus/share_plus.dart';
import 'package:tencent_kit/tencent_kit.dart';

/// QQ 分享工具类
/// 使用官方 QQ SDK (tencent_kit) 实现分享到 QQ 好友和 QQ 空间
class QQShareUtil {
  /// 分享网页到 QQ 好友
  static Future<bool> shareToQQFriend({
    required String url,
    required String title,
    String? summary,
    Uri? imageUri,
  }) async {
    try {
      log('📤 QQShareUtil: 开始分享到 QQ 好友');

      // 检查 QQ 是否已安装
      final isInstalled = await TencentKitPlatform.instance.isQQInstalled();
      if (!isInstalled) {
        log('⚠️ QQShareUtil: QQ 未安装，回退到系统分享');
        await Share.share('$title\n$url');
        return false;
      }

      await TencentKitPlatform.instance.shareWebpage(
        scene: TencentScene.kScene_QQ,
        title: title,
        summary: summary,
        imageUri: imageUri,
        targetUrl: url,
      );

      log('✅ QQShareUtil: QQ 好友分享调用成功');
      return true;
    } catch (e) {
      log('❌ QQShareUtil: QQ 好友分享失败: $e，回退到系统分享');
      await Share.share('$title\n$url');
      return false;
    }
  }

  /// 分享网页到 QQ 空间
  static Future<bool> shareToQzone({
    required String url,
    required String title,
    String? summary,
    Uri? imageUri,
  }) async {
    try {
      log('📤 QQShareUtil: 开始分享到 QQ 空间');

      // 检查 QQ 是否已安装
      final isInstalled = await TencentKitPlatform.instance.isQQInstalled();
      if (!isInstalled) {
        log('⚠️ QQShareUtil: QQ 未安装，回退到系统分享');
        await Share.share('$title\n$url');
        return false;
      }

      await TencentKitPlatform.instance.shareWebpage(
        scene: TencentScene.kScene_QZone,
        title: title,
        summary: summary,
        imageUri: imageUri,
        targetUrl: url,
        extInt: TencentQZoneFlag.kAutoOpen,
      );

      log('✅ QQShareUtil: QQ 空间分享调用成功');
      return true;
    } catch (e) {
      log('❌ QQShareUtil: QQ 空间分享失败: $e，回退到系统分享');
      await Share.share('$title\n$url');
      return false;
    }
  }

  /// 分享图片到 QQ 好友
  static Future<bool> shareImageToQQ({
    required Uri imageUri,
    String? appName,
  }) async {
    try {
      log('📤 QQShareUtil: 开始分享图片到 QQ');

      final isInstalled = await TencentKitPlatform.instance.isQQInstalled();
      if (!isInstalled) {
        log('⚠️ QQShareUtil: QQ 未安装');
        return false;
      }

      await TencentKitPlatform.instance.shareImage(
        scene: TencentScene.kScene_QQ,
        imageUri: imageUri,
        appName: appName,
      );

      log('✅ QQShareUtil: QQ 图片分享调用成功');
      return true;
    } catch (e) {
      log('❌ QQShareUtil: QQ 图片分享失败: $e');
      return false;
    }
  }

  /// 分享文本到 QQ 好友
  static Future<bool> shareTextToQQ({
    required String text,
  }) async {
    try {
      log('📤 QQShareUtil: 开始分享文本到 QQ');

      final isInstalled = await TencentKitPlatform.instance.isQQInstalled();
      if (!isInstalled) {
        log('⚠️ QQShareUtil: QQ 未安装，回退到系统分享');
        await Share.share(text);
        return false;
      }

      await TencentKitPlatform.instance.shareText(
        scene: TencentScene.kScene_QQ,
        summary: text,
      );

      log('✅ QQShareUtil: QQ 文本分享调用成功');
      return true;
    } catch (e) {
      log('❌ QQShareUtil: QQ 文本分享失败: $e');
      await Share.share(text);
      return false;
    }
  }
}
