import 'package:url_launcher/url_launcher.dart';

/// QQ 分享工具类
/// 支持分享到 QQ 好友和 QQ 空间
class QQShareUtil {
  /// 分享到 QQ 好友（优先唤醒 QQ App，失败后回退网页版）
  static Future<void> shareToQQFriend({
    required String url,
    required String title,
    String? summary,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(title);
    final summaryParam = summary != null ? '&summary=${Uri.encodeComponent(summary)}' : '';

    // 优先尝试唤醒 QQ App 分享给好友
    final appUrl = Uri.parse(
        'mqq://share/to_fri?src_type=web&url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版 QQ 分享（通过 connect.qq.com）
    final webUrl = Uri.parse(
        'https://connect.qq.com/widget/shareqq/index.html?url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  /// 分享到 QQ 空间（优先唤醒 QQ 空间 App，失败后回退网页版）
  static Future<void> shareToQzone({
    required String url,
    required String title,
    String? summary,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(title);
    final summaryParam = summary != null ? '&summary=${Uri.encodeComponent(summary)}' : '';

    // 优先尝试唤醒 QQ 空间 App
    final appUrl = Uri.parse('mqqzone://share?url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版 QQ 空间分享
    final webUrl = Uri.parse(
        'https://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
