import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class SystemShareUtil {
  /// 分享图片和文本到系统原生分享面板
  static Future<void> shareCard({required String text, Uint8List? imageBytes}) async {
    if (imageBytes != null) {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/share_card.png').writeAsBytes(imageBytes);
      await Share.shareXFiles([XFile(file.path)], text: text);
    } else {
      await Share.share(text);
    }
  }
}
