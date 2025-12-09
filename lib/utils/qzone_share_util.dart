import 'package:url_launcher/url_launcher.dart';

class QzoneShareUtil {
  /// 分享到 QQ 空间（优先唤醒App，失败后回退网页版）
  static Future<void> shareToQzone({
    required String url,
    required String title,
    String? summary,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);
    final encodedTitle = Uri.encodeComponent(title);
    final summaryParam = summary != null ? '&summary=${Uri.encodeComponent(summary)}' : '';

    // 优先尝试唤醒 QQ空间 App
    final appUrl = Uri.parse('mqqzone://share?url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版
    final webUrl = Uri.parse(
        'https://sns.qzone.qq.com/cgi-bin/qzshare/cgi_qzshare_onekey?url=$encodedUrl&title=$encodedTitle$summaryParam');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
