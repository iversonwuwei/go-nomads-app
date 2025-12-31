import 'dart:developer';

import 'package:df_admin_mobile/features/user_profile/infrastructure/models/user_profile_dto.dart';
import 'package:df_admin_mobile/services/database/user_profile_dao.dart';
import 'package:get/get.dart';

/// ModularUserProfilePage 控制器
class ModularUserProfilePageController extends GetxController {
  final int accountId;
  final String? username;

  ModularUserProfilePageController({
    required this.accountId,
    this.username,
  });

  final _userProfileDao = UserProfileDao();

  final RxBool loading = true.obs;
  final Rx<UserBasicInfoDto?> basicInfo = Rx<UserBasicInfoDto?>(null);
  final Rx<NomadStatsDto?> stats = Rx<NomadStatsDto?>(null);
  final RxList<UserSkillDto> skills = <UserSkillDto>[].obs;
  final RxList<UserInterestDto> interests = <UserInterestDto>[].obs;
  final RxList<SocialLinkDto> socialLinks = <SocialLinkDto>[].obs;
  final RxList<dynamic> travelPlans = <dynamic>[].obs;
  final RxList<UserBadgeDto> badges = <UserBadgeDto>[].obs;
  final RxList<TravelHistoryEntryDto> history = <TravelHistoryEntryDto>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    loading.value = true;
    try {
      basicInfo.value = await _userProfileDao.getBasicInfo(accountId);
      stats.value = await _userProfileDao.getNomadStats(accountId);
      skills.value = await _userProfileDao.getSkills(accountId);
      interests.value = await _userProfileDao.getInterests(accountId);
      socialLinks.value = await _userProfileDao.getSocialLinks(accountId);
      travelPlans.value = await _userProfileDao.getTravelPlans(accountId);
      badges.value = await _userProfileDao.getBadges(accountId);
      history.value = await _userProfileDao.getTravelHistory(accountId);
    } catch (e) {
      log('加载用户资料失败: $e');
    } finally {
      loading.value = false;
    }
  }
}
