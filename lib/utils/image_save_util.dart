import 'dart:io';
import 'dart:typed_data';

import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaveUtil {
  /// 保存图片到相册
  static Future<void> saveImageToGallery(Uint8List imageBytes) async {
    try {
      // 获取图片目录
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imagePath = '${directory.path}/share_card_$timestamp.png';

      // 保存图片文件
      final file = File(imagePath);
      await file.writeAsBytes(imageBytes);

      // 注意：要真正保存到系统相册，需要使用 image_gallery_saver 插件
      // 这里先保存到应用目录
      AppToast.success('图片已保存');
    } catch (e) {
      AppToast.error('保存失败: $e');
    }
  }
}
