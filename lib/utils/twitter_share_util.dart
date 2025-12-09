import 'package:url_launcher/url_launcher.dart';

class TwitterShareUtil {
  /// 分享到 Twitter/X（优先唤醒App，失败后回退网页版）
  static Future<void> shareToTwitter({
    required String text,
    required String url,
  }) async {
    final encodedText = Uri.encodeComponent(text);
    final encodedUrl = Uri.encodeComponent(url);

    // 优先尝试唤醒 Twitter App
    final appUrl = Uri.parse('twitter://post?message=$encodedText%20$encodedUrl');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版
    final webUrl = Uri.parse('https://twitter.com/intent/tweet?text=$encodedText&url=$encodedUrl');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
