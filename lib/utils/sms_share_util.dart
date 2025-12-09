import 'package:url_launcher/url_launcher.dart';

class SmsShareUtil {
  /// 通过短信分享文本和URL
  static Future<void> shareViaSms({required String text, required String url}) async {
    final smsUri = Uri(
      scheme: 'sms',
      queryParameters: {'body': '$text $url'},
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }
}
