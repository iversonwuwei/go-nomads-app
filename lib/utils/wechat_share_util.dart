import 'dart:developer';
import 'dart:typed_data';

import 'package:fluwx/fluwx.dart';
import 'package:share_plus/share_plus.dart';

class WechatShareUtil {
  static final _fluwxInstance = Fluwx();

  /// 分享卡片到微信
  static Future<bool> shareToWeChat({
    required String url,
    required String title,
    required String description,
    Uint8List? thumbnail,
    bool toTimeline = false,
  }) async {
    try {
      log('📤 WechatShareUtil: 开始分享到微信, toTimeline=$toTimeline');
      final model = WeChatShareWebPageModel(
        url,
        title: title,
        description: description,
        thumbData: thumbnail,
        scene: toTimeline ? WeChatScene.timeline : WeChatScene.session,
      );
      final result = await _fluwxInstance.share(model);
      log('📤 WechatShareUtil: 分享结果=$result');
      return true;
    } catch (e) {
      log('❌ WechatShareUtil: 分享失败, 使用系统分享. 错误: $e');
      // 回退到系统分享
      final shareText = '$title\n$description\n$url';
      await Share.share(shareText);
      return false;
    }
  }
}
