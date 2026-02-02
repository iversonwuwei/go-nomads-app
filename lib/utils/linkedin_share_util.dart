import 'package:url_launcher/url_launcher.dart';

class LinkedInShareUtil {
  /// 分享到 LinkedIn（优先唤醒App，失败后回退网页版）
  static Future<void> shareToLinkedIn({
    required String url,
    String? title,
    String? summary,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);

    // 优先尝试唤醒 LinkedIn App
    final appUrl = Uri.parse('linkedin://shareArticle?url=$encodedUrl');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版
    final webUrl = Uri.parse('https://www.linkedin.com/sharing/share-offsite/?url=$encodedUrl');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
