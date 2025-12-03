import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/ai/presentation/controllers/ai_state_controller.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/features/notification/presentation/controllers/notification_state_controller.dart';
import 'package:df_admin_mobile/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:df_admin_mobile/features/user/domain/entities/user.dart';
import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:df_admin_mobile/routes/route_refresh_observer.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with RouteAwareRefreshMixin<ProfilePage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时刷新用户数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  /// 加载用户数据
  Future<void> _loadUserData() async {
    final controller = Get.find<UserStateController>();

    // 先检查 Token 是否存在
    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      log('⚠️ 用户未登录，跳转到登录页');
      AppToast.info('Please login to view your profile', title: 'Login Required');
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // 尝试加载用户数据
    if (controller.isLoggedIn) {
      await controller.loadUserProfile();

      // 加载后检查是否成功（如果失败会清除 currentUser）
      if (!mounted) return;

      if (controller.currentUser.value == null && controller.errorMessage.value.isNotEmpty) {
        log('⚠️ 加载用户数据失败，跳转到登录页');
        AppToast.info('Please login again', title: 'Session Expired');
        Get.offAllNamed(AppRoutes.login);
      }

      // 加载用户统计数据
      controller.loadNomadStats();

      // 加载用户旅行计划
      _loadUserTravelPlans();
    }
  }

  /// 加载用户旅行计划
  Future<void> _loadUserTravelPlans() async {
    try {
      final aiController = Get.find<AiStateController>();
      await aiController.loadUserTravelPlans(page: 1, pageSize: 1);
    } catch (e) {
      log('⚠️ 加载用户旅行计划失败: $e');
    }
  }

  /// 处理退出登录
  void _handleLogout(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 显示确认对话框
    Get.dialog(
      AlertDialog(
        title: Text(l10n.logoutConfirmTitle),
        content: Text(l10n.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // 关闭对话框
              _performLogout();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF4458),
            ),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );
  }

  /// 执行退出登录操作
  Future<void> _performLogout() async {
    try {
      log('🚪 开始执行退出登录...');

      // 获取控制器
      final authController = Get.find<AuthStateController>();
      final userStateController = Get.find<UserStateController>();

      log('   当前登录状态: ${userStateController.isLoggedIn}');
      log('   当前用户: ${userStateController.currentUser.value?.name ?? "Unknown"}');
      log('   当前账户ID: ${userStateController.currentUser.value?.id ?? "0"}');

      // 调用 AuthStateController 的 logout 方法
      await authController.logout();

      // 清除 UserStateController 状态
      userStateController.clearUser();

      // 清除通知控制器状态
      if (Get.isRegistered<NotificationStateController>()) {
        final notificationController = Get.find<NotificationStateController>();
        notificationController.clearNotifications();
      }

      log('✅ 用户状态已清除');
      log('   登录状态: ${userStateController.isLoggedIn}');

      // 显示退出成功提示
      AppToast.success(
        'You have been logged out successfully',
        title: 'Logout Success',
      );

      // 跳转到登录页
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      log('❌ 退出登录失败: $e');
      AppToast.error(
        'An error occurred during logout',
        title: 'Error',
      );
    }
  }

  @override
  Future<void> onRouteResume() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserStateController>();
    final authController = Get.find<AuthStateController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const ProfileSkeleton();
          }

          final user = controller.currentUser.value;

          // 如果用户数据为空，检查是否需要跳转登录
          if (user == null) {
            // 检查认证状态
            if (!authController.isAuthenticated.value) {
              // Token 不存在，直接跳转
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Get.offAllNamed(AppRoutes.login);
              });
            } else if (controller.errorMessage.value.isNotEmpty) {
              // 有错误信息（比如 401），延迟跳转
              WidgetsBinding.instance.addPostFrameCallback((_) {
                AppToast.info('Please login again', title: 'Session Expired');
                Get.offAllNamed(AppRoutes.login);
              });
            }

            // 在跳转前显示加载状态，避免闪现 "用户未找到"
            return const ProfileSkeleton();
          }

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadUserProfile();
            },
            child: CustomScrollView(
              slivers: [
                // 移除旧 AppBar - 不需要 header

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 32,
                      vertical: isMobile ? 24 : 32, // 减少顶部留白，SafeArea 已处理
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Login Notice (if not logged in)
                        if (!controller.isLoggedIn) _buildLoginNotice(context, isMobile),

                        // Profile Header
                        _buildProfileHeader(context, user, controller, isMobile),
                        const SizedBox(height: 32),

                        // My Travel Plans (AI Generated)
                        _buildTravelPlansSection(context, isMobile),
                        const SizedBox(height: 32),

                        // Stats
                        _buildStatsSection(context, isMobile),
                        const SizedBox(height: 32),

                        // Badges
                        _buildBadgesSection(context, user.badges, isMobile),
                        const SizedBox(height: 32),

                        // Skills & Interests
                        _buildSkillsAndInterests(context, user, controller, isMobile),
                        const SizedBox(height: 32),

                        // Travel History
                        _buildTravelHistory(context, user.travelHistory, isMobile),
                        const SizedBox(height: 32),

                        // Social Links
                        _buildSocialLinks(context, user.socialLinks, isMobile),

                        const SizedBox(height: 48),

                        // Legacy API Profile Link
                        _buildLegacyProfileLink(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // 构建头像内容 - 如果没有头像URL则显示用户名首字母
  Widget _buildAvatarContent(User user, bool isMobile) {
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.isNotEmpty && user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    if (hasAvatar) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          // 如果图片加载失败，显示首字母
          return _buildInitialsAvatar(user, isMobile);
        },
      );
    } else {
      return _buildInitialsAvatar(user, isMobile);
    }
  }

  // 构建首字母头像
  Widget _buildInitialsAvatar(User user, bool isMobile) {
    // 获取用户名首字母
    String initials = '';
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        // 如果有多个单词，取前两个单词的首字母
        initials = nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        // 如果只有一个单词，取前两个字母（如果有的话）
        initials = user.name.substring(0, user.name.length >= 2 ? 2 : 1).toUpperCase();
      }
    } else {
      initials = '?';
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFF4458),
            const Color(0xFFFF6B7A),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(BuildContext context, User user, UserStateController controller, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar (只读，移除编辑功能)
        Stack(
          children: [
            Container(
              width: isMobile ? 80 : 120,
              height: isMobile ? 80 : 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFFF4458),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: _buildAvatarContent(user, isMobile),
              ),
            ),
            if (user.isVerified)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: isMobile ? 24 : 32,
                  height: isMobile ? 24 : 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4458),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(width: 20),

        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1a1a1a),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (user.isVerified)
                    const Icon(
                      FontAwesomeIcons.circleCheck,
                      color: Color(0xFFFF4458),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                user.username,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6b7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (user.currentCity != null && user.currentCountry != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.locationDot,
                      size: 18,
                      color: Color(0xFFFF4458),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${user.currentCity}, ${user.currentCountry}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1a1a1a),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
              if (user.bio != null) ...[
                const SizedBox(height: 16),
                Text(
                  user.bio!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF374151),
                    height: 1.6,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                'Member since ${_formatJoinDate(user.joinedDate)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9ca3af),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Stats Section - 使用后端返回的 NomadStats
  Widget _buildStatsSection(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<UserStateController>();

    return Obx(() {
      final stats = controller.nomadStats.value;
      final favoriteCityCount = controller.favoriteCityIds.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomad Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildStatCard('🌍', (stats?.countriesVisited ?? 0).toString(), 'Countries', isMobile),
              _buildStatCard('🏙️', (stats?.citiesLived ?? 0).toString(), l10n.cities, isMobile),
              _buildStatCard('📅', (stats?.daysNomading ?? 0).toString(), 'Days nomading', isMobile),
              _buildClickableStatCard(
                '🤝',
                (stats?.meetupsCreated ?? 0).toString(),
                'Meetups',
                isMobile,
                onTap: () => Get.toNamed(AppRoutes.myMeetups),
              ),
              _buildStatCard('✈️', (stats?.tripsCompleted ?? 0).toString(), 'Trips', isMobile),
              _buildClickableStatCard(
                '❤️',
                (stats?.favoriteCitiesCount ?? favoriteCityCount).toString(),
                'Favorites',
                isMobile,
                onTap: () => Get.toNamed(AppRoutes.favorites),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildStatCard(String emoji, String value, String label, bool isMobile) {
    return Container(
      width: isMobile ? ((Get.width - 44) / 2) : 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6b7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClickableStatCard(String emoji, String value, String label, bool isMobile, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? ((Get.width - 44) / 2) : 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6b7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    FontAwesomeIcons.chevronRight,
                    size: 10,
                    color: Color(0xFF6b7280),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Badges Section
  Widget _buildBadgesSection(BuildContext context, List<Badge> badges, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.badges,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: badges.map((badge) => _buildBadgeCard(badge)).toList(),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(badge.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                badge.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge.description,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Skills and Interests
  Widget _buildSkillsAndInterests(BuildContext context, User user, UserStateController controller, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        Text(l10n.skills, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        user.skills.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 40 : 60,
                  horizontal: isMobile ? 20 : 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.lightbulb,
                        size: isMobile ? 48 : 64,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No skills added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (skill.hasIcon) ...[
                          Text(
                            skill.icon!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          skill.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFFF4458)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 24),

        // Interests Section
        Text(l10n.interests,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        user.interests.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 40 : 60,
                  horizontal: isMobile ? 20 : 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.heart,
                        size: isMobile ? 48 : 64,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No interests added yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (interest.hasIcon) ...[
                          Text(
                            interest.icon!,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          interest.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // Travel History
  Widget _buildTravelHistory(BuildContext context, List<TravelHistory> history, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.travelHistory,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        history.isEmpty
            ? Container(
                padding: EdgeInsets.symmetric(
                  vertical: isMobile ? 40 : 60,
                  horizontal: isMobile ? 20 : 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        FontAwesomeIcons.compass,
                        size: isMobile ? 48 : 64,
                        color: Colors.grey.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No travel history yet',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your digital nomad journey!',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Column(
                children: history.map((trip) => _buildTravelHistoryCard(trip)).toList(),
              ),
      ],
    );
  }

  Widget _buildTravelHistoryCard(TravelHistory trip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${trip.cityName}, ${trip.countryName ?? "Unknown"}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(trip.visitDate),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF6b7280)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(trip.cityName, style: const TextStyle(fontSize: 14, color: Color(0xFF374151), height: 1.5)),
        ],
      ),
    );
  }

  // Social Links
  Widget _buildSocialLinks(BuildContext context, Map<String, String> links, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.connect, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: links.entries.map((entry) => _buildSocialLinkButton(entry.key, entry.value)).toList(),
        ),
      ],
    );
  }

  Widget _buildSocialLinkButton(String platform, String url) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'twitter':
        icon = FontAwesomeIcons.rocket;
        color = const Color(0xFF1DA1F2);
        break;
      case 'github':
        icon = FontAwesomeIcons.code;
        color = const Color(0xFF171515);
        break;
      case 'linkedin':
        icon = FontAwesomeIcons.building;
        color = const Color(0xFF0A66C2);
        break;
      case 'website':
        icon = FontAwesomeIcons.globe;
        color = const Color(0xFF6B7280);
        break;
      default:
        icon = FontAwesomeIcons.link;
        color = const Color(0xFF6B7280);
    }

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Text(platform.toUpperCase(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }

  // Legacy Profile Link
  Widget _buildLegacyProfileLink(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        // 退出登录
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              const Icon(FontAwesomeIcons.rightFromBracket, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.logout,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _handleLogout(context);
                },
                child: Text(l10n.logout, style: const TextStyle(color: Color(0xFFFF4458))),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 我的旅行计划部分
  Widget _buildTravelPlansSection(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    final aiController = Get.find<AiStateController>();

    return Obx(() {
      final latestPlan = aiController.latestTravelPlan;
      final isLoading = aiController.isLoadingUserPlans;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                FontAwesomeIcons.wandMagicSparkles,
                color: Color(0xFFFF4458),
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'My Travel Plans',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (latestPlan != null) ...[
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Get.toNamed(AppRoutes.cityList);
                  },
                  icon: const Icon(FontAwesomeIcons.plus, size: 16),
                  label: Text(l10n.createNew),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4458),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading)
            _buildLoadingPlanCard()
          else if (latestPlan == null)
            _buildEmptyPlansCard(context, l10n)
          else
            _buildLatestPlanCard(latestPlan),
        ],
      );
    });
  }

  /// 加载中的计划卡片
  Widget _buildLoadingPlanCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
        ),
      ),
    );
  }

  /// 空计划卡片
  Widget _buildEmptyPlansCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FontAwesomeIcons.earthAmericas,
              size: 48,
              color: Color(0xFFFF4458),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Travel Plans Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate AI-powered travel plans from city detail pages',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Get.toNamed(AppRoutes.cityList);
            },
            icon: const Icon(FontAwesomeIcons.compass, size: 18),
            label: Text(l10n.exploreCities),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 最新旅行计划卡片
  Widget _buildLatestPlanCard(TravelPlanSummary plan) {
    return GestureDetector(
      onTap: () {
        // 导航到旅行计划详情页
        Get.toNamed(
          AppRoutes.travelPlan,
          arguments: {
            'planId': plan.id,
            'cityId': plan.cityId,
            'cityName': plan.cityName,
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 城市图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  if (plan.cityImage != null && plan.cityImage!.isNotEmpty)
                    Image.network(
                      plan.cityImage!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 120,
                          color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                          child: const Center(
                            child: Icon(
                              FontAwesomeIcons.city,
                              size: 40,
                              color: Color(0xFFFF4458),
                            ),
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      height: 120,
                      color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                      child: const Center(
                        child: Icon(
                          FontAwesomeIcons.city,
                          size: 40,
                          color: Color(0xFFFF4458),
                        ),
                      ),
                    ),
                  // 渐变遮罩
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 城市名称
                  Positioned(
                    bottom: 12,
                    left: 16,
                    child: Text(
                      plan.cityName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // AI 标签
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4458),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            FontAwesomeIcons.wandMagicSparkles,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'AI Generated',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 计划详情
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标签行
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPlanTag(
                        FontAwesomeIcons.calendarDays,
                        '${plan.duration} days',
                      ),
                      _buildPlanTag(
                        FontAwesomeIcons.dollarSign,
                        plan.budgetLevelDisplay,
                      ),
                      _buildPlanTag(
                        FontAwesomeIcons.paintbrush,
                        plan.travelStyleDisplay,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 创建时间
                  Row(
                    children: [
                      Icon(
                        FontAwesomeIcons.clock,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Created ${plan.formattedCreatedAt}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        FontAwesomeIcons.chevronRight,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 计划标签
  Widget _buildPlanTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFFFF4458)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Preferences Section
  // 登录提示卡片
  Widget _buildLoginNotice(BuildContext context, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFB84D),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.circleInfo,
            color: Color(0xFFFF8C00),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '示例数据预览',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1a1a1a),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '您当前查看的是示例用户资料。登录后可查看您的真实个人信息。',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Get.toNamed(AppRoutes.login);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              '去登录',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
