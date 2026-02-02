import 'package:url_launcher/url_launcher.dart';

class EmailShareUtil {
  /// 通过邮件分享
  static Future<void> shareViaEmail({
    required String subject,
    required String body,
    required String url,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      queryParameters: {
        'subject': subject,
        'body': '$body\n\n$url',
      },
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }
}
