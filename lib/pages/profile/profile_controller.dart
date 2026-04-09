import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/membership/presentation/controllers/membership_state_controller.dart';
import 'package:go_nomads_app/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/domain/entities/profile_snapshot.dart';
import 'package:go_nomads_app/pages/profile/domain/repositories/i_profile_snapshot_repository.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// Profile 页面控制器
///
/// 负责协调用户、会员、旅行计划等状态
class ProfileController extends GetxController {
  final IProfileSnapshotRepository _profileSnapshotRepository;

  ProfileController(this._profileSnapshotRepository);

  // ==================== 依赖控制器 ====================

  UserStateController get userController => Get.find<UserStateController>();
  AuthStateController get authController => Get.find<AuthStateController>();
  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  MembershipStateController? get membershipController {
    if (Get.isRegistered<MembershipStateController>()) {
      return Get.find<MembershipStateController>();
    }
    return null;
  }

  // ==================== 可观察状态 ====================

  /// 页面是否正在加载
  final _isPageLoading = true.obs;

  /// 是否已初始化
  final _isInitialized = false.obs;

  /// 下一站城市详情
  final _nextDestinationCity = Rx<City?>(null);

  /// 最新旅行计划摘要
  final _latestTravelPlan = Rx<TravelPlanSummary?>(null);

  // ==================== Getters ====================

  /// 当前用户
  User? get currentUser => userController.currentUser.value;
  Rx<User?> get currentUserRx => userController.currentUser;

  /// 用户是否已登录
  bool get isLoggedIn => userController.isLoggedIn;

  /// 是否正在加载用户数据
  bool get isLoadingUser => userController.isLoading.value;
  RxBool get isLoadingUserRx => userController.isLoading;

  /// 页面是否正在加载
  bool get isPageLoading => _isPageLoading.value;
  RxBool get isPageLoadingRx => _isPageLoading;

  /// 是否已认证
  bool get isAuthenticated => authController.isAuthenticated.value;

  City? get nextDestinationCity => _nextDestinationCity.value;

  TravelPlanSummary? get latestTravelPlan => _latestTravelPlan.value;

  NomadProfileSnapshot? get nomadProfileSnapshot {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final stats = userController.nomadStats.value ?? NomadStats.empty(user.id);
    final plan = latestTravelPlan;
    final favoriteCount = userController.favoriteCityIds.length;

    return NomadProfileSnapshot(
      nextDestination: plan?.cityName ?? user.currentCity ?? _l10n.profileSnapshotNoDestination,
      departureDateLabel: plan?.formattedDepartureDate,
      budgetLane: _describeBudgetLane(plan?.budgetLevel),
      workTimezone: nextDestinationCity?.timezone ?? _describeBaseTimezone(user),
      stayRhythm: _describeStayRhythm(plan?.duration, stats),
      communityMomentum: _describeCommunityMomentum(stats),
      baseLocation: _describeBaseLocation(user),
      migrationStatus: _describeMigrationStatus(plan?.status),
      profileReadiness: _describeProfileReadiness(user, stats, favoriteCount),
      focusRouteName: _resolveFocusRoute(plan),
      focusRouteLabel: _resolveFocusRouteLabel(plan),
      secondaryRouteName: AppRoutes.profileEdit,
      secondaryRouteLabel: _l10n.profileSnapshotTuneProfile,
    );
  }

  NomadCollaborationProfile? get collaborationProfile {
    final user = currentUser;
    if (user == null) {
      return null;
    }

    final stats = userController.nomadStats.value ?? NomadStats.empty(user.id);
    final skillTags = user.skills.map((skill) => skill.name).where((name) => name.trim().isNotEmpty).take(3).toList();
    final interestTags =
        user.interests.map((interest) => interest.name).where((name) => name.trim().isNotEmpty).take(3).toList();
    final socialTags = user.socialLinks.keys.map(_formatPlatformName).take(3).toList();

    return NomadCollaborationProfile(
      professionalIdentity: _describeProfessionalIdentity(user),
      languageAbility: _describeLanguageAbility(user),
      collaborationMode: _describeCollaborationMode(user, stats),
      discoveryReadiness: _describeDiscoveryReadiness(user, stats),
      skillTags: skillTags,
      interestTags: interestTags,
      socialTags: socialTags,
    );
  }

  // ==================== 生命周期 ====================

  @override
  void onInit() {
    super.onInit();
    log('🎬 ProfileController 初始化');
  }

  @override
  void onReady() {
    super.onReady();
    // 页面准备好后加载数据
    loadProfileData();
  }

  // ==================== 业务方法 ====================

  /// 加载 Profile 页面数据
  Future<void> loadProfileData() async {
    log('📦 ProfileController: 开始加载数据');
    _isPageLoading.value = true;

    try {
      // 检查认证状态
      if (!isAuthenticated) {
        log('⚠️ 用户未登录，跳转到登录页');
        AppToast.info(_l10n.profilePleaseLoginToView, title: _l10n.loginRequired);
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      final result = await _profileSnapshotRepository.getProfileSnapshot();

      result.fold(
        onSuccess: _applySnapshot,
        onFailure: (exception) {
          log('❌ ProfileController: Profile Snapshot 加载失败: ${exception.message}');
        },
      );

      if (currentUser == null && userController.errorMessage.value.isNotEmpty) {
        log('⚠️ 加载用户数据失败，跳转到登录页');
        AppToast.info(_l10n.profilePleaseLoginAgain, title: _l10n.dataServiceSessionExpiredTitle);
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      _isInitialized.value = true;
      log('✅ ProfileController: 数据加载完成');
    } catch (e) {
      log('❌ ProfileController: 加载数据失败: $e');
    } finally {
      _isPageLoading.value = false;
    }
  }

  /// 刷新数据
  Future<void> refreshData() async {
    log('🔄 ProfileController: 刷新数据');
    await loadProfileData();
  }

  /// 路由恢复时调用 - 强制刷新关键数据
  ///
  /// 当用户从其他页面返回 Profile 时调用此方法，
  /// 确保收藏、统计等数据与服务器同步
  Future<void> onRouteResume() async {
    log('🔄 ProfileController: 路由恢复，同步数据');

    // 只有在已初始化的情况下才执行刷新
    if (!_isInitialized.value) {
      log('⚠️ ProfileController 未初始化，跳过 onRouteResume');
      return;
    }

    await loadProfileData();

    log('✅ ProfileController: 数据同步完成');
  }

  void _applySnapshot(ProfileSnapshot snapshot) {
    userController.currentUser.value = snapshot.user;
    userController.nomadStats.value = snapshot.nomadStats;
    userController.favoriteCityIds
      ..clear()
      ..addAll(snapshot.favoriteCityIds);
    _latestTravelPlan.value = snapshot.latestTravelPlan;
    _nextDestinationCity.value = snapshot.nextDestinationCity;
    userController.errorMessage.value = '';
  }

  String _describeBudgetLane(String? budgetLevel) {
    switch (budgetLevel?.toLowerCase()) {
      case 'low':
        return _l10n.profileSnapshotBudgetLean;
      case 'high':
        return _l10n.profileSnapshotBudgetPremium;
      case 'medium':
      default:
        return _l10n.profileSnapshotBudgetBalanced;
    }
  }

  String _describeStayRhythm(int? duration, NomadStats stats) {
    if ((duration ?? 0) >= 60) {
      return _l10n.profileSnapshotStayLong;
    }

    if ((duration ?? 0) >= 30 || stats.daysNomading >= 90) {
      return _l10n.profileSnapshotStaySeasonal;
    }

    return _l10n.profileSnapshotStaySprint;
  }

  String _describeCommunityMomentum(NomadStats stats) {
    if (stats.activeMeetups >= 4) {
      return _l10n.profileSnapshotCommunityHigh;
    }

    if (stats.activeMeetups >= 1 || stats.favoriteCitiesCount >= 3) {
      return _l10n.profileSnapshotCommunityBuilding;
    }

    return _l10n.profileSnapshotCommunityQuiet;
  }

  String _describeBaseLocation(User user) {
    if ((user.currentCity ?? '').isNotEmpty && (user.currentCountry ?? '').isNotEmpty) {
      return '${user.currentCity}, ${user.currentCountry}';
    }

    if ((user.currentCity ?? '').isNotEmpty) {
      return user.currentCity!;
    }

    return _l10n.profileSnapshotBaseFlexible;
  }

  String _describeMigrationStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'draft':
        return _l10n.profileSnapshotMigrationDraft;
      case 'planned':
      case 'planning':
        return _l10n.profileSnapshotMigrationPlanning;
      case 'confirmed':
      case 'booked':
        return _l10n.profileSnapshotMigrationBooked;
      case 'active':
      case 'ongoing':
        return _l10n.profileSnapshotMigrationActive;
      default:
        return _l10n.profileSnapshotMigrationFlexible;
    }
  }

  String _describeProfileReadiness(User user, NomadStats stats, int favoriteCount) {
    final score = [
      if ((user.bio ?? '').trim().isNotEmpty) 1,
      if (user.skills.isNotEmpty) 1,
      if (user.interests.isNotEmpty) 1,
      if (favoriteCount >= 3) 1,
      if (stats.daysNomading >= 30) 1,
    ].length;

    if (score >= 4) {
      return _l10n.profileSnapshotReadinessStrong;
    }

    if (score >= 2) {
      return _l10n.profileSnapshotReadinessGrowing;
    }

    return _l10n.profileSnapshotReadinessStarting;
  }

  String _describeBaseTimezone(User user) {
    if ((user.currentCountry ?? '').isNotEmpty) {
      return '${user.currentCountry} · ${DateTime.now().timeZoneName}';
    }

    return DateTime.now().timeZoneName;
  }

  String _describeProfessionalIdentity(User user) {
    if (user.skills.length >= 2) {
      return '${user.skills[0].name} × ${user.skills[1].name}';
    }

    if (user.skills.isNotEmpty) {
      return user.skills.first.name;
    }

    if ((user.bio ?? '').trim().isNotEmpty) {
      return _l10n.profileCollaborationIdentityBioDriven;
    }

    return _l10n.profileCollaborationIdentityFlexible;
  }

  String _describeLanguageAbility(User user) {
    if ((user.bio ?? '').trim().isEmpty && user.socialLinks.isEmpty) {
      return _l10n.profileCollaborationLanguagePending;
    }

    if ((user.bio ?? '').contains(RegExp(r'[A-Za-z]')) && (user.bio ?? '').contains(RegExp(r'[\u4e00-\u9fff]'))) {
      return _l10n.profileCollaborationLanguageBilingualSignal;
    }

    return _l10n.profileCollaborationLanguageProfileReady;
  }

  String _describeCollaborationMode(User user, NomadStats stats) {
    if (stats.activeMeetups >= 4) {
      return _l10n.profileCollaborationModeCommunityLead;
    }

    if (user.socialLinks.isNotEmpty || stats.meetupsJoined > 0) {
      return _l10n.profileCollaborationModeOpenToConnect;
    }

    return _l10n.profileCollaborationModeBuilding;
  }

  String _describeDiscoveryReadiness(User user, NomadStats stats) {
    final score = [
      if (user.skills.isNotEmpty) 1,
      if (user.interests.isNotEmpty) 1,
      if (user.socialLinks.isNotEmpty) 1,
      if ((user.bio ?? '').trim().isNotEmpty) 1,
      if (stats.activeMeetups > 0) 1,
    ].length;

    if (score >= 4) {
      return _l10n.profileCollaborationDiscoveryStrong;
    }

    if (score >= 2) {
      return _l10n.profileCollaborationDiscoveryGrowing;
    }

    return _l10n.profileCollaborationDiscoveryStarting;
  }

  String _formatPlatformName(String platform) {
    if (platform.isEmpty) {
      return platform;
    }

    return platform[0].toUpperCase() + platform.substring(1).toLowerCase();
  }

  String _resolveFocusRoute(TravelPlanSummary? plan) {
    if (plan == null) {
      return AppRoutes.migrationWorkspace;
    }

    if (plan.status.toLowerCase() == 'draft') {
      return AppRoutes.migrationWorkspace;
    }

    return AppRoutes.budgetCenter;
  }

  String _resolveFocusRouteLabel(TravelPlanSummary? plan) {
    if (plan == null) {
      return _l10n.profileSnapshotOpenWorkspace;
    }

    if (plan.status.toLowerCase() == 'draft') {
      return _l10n.profileSnapshotOpenWorkspace;
    }

    return _l10n.profileSnapshotOpenBudget;
  }

  /// 处理退出登录
  Future<void> logout() async {
    try {
      log('🚪 开始执行退出登录...');
      log('   当前用户: ${currentUser?.name ?? "Unknown"}');

      // 执行登出
      await authController.logout();

      // 清除用户数据
      userController.clearUser();

      // 清除会员数据
      membershipController?.clearMembership();

      // 清除通知数据
      if (Get.isRegistered<NotificationStateController>()) {
        Get.find<NotificationStateController>().clearNotifications();
      }

      log('✅ 用户状态已清除');

      AppToast.success(
        _l10n.profileLogoutSuccessMessage,
        title: _l10n.profileLogoutSuccessTitle,
      );

      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('❌ 退出登录失败: $e');
      AppToast.error(
        _l10n.profileLogoutErrorMessage,
        title: _l10n.error,
      );
    }
  }
}

class NomadProfileSnapshot {
  final String nextDestination;
  final String? departureDateLabel;
  final String budgetLane;
  final String workTimezone;
  final String stayRhythm;
  final String communityMomentum;
  final String baseLocation;
  final String migrationStatus;
  final String profileReadiness;
  final String focusRouteName;
  final String focusRouteLabel;
  final String secondaryRouteName;
  final String secondaryRouteLabel;

  const NomadProfileSnapshot({
    required this.nextDestination,
    required this.departureDateLabel,
    required this.budgetLane,
    required this.workTimezone,
    required this.stayRhythm,
    required this.communityMomentum,
    required this.baseLocation,
    required this.migrationStatus,
    required this.profileReadiness,
    required this.focusRouteName,
    required this.focusRouteLabel,
    required this.secondaryRouteName,
    required this.secondaryRouteLabel,
  });
}

class NomadCollaborationProfile {
  final String professionalIdentity;
  final String languageAbility;
  final String collaborationMode;
  final String discoveryReadiness;
  final List<String> skillTags;
  final List<String> interestTags;
  final List<String> socialTags;

  const NomadCollaborationProfile({
    required this.professionalIdentity,
    required this.languageAbility,
    required this.collaborationMode,
    required this.discoveryReadiness,
    required this.skillTags,
    required this.interestTags,
    required this.socialTags,
  });
}
