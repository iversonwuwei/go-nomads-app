import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

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
class EditSocialLinksPage extends StatefulWidget {
  final int accountId;

  const EditSocialLinksPage({super.key, required this.accountId});

  @override
  State<EditSocialLinksPage> createState() => _EditSocialLinksPageState();
}

class _EditSocialLinksPageState extends State<EditSocialLinksPage> {
  final _userProfileDao = UserProfileDao();

  bool _loading = true;
  Map<String, String> _socialLinks = {}; // platform -> url

  @override
  void initState() {
    super.initState();
    _loadSocialLinks();
  }

  Future<void> _loadSocialLinks() async {
    try {
      final links = await _userProfileDao.getSocialLinks(widget.accountId);
      if (mounted) {
        setState(() {
          _socialLinks = {for (var link in links) link.platform: link.url};
          _loading = false;
        });
      }
    } catch (e) {
      log('加载社交链接失败: $e');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _showEditDialog(String platform) async {
    final platformInfo = SocialPlatforms.platforms[platform]!;
    final currentUrl = _socialLinks[platform];
    final controller = TextEditingController(text: currentUrl);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(platformInfo['icon'] as String,
                style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text('${platformInfo['name']}'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '链接地址',
                border: const OutlineInputBorder(),
                hintText: platformInfo['urlPattern'] as String,
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 8),
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
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      if (result == 'DELETE') {
        await _deleteSocialLink(platform);
      } else if (result.isNotEmpty) {
        await _saveSocialLink(platform, result);
      }
    }

    controller.dispose();
  }

  Future<void> _saveSocialLink(String platform, String url) async {
    try {
      final link = SocialLinkDto(
        accountId: widget.accountId,
        platform: platform,
        url: url,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.saveSocialLink(link);
      setState(() {
        _socialLinks[platform] = url;
      });
      AppToast.success('已保存社交链接');
    } catch (e) {
      log('保存社交链接失败: $e');
      AppToast.error('保存失败，请重试');
    }
  }

  Future<void> _deleteSocialLink(String platform) async {
    try {
      await _userProfileDao.removeSocialLink(widget.accountId, platform);
      setState(() {
        _socialLinks.remove(platform);
      });
      AppToast.success('已删除社交链接');
    } catch (e) {
      log('删除社交链接失败: $e');
      AppToast.error('删除失败，请重试');
    }
  }

  Widget _buildPlatformCard(String platform, Map<String, dynamic> info) {
    final hasLink = _socialLinks.containsKey(platform);

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
                _socialLinks[platform]!,
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
        onTap: () => _showEditDialog(platform),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('社交链接'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                      Text(
                        '已添加 ${_socialLinks.length} / ${SocialPlatforms.platforms.length} 个平台',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                        child: _buildPlatformCard(entry.key, entry.value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
