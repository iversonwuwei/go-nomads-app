import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:image_picker/image_picker.dart';

/// 聊天更多选项配置
class ChatMoreOptionsConfig {
  /// 选择图片回调
  final Future<void> Function(XFile image)? onImagePicked;

  /// 选择位置回调
  final Future<void> Function()? onLocationPicked;

  /// 选择文件回调
  final Future<void> Function(PlatformFile file)? onFilePicked;

  /// 是否显示位置选项
  final bool showLocation;

  /// 是否显示文件选项
  final bool showFile;

  const ChatMoreOptionsConfig({
    this.onImagePicked,
    this.onLocationPicked,
    this.onFilePicked,
    this.showLocation = true,
    this.showFile = true,
  });
}

/// 聊天更多选项控制器
class ChatMoreOptionsController extends GetxController {
  final ChatMoreOptionsConfig config;

  ChatMoreOptionsController({required this.config});

  /// 选择图片（相册/相机）
  Future<void> pickImage(ImageSource source) async {
    Get.back(); // 关闭底部菜单
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null && config.onImagePicked != null) {
        await config.onImagePicked!(image);
      }
    } catch (e) {
      AppToast.error('选择图片失败: $e');
    }
  }

  /// 选择位置
  Future<void> pickLocation() async {
    Get.back(); // 关闭底部菜单
    if (config.onLocationPicked != null) {
      await config.onLocationPicked!();
    }
  }

  /// 选择文件
  Future<void> pickFile() async {
    Get.back(); // 关闭底部菜单
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (result != null && result.files.isNotEmpty && config.onFilePicked != null) {
        final platformFile = result.files.first;
        if (platformFile.path != null) {
          await config.onFilePicked!(platformFile);
        }
      }
    } catch (e) {
      AppToast.error('选择文件失败: $e');
    }
  }
}

/// 聊天更多选项底部弹窗
class ChatMoreOptionsSheet extends GetView<ChatMoreOptionsController> {
  final ChatMoreOptionsConfig config;

  const ChatMoreOptionsSheet({
    super.key,
    required this.config,
  });

  /// 显示更多选项底部弹窗
  static void show({required ChatMoreOptionsConfig config}) {
    // 注册控制器
    Get.put(ChatMoreOptionsController(config: config));

    Get.bottomSheet(
      ChatMoreOptionsSheet(config: config),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部拖动条
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // 功能选项网格
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _ChatMoreOptionItem(
                    icon: FontAwesomeIcons.image,
                    label: '照片',
                    color: const Color(0xFF10B981),
                    onTap: () => controller.pickImage(ImageSource.gallery),
                  ),
                  _ChatMoreOptionItem(
                    icon: FontAwesomeIcons.camera,
                    label: '拍摄',
                    color: const Color(0xFFFFAA00),
                    onTap: () => controller.pickImage(ImageSource.camera),
                  ),
                  if (config.showLocation)
                    _ChatMoreOptionItem(
                      icon: FontAwesomeIcons.locationDot,
                      label: '位置',
                      color: const Color(0xFFEF4444),
                      onTap: () => controller.pickLocation(),
                    ),
                  if (config.showFile)
                    _ChatMoreOptionItem(
                      icon: FontAwesomeIcons.folder,
                      label: '文件',
                      color: const Color(0xFF3B82F6),
                      onTap: () => controller.pickFile(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 更多选项单个按钮
class _ChatMoreOptionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ChatMoreOptionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }
}
