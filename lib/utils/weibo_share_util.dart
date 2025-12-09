import 'dart:typed_data';

import 'package:url_launcher/url_launcher.dart';

class WeiboShareUtil {
  /// 分享卡片到微博
  /// 注意：weibo_kit 4.0 版本 API 变化较大，此处使用网页分享方式
  static Future<void> shareToWeibo({
    required String url,
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    // 使用微博网页分享链接
    final weiboShareUrl = Uri.parse(
      'https://service.weibo.com/share/share.php?title=${Uri.encodeComponent("$title - $description")}&url=${Uri.encodeComponent(url)}',
    );
    if (await canLaunchUrl(weiboShareUrl)) {
      await launchUrl(weiboShareUrl, mode: LaunchMode.externalApplication);
    }
  }
}
