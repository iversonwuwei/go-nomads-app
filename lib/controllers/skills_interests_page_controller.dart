import 'dart:developer';

import 'package:df_admin_mobile/features/interest/domain/entities/interest.dart';
import 'package:df_admin_mobile/features/interest/presentation/controllers/interest_state_controller.dart';
import 'package:df_admin_mobile/features/skill/domain/entities/skill.dart';
import 'package:df_admin_mobile/features/skill/presentation/controllers/skill_state_controller.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller_v2.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:get/get.dart';

/// 技能和兴趣选择页面控制器
class SkillsInterestsPageController extends GetxController {
  late final SkillStateController skillController;
  late final InterestStateController interestController;
  late final UserStateControllerV2 userStateController;

  /// 已选技能列表
  final RxList<UserSkill> selectedSkills = <UserSkill>[].obs;

  /// 已选兴趣列表
  final RxList<UserInterest> selectedInterests = <UserInterest>[].obs;

  /// 是否正在保存
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    skillController = Get.find<SkillStateController>();
    interestController = Get.find<InterestStateController>();
    userStateController = Get.find<UserStateControllerV2>();
  }

  /// 更新选中的技能
  void updateSelectedSkills(List<UserSkill> skills) {
    selectedSkills.value = skills;
  }

  /// 更新选中的兴趣
  void updateSelectedInterests(List<UserInterest> interests) {
    selectedInterests.value = interests;
  }

  /// 获取选中的技能ID列表
  List<String> get selectedSkillIds => selectedSkills.map((s) => s.skillId.toString()).toList();

  /// 获取选中的兴趣ID列表
  List<String> get selectedInterestIds => selectedInterests.map((i) => i.interestId.toString()).toList();

  /// 是否有选中项
  bool get hasSelection => selectedSkills.isNotEmpty || selectedInterests.isNotEmpty;

  /// 保存技能和兴趣
  Future<void> saveSkillsAndInterests() async {
    final currentUser = userStateController.currentUser.value;

    if (currentUser == null) {
      AppToast.error('请先登录以保存您的技能和兴趣');
      return;
    }

    if (!hasSelection) {
      AppToast.error('请至少选择一个技能或兴趣');
      return;
    }

    isSaving.value = true;

    try {
      var skillSuccessCount = 0;
      var interestSuccessCount = 0;

      // 保存技能
      if (selectedSkills.isNotEmpty) {
        for (final skill in selectedSkills) {
          final success = await skillController.addUserSkill(
            currentUser.id,
            AddUserSkillRequest(
              skillId: skill.skillId,
              proficiencyLevel: skill.proficiencyLevel,
              yearsOfExperience: skill.yearsOfExperience,
            ),
          );
          if (success) {
            skillSuccessCount++;
          }
        }
      }

      // 保存兴趣
      if (selectedInterests.isNotEmpty) {
        for (final interest in selectedInterests) {
          final success = await interestController.addUserInterest(
            currentUser.id,
            AddUserInterestRequest(
              interestId: interest.interestId,
              intensityLevel: interest.intensityLevel,
            ),
          );
          if (success) {
            interestSuccessCount++;
          }
        }
      }

      final hasSkillFailure = skillSuccessCount != selectedSkills.length && selectedSkills.isNotEmpty;
      final hasInterestFailure = interestSuccessCount != selectedInterests.length && selectedInterests.isNotEmpty;

      if (!hasSkillFailure && !hasInterestFailure) {
        AppToast.success('已保存 $skillSuccessCount 个技能和 $interestSuccessCount 个兴趣');
        // 返回上一页
        Get.back();
      } else {
        final failureMessages = <String>[];
        if (hasSkillFailure) {
          failureMessages.add('技能保存失败 ${selectedSkills.length - skillSuccessCount}/${selectedSkills.length}');
        }
        if (hasInterestFailure) {
          failureMessages
              .add('兴趣保存失败 ${selectedInterests.length - interestSuccessCount}/${selectedInterests.length}');
        }
        AppToast.warning(failureMessages.join(' · '));
      }
    } catch (e) {
      log('❌ 保存失败: $e');
      AppToast.error('无法保存您的选择，请稍后重试');
    } finally {
      isSaving.value = false;
    }
  }
}
