import 'dart:developer';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 技能编辑页面控制器
class EditSkillsPageController extends GetxController {
  final int accountId;

  EditSkillsPageController({required this.accountId});

  final _userProfileDao = UserProfileDao();
  final customSkillController = TextEditingController();

  final RxBool loading = true.obs;
  final RxSet<String> selectedSkills = <String>{}.obs;
  final RxnString selectedCategory = RxnString('全部');

  final Map<String, List<String>> categorizedSkills = {
    '技术': [
      'Web开发', '移动开发', 'UI/UX设计', '数据科学', '机器学习',
      'DevOps', '云计算', '区块链', '前端开发', '后端开发', 'Full Stack', '数据库',
    ],
    '商业': [
      '市场营销', '产品管理', '项目管理', '销售', '商业分析', '创业', '咨询', '财务',
    ],
    '创意': [
      '平面设计', '内容创作', '视频制作', '摄影', '写作', '插画', '动画', '音乐制作',
    ],
    '其他': [
      '教学', '翻译', '客户服务', '人力资源', '法律', '医疗', '研究', '运营',
    ],
  };

  @override
  void onInit() {
    super.onInit();
    loadSkills();
  }

  @override
  void onClose() {
    customSkillController.dispose();
    super.onClose();
  }

  Future<void> loadSkills() async {
    try {
      final skills = await _userProfileDao.getSkills(accountId);
      selectedSkills.assignAll(skills.map((s) => s.skillName).toSet());
      loading.value = false;
    } catch (e) {
      log('加载技能失败: $e');
      loading.value = false;
    }
  }

  Future<void> toggleSkill(String skillName) async {
    try {
      if (selectedSkills.contains(skillName)) {
        await _userProfileDao.removeSkill(accountId, skillName);
        selectedSkills.remove(skillName);
        AppToast.success('已移除技能');
      } else {
        final skill = UserSkillDto(
          accountId: accountId,
          skillName: skillName,
          createdAt: DateTime.now().toIso8601String(),
        );
        await _userProfileDao.addSkill(skill);
        selectedSkills.add(skillName);
        AppToast.success('已添加技能');
      }
    } catch (e) {
      log('操作技能失败: $e');
      AppToast.error('操作失败，请重试');
    }
  }

  Future<void> addCustomSkill() async {
    final skillName = customSkillController.text.trim();
    if (skillName.isEmpty) {
      AppToast.warning('请输入技能名称');
      return;
    }

    if (selectedSkills.contains(skillName)) {
      AppToast.warning('该技能已存在');
      return;
    }

    try {
      final skill = UserSkillDto(
        accountId: accountId,
        skillName: skillName,
        createdAt: DateTime.now().toIso8601String(),
      );
      await _userProfileDao.addSkill(skill);
      selectedSkills.add(skillName);
      customSkillController.clear();
      AppToast.success('已添加自定义技能');
    } catch (e) {
      log('添加自定义技能失败: $e');
      AppToast.error('添加失败，请重试');
    }
  }

  List<String> getFilteredSkills() {
    if (selectedCategory.value == '全部') {
      return categorizedSkills.values.expand((skills) => skills).toList();
    }
    return categorizedSkills[selectedCategory.value] ?? [];
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }
}
