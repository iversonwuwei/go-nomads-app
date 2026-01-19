import 'dart:developer';

import 'package:go_nomads_app/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:go_nomads_app/services/database/user_profile_dao.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 社交链接编辑页面控制器
class EditSocialLinksPageController extends GetxController {
  final int accountId;
  final _userProfileDao = UserProfileDao();

  EditSocialLinksPageController({required this.accountId});

  /// 是否正在加载
  final RxBool isLoading = true.obs;

  /// 社交链接映射 platform -> url
  final RxMap<String, String> socialLinks = <String, String>{}.obs;

  /// 已添加的链接数量
  int get linkedCount => socialLinks.length;

  @override
  void onInit() {
    super.onInit();
    loadSocialLinks();
  }

  /// 加载社交链接
  Future<void> loadSocialLinks() async {
    try {
      final links = await _userProfileDao.getSocialLinks(accountId);
      socialLinks.value = {for (var link in links) link.platform: link.url};
    } catch (e) {
      log('加载社交链接失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 检查平台是否已添加链接
  bool hasLink(String platform) => socialLinks.containsKey(platform);

  /// 获取平台链接
  String? getLink(String platform) => socialLinks[platform];

  /// 保存社交链接
  Future<void> saveSocialLink(String platform, String url) async {
    try {
      final link = SocialLinkDto(
        accountId: accountId,
        platform: platform,
        url: url,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.saveSocialLink(link);
      socialLinks[platform] = url;
      AppToast.success('已保存社交链接');
    } catch (e) {
      log('保存社交链接失败: $e');
      AppToast.error('保存失败，请重试');
    }
  }

  /// 删除社交链接
  Future<void> deleteSocialLink(String platform) async {
    try {
      await _userProfileDao.removeSocialLink(accountId, platform);
      socialLinks.remove(platform);
      AppToast.success('已删除社交链接');
    } catch (e) {
      log('删除社交链接失败: $e');
      AppToast.error('删除失败，请重试');
    }
  }
}
