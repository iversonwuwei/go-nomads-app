import 'package:flutter/material.dart' hide Badge;
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../controllers/locale_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';
import 'city_list_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
  void _performLogout() {
    try {
      print('🚪 开始执行退出登录...');

      // 获取用户状态控制器
      final userStateController = Get.find<UserStateController>();

      print('   当前登录状态: ${userStateController.isLoggedIn}');
      print('   当前用户: ${userStateController.username}');
      print('   当前账户ID: ${userStateController.currentAccountId}');

      // 清除用户状态
      userStateController.logout();

      print('✅ 用户状态已清除');
      print('   登录状态: ${userStateController.isLoggedIn}');
      print('   账户ID: ${userStateController.currentAccountId}');

      // 显示退出成功提示
      AppToast.success(
        'You have been logged out successfully',
        title: 'Logout Success',
      );

      // 延迟一小段时间让用户看到提示，然后跳转到登录页
      Future.delayed(const Duration(milliseconds: 500), () {
        print('🔄 跳转到登录页...');
        Get.offAllNamed(AppRoutes.login);
      });
    } catch (e) {
      print('❌ 退出登录失败: $e');
      AppToast.error(
        'An error occurred during logout',
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserProfileController());
    final userStateController = Get.find<UserStateController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const ProfileSkeleton();
        }

        final user = controller.currentUser.value;
        if (user == null) {
          return Center(child: Text(l10n.userNotFound));
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                l10n.profile,
                style: const TextStyle(
                  color: Color(0xFF1a1a1a),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    controller.isEditMode.value ? Icons.check : Icons.edit,
                    color: const Color(0xFFFF4458),
                  ),
                  onPressed: () {
                    controller.toggleEditMode();
                    AppToast.info(
                      l10n.profileEditingComingSoon,
                      title: l10n.editProfile,
                    );
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Login Notice (if not logged in)
                    if (!userStateController.isLoggedIn)
                      _buildLoginNotice(context, isMobile),

                    // Profile Header
                    _buildProfileHeader(context, user, isMobile),
                    const SizedBox(height: 32),

                    // My Travel Plans (AI Generated)
                    _buildTravelPlansSection(context, isMobile),
                    const SizedBox(height: 32),

                    // Stats
                    _buildStatsSection(context, user.stats, isMobile),
                    const SizedBox(height: 32),

                    // Badges
                    _buildBadgesSection(context, user.badges, isMobile),
                    const SizedBox(height: 32),

                    // Skills & Interests
                    _buildSkillsAndInterests(
                        context, user, controller, isMobile),
                    const SizedBox(height: 32),

                    // Travel History
                    _buildTravelHistory(context, user.travelHistory, isMobile),
                    const SizedBox(height: 32),

                    // Social Links
                    _buildSocialLinks(context, user.socialLinks, isMobile),

                    const SizedBox(height: 32),

                    // Preferences
                    _buildPreferencesSection(isMobile),

                    const SizedBox(height: 48),

                    // Legacy API Profile Link
                    _buildLegacyProfileLink(context),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Profile Header
  Widget _buildProfileHeader(
      BuildContext context, UserModel user, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
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
                child: Image.network(
                  user.avatarUrl ?? 'https://i.pravatar.cc/300',
                  fit: BoxFit.cover,
                ),
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
                    Icons.check,
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
                      Icons.verified,
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
                      Icons.location_on,
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

  // Stats Section
  Widget _buildStatsSection(
      BuildContext context, TravelStats stats, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
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
            _buildStatCard(
                '🌍', stats.countriesVisited.toString(), 'Countries', isMobile),
            _buildStatCard(
                '🏙️', stats.citiesLived.toString(), l10n.cities, isMobile),
            _buildStatCard(
                '📅', stats.daysNomading.toString(), 'Days nomading', isMobile),
            _buildStatCard(
                '🤝', stats.meetupsAttended.toString(), 'Meetups', isMobile),
            _buildStatCard(
                '✈️', stats.tripsCompleted.toString(), 'Trips', isMobile),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String emoji, String value, String label, bool isMobile) {
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

  // Badges Section
  Widget _buildBadgesSection(
      BuildContext context, List<Badge> badges, bool isMobile) {
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
  Widget _buildSkillsAndInterests(BuildContext context, UserModel user,
      UserProfileController controller, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.skills,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: user.skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
              ),
              child: Text(
                skill,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(l10n.interests,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 12),
        Wrap(
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
              child: Text(
                interest,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Travel History
  Widget _buildTravelHistory(
      BuildContext context, List<TravelHistory> history, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.travelHistory,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        ...history.map((trip) => _buildTravelHistoryCard(trip)),
      ],
    );
  }

  Widget _buildTravelHistoryCard(TravelHistory trip) {
    final isCurrentLocation = trip.endDate == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentLocation
            ? const Color(0xFFFF4458).withValues(alpha: 0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentLocation
              ? const Color(0xFFFF4458).withValues(alpha: 0.3)
              : const Color(0xFFE5E7EB),
          width: isCurrentLocation ? 2 : 1,
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
                    Row(
                      children: [
                        Text('${trip.city}, ${trip.country}',
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a1a1a))),
                        if (isCurrentLocation) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: const Color(0xFFFF4458),
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text('Current',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatDate(trip.startDate)} - ${trip.endDate != null ? _formatDate(trip.endDate!) : 'Present'}',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6b7280)),
                    ),
                  ],
                ),
              ),
              if (trip.rating != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      const Icon(Icons.star,
                          size: 16, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 4),
                      Text(trip.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E))),
                    ],
                  ),
                ),
            ],
          ),
          if (trip.review != null) ...[
            const SizedBox(height: 12),
            Text(trip.review!,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF374151), height: 1.5)),
          ],
        ],
      ),
    );
  }

  // Social Links
  Widget _buildSocialLinks(
      BuildContext context, Map<String, String> links, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.connect,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: links.entries
              .map((entry) => _buildSocialLinkButton(entry.key, entry.value))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSocialLinkButton(String platform, String url) {
    IconData icon;
    Color color;

    switch (platform.toLowerCase()) {
      case 'twitter':
        icon = Icons.flutter_dash;
        color = const Color(0xFF1DA1F2);
        break;
      case 'github':
        icon = Icons.code;
        color = const Color(0xFF171515);
        break;
      case 'linkedin':
        icon = Icons.business;
        color = const Color(0xFF0A66C2);
        break;
      case 'website':
        icon = Icons.language;
        color = const Color(0xFF6B7280);
        break;
      default:
        icon = Icons.link;
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
            Text(platform.toUpperCase(),
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: color)),
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
              const Icon(Icons.logout, color: Color(0xFF6B7280), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.logout,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151)),
                ),
              ),
              TextButton(
                onPressed: () {
                  _handleLogout(context);
                },
                child: Text(l10n.logout,
                    style: const TextStyle(color: Color(0xFFFF4458))),
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
    // 这里应该从用户数据中获取保存的计划
    // 暂时使用空列表演示
    final savedPlans = <String>[]; // TODO: 从UserProfileController获取

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.auto_awesome,
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
            if (savedPlans.isNotEmpty) ...[
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  AppToast.info(
                    'Visit city details and click "AI Travel Plan" to generate new plans',
                    title: 'Info',
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(l10n.createNew),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4458),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (savedPlans.isEmpty)
          Container(
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
                    Icons.travel_explore,
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
                    Get.to(() => const CityListPage());
                  },
                  icon: const Icon(Icons.explore, size: 18),
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
          )
        else
          // TODO: 显示保存的旅行计划列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: savedPlans.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Text(l10n.travelPlanCard), // Placeholder
              );
            },
          ),
      ],
    );
  }

  String _formatJoinDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Preferences Section
  Widget _buildPreferencesSection(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(
                l10n.preferences,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1a1a1a),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _buildLanguageTile(isMobile),
        ],
      ),
    );
  }

  // Language Selection Tile
  Widget _buildLanguageTile(bool isMobile) {
    final localeController = Get.find<LocaleController>();

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;

        return InkWell(
          onTap: () => Get.toNamed(AppRoutes.languageSettings),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Row(
              children: [
                Icon(
                  Icons.language,
                  color: const Color(0xFFFF4458),
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.language,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1a1a1a),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            localeController.currentLanguageName,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: const Color(0xFF6B7280),
                            ),
                          )),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFF6B7280),
                  size: isMobile ? 20 : 24,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 登录提示卡片
  Widget _buildLoginNotice(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;

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
            Icons.info_outline,
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
