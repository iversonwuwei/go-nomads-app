import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/services.dart';

class ClipboardShareUtil {
  /// 复制链接到剪贴板
  static Future<void> copyLink({required String url, String? text}) async {
    final content = text != null ? '$text\n$url' : url;
    await Clipboard.setData(ClipboardData(text: content));
    AppToast.success('链接已复制到剪贴板');
  }
}
