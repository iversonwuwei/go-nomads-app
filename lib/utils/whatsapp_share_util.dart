import 'package:url_launcher/url_launcher.dart';

class WhatsappShareUtil {
  /// 分享到 WhatsApp（优先唤醒App，失败后回退网页版）
  static Future<void> shareToWhatsApp({
    required String text,
    required String url,
  }) async {
    final content = Uri.encodeComponent('$text\n$url');

    // 优先尝试唤醒 WhatsApp App
    final appUrl = Uri.parse('whatsapp://send?text=$content');
    if (await canLaunchUrl(appUrl)) {
      await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      return;
    }

    // 回退到网页版
    final webUrl = Uri.parse('https://wa.me/?text=$content');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }
}
