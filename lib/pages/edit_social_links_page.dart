import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/edit_social_links_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final platformInfo = SocialPlatforms.platforms[platform]!;
    final currentUrl = controller.getLink(platform);
    final textController = TextEditingController(text: currentUrl);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(platformInfo['icon'] as String, style: TextStyle(fontSize: 24.sp)),
            SizedBox(width: 8.w),
            Text(platformInfo['name'] as String),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: l10n.editSocialLinksUrl,
                border: const OutlineInputBorder(),
                hintText: platformInfo['urlPattern'],
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 8.h),
            if (platformInfo['urlPattern'] != null)
              Text(
                l10n.editSocialLinksExample(platformInfo['urlPattern'] as String),
                style: TextStyle(
                  fontSize: 12.sp,
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
              child: Text(l10n.delete),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, textController.text.trim()),
            child: Text(l10n.save),
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
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: hasLink ? Colors.blue.shade100 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                info['icon'] as String,
                style: TextStyle(fontSize: 24.sp),
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
                  style: TextStyle(fontSize: 12.sp),
                )
              : Text(
                  AppLocalizations.of(context)!.editSocialLinksTapToAdd,
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.modularProfileModuleSocialLinks),
      ),
      body: Obx(() {
        return AppLoadingSwitcher(
          isLoading: controller.isLoading.value,
          loading: const EditFormSkeleton(),
          child: Column(
            children: [
              // 统计信息
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(FontAwesomeIcons.link, color: Colors.blue),
                    SizedBox(width: 8.w),
                    Obx(() => Text(
                          l10n.editSocialLinksAddedCount(controller.linkedCount, SocialPlatforms.platforms.length),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        )),
                  ],
                ),
              ),

              // 平台列表
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16.w),
                  children: SocialPlatforms.platforms.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: _buildPlatformCard(context, controller, entry.key, entry.value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
