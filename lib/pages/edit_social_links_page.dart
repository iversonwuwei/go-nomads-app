import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/controllers/edit_social_links_page_controller.dart';

/// 社交平台常量
class SocialPlatforms {
  static const Map<String, Map<String, String>> platforms = {
    'instagram': {'name': 'Instagram', 'icon': '📷'},
    'twitter': {'name': 'Twitter', 'icon': '🐦'},
    'facebook': {'name': 'Facebook', 'icon': '👤'},
    'linkedin': {'name': 'LinkedIn', 'icon': '💼'},
    'github': {'name': 'GitHub', 'icon': '💻'},
    'youtube': {'name': 'YouTube', 'icon': '📺'},
    'tiktok': {'name': 'TikTok', 'icon': '🎵'},
    'wechat': {'name': 'WeChat', 'icon': '💬'},
  };
}

/// 社交链接编辑页面
class EditSocialLinksPage extends StatelessWidget {
  final int accountId;

  const EditSocialLinksPage({super.key, required this.accountId});

  static String _generateTag(int accountId) => 'EditSocialLinksPage_$accountId';

  EditSocialLinksPageController _useController() {
    final tag = _generateTag(accountId);
    if (Get.isRegistered<EditSocialLinksPageController>(tag: tag)) {
      return Get.find<EditSocialLinksPageController>(tag: tag);
    }
    return Get.put(EditSocialLinksPageController(accountId: accountId), tag: tag);
  }

  Future<void> _showEditDialog(BuildContext context, EditSocialLinksPageController controller, String platform) async {
    final platformInfo = SocialPlatforms.platforms[platform]!;
    final currentUrl = controller.getLink(platform);
    final textController = TextEditingController(text: currentUrl);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(platformInfo['icon'] as String, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text('${platformInfo['name']}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: '链接地址',
                border: const OutlineInputBorder(),
                hintText: platformInfo['urlPattern'],
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
            if (platformInfo['urlPattern'] != null)
              Text(
                '示例: ${platformInfo['urlPattern']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        actions: [
          if (currentUrl != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'DELETE'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    textController.dispose();

    if (result != null) {
      if (result == 'DELETE') {
        await controller.deleteSocialLink(platform);
      } else if (result.isNotEmpty) {
        await controller.saveSocialLink(platform, result);
      }
    }
  }

  Widget _buildPlatformCard(
    BuildContext context,
    EditSocialLinksPageController controller,
    String platform,
    Map<String, dynamic> info,
  ) {
    return Obx(() {
      final hasLink = controller.hasLink(platform);
      final linkUrl = controller.getLink(platform);

      return Card(
        elevation: hasLink ? 2 : 0,
        color: hasLink ? Colors.blue.shade50 : null,
        child: ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasLink ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                info['icon'] as String,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          title: Text(
            info['name'] as String,
            style: TextStyle(
              fontWeight: hasLink ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: hasLink
              ? Text(
                  linkUrl!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                )
              : Text(
                  '点击添加',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
          trailing: Icon(
            hasLink ? FontAwesomeIcons.circleCheck : FontAwesomeIcons.circlePlus,
            color: hasLink ? Colors.green : Colors.grey,
          ),
          onTap: () => _showEditDialog(context, controller, platform),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('社交链接'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const EditFormSkeleton();
        }

        return Column(
          children: [
            // 统计信息
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                children: [
                  const Icon(FontAwesomeIcons.link, color: Colors.blue),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                        '已添加 ${controller.linkedCount} / ${SocialPlatforms.platforms.length} 个平台',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )),
                ],
              ),
            ),

            // 平台列表
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: SocialPlatforms.platforms.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildPlatformCard(context, controller, entry.key, entry.value),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}
