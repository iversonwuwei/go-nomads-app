import 'package:url_launcher/url_launcher.dart';

class TelegramShareUtil {
  /// 分享到 Telegram（优先唤醒App，失败后回退网页版）
  static Future<void> shareToTelegram({
    required String text,
    required String url,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);
    final encodedText = Uri.encodeComponent(text);

    // 优先尝试唤醒 Telegram App
    final appUrl = Uri.parse('tg://msg_url?url=$encodedUrl&text=$encodedText');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版
    final webUrl = Uri.parse('https://t.me/share/url?url=$encodedUrl&text=$encodedText');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
