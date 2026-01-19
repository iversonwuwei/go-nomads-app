import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class FacebookShareUtil {
  /// 分享到 Facebook（优先唤醒App，失败后回退网页版）
  static Future<void> shareToFacebook({
    required String url,
    String? quote,
    bool showDebugToast = true,
  }) async {
    final encodedUrl = Uri.encodeComponent(url);

    // 优先尝试唤醒 Facebook App
    final appUrl = Uri.parse('fb://facewebmodal/f?href=$encodedUrl');

    // 先显示调试信息
    if (showDebugToast) {
      AppToast.info(
        '正在检测 Facebook App...\nURL scheme: fb://',
        title: '🔍 调试信息',
      );
    }

    // 等待一下让 Toast 显示
    await Future.delayed(const Duration(milliseconds: 500));

    final canLaunchApp = await canLaunchUrl(appUrl);

    if (showDebugToast) {
      AppToast.info(
        'Facebook App检测结果: ${canLaunchApp ? "✅ 已安装" : "❌ 未检测到"}',
        title: '🔍 检测结果',
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (canLaunchApp) {
      final launched = await launchUrl(appUrl, mode: LaunchMode.externalApplication);
      if (showDebugToast && !launched) {
        AppToast.error('启动 Facebook App 失败');
      }
      return;
    }

    // 回退到网页版
    if (showDebugToast) {
      AppToast.warning('无法唤醒 Facebook App，使用网页版分享');
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final quoteParam = quote != null ? '&quote=${Uri.encodeComponent(quote)}' : '';
    final webUrl = Uri.parse('https://www.facebook.com/sharer/sharer.php?u=$encodedUrl$quoteParam');
    if (await canLaunchUrl(webUrl)) {
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    } else {
      if (showDebugToast) {
        AppToast.error('无法打开网页版 Facebook');
      }
    }
  }
}
