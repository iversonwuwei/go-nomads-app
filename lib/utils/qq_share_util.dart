import 'dart:developer';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class QQShareUtil {
  /// 分享卡片到QQ好友（优先唤醒App，失败后回退网页版）
  static Future<void> shareToQQFriend({
    required String url,
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    log('📤 QQShareUtil: 开始分享到QQ好友');
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(title);
    final encodedDesc = Uri.encodeComponent(description);

    // 优先尝试唤醒 QQ App
    final appUrl =
        Uri.parse('mqq://share/to_fri?src_type=web&url=$encodedUrl&title=$encodedTitle&description=$encodedDesc');
    log('📤 QQShareUtil: 尝试唤醒QQ App: $appUrl');
    if (await canLaunchUrl(appUrl)) {
      log('📤 QQShareUtil: 可以启动QQ App');
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    log('📤 QQShareUtil: QQ App未安装，尝试网页版');
    // 回退到网页版
    final webUrl = Uri.parse(
        'https://connect.qq.com/widget/shareqq/index.html?url=$encodedUrl&title=$encodedTitle&desc=$encodedDesc');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      return;
    }

    log('📤 QQShareUtil: 网页版也失败，使用系统分享');
    // 最终回退到系统分享
    await Share.share('$title\n$description\n$url');
  }

  /// 分享到QQ空间（优先唤醒App，失败后回退网页版）
  static Future<void> shareToQZone({
    required String url,
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    log('📤 QQShareUtil: 开始分享到QQ空间');
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(title);
    final encodedDesc = Uri.encodeComponent(description);

    // 优先尝试唤醒 QQ空间 App
    final appUrl =
        Uri.parse('qzone://qzapp/share?src_type=web&url=$encodedUrl&title=$encodedTitle&summary=$encodedDesc');
    log('📤 QQShareUtil: 尝试唤醒QQ空间: $appUrl');
    if (await canLaunchUrl(appUrl)) {
      log('📤 QQShareUtil: 可以启动QQ空间');
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    log('📤 QQShareUtil: QQ空间未安装，尝试网页版');
    // 回退到网页版
    final webUrl = Uri.parse(
        'https://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=$encodedUrl&title=$encodedTitle&desc=$encodedDesc');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      return;
    }

    log('📤 QQShareUtil: 网页版也失败，使用系统分享');
    // 最终回退到系统分享
    await Share.share('$title\n$description\n$url');
  }

  /// 分享卡片到QQ（优先唤醒App，失败后回退网页版）- 兼容老方法
  static Future<void> shareToQQ({
    required String url,
    required String title,
    required String summary,
    Uint8List? imageBytes,
  }) async {
    await shareToQQFriend(
      url: url,
      title: title,
      description: summary,
      imageBytes: imageBytes,
    );
  }
}
