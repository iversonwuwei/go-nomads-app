import 'package:url_launcher/url_launcher.dart';

class DingTalkShareUtil {
  /// 分享到钉钉
  static Future<void> shareToDingTalk({
    required String url,
    required String title,
    String? content,
  }) async {
    // 钉钉分享链接格式
    final dingtalkUrl = Uri.parse(
      'dingtalk://dingtalkclient/sendmsg?type=link&url=${Uri.encodeComponent(url)}&title=${Uri.encodeComponent(title)}${content != null ? '&content=${Uri.encodeComponent(content)}' : ''}',
    );

    // 首先尝试打开钉钉 App
    if (await canLaunchUrl(dingtalkUrl)) {
      await launchUrl(dingtalkUrl, mode: LaunchMode.externalApplication);
    } else {
      // 如果钉钉未安装，使用网页版
      final webUrl = Uri.parse(
        'https://page.dingtalk.com/wow/dingtalk/act/share?url=${Uri.encodeComponent(url)}',
      );
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    }
  }
}
