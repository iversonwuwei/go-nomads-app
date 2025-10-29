import 'package:flutter/material.dart' hide Badge;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../config/profile_presets.dart';
import '../controllers/locale_controller.dart';
import '../controllers/user_profile_controller.dart';
import '../controllers/user_state_controller.dart';
import '../generated/app_localizations.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';
import '../widgets/app_toast.dart';
import '../widgets/skeletons/skeletons.dart';

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

  Future<void> _handleAvatarUpload(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();

      // 显示选择对话框：相册或相机
      final source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          final l10n = AppLocalizations.of(context)!;
          return AlertDialog(
            title: Text(l10n.chooseImageSource),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(l10n.gallery),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text(l10n.camera),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      // 选择图片
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return;

      // TODO: 这里需要上传图片到服务器并获取URL
      // 暂时显示上传成功提示
      if (context.mounted) {
        AppToast.success(
          'Avatar image selected: ${image.name}',
          title: 'Success',
        );
      }

      // 后续需要：
      // 1. 上传图片到云存储服务（如 Supabase Storage）
      // 2. 获取上传后的 URL
      // 3. 调用 UserProfileController 更新头像 URL
      // 例如:
      // final controller = Get.find<UserProfileController>();
      // await controller.updateAvatar(imageUrl);
    } catch (e) {
      print('❌ 上传头像失败: $e');
      if (context.mounted) {
        AppToast.error(
          'Failed to upload avatar',
          title: 'Error',
        );
      }
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
                    if (controller.isEditMode.value) {
                      AppToast.info(
                        l10n.editModeEnabled,
                        title: l10n.editProfile,
                      );
                    } else {
                      AppToast.success(
                        l10n.editModeSaved,
                        title: l10n.editProfile,
                      );
                    }
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
                    _buildProfileHeader(context, user, controller, isMobile),
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

  // 构建头像内容 - 如果没有头像URL则显示用户名首字母
  Widget _buildAvatarContent(UserModel user, bool isMobile) {
    final hasAvatar = user.avatarUrl != null &&
        user.avatarUrl!.isNotEmpty &&
        user.avatarUrl != 'https://i.pravatar.cc/300';

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
  Widget _buildInitialsAvatar(UserModel user, bool isMobile) {
    // 获取用户名首字母
    String initials = '';
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        // 如果有多个单词，取前两个单词的首字母
        initials =
            nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        // 如果只有一个单词，取前两个字母（如果有）
        initials =
            user.name.substring(0, user.name.length >= 2 ? 2 : 1).toUpperCase();
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
  Widget _buildProfileHeader(BuildContext context, UserModel user,
      UserProfileController controller, bool isMobile) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        GestureDetector(
          onTap: controller.isEditMode.value
              ? () => _handleAvatarUpload(context)
              : null,
          child: Stack(
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
              // 相机图标覆盖层 - 仅在编辑模式下显示
              if (controller.isEditMode.value)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: isMobile ? 32 : 40,
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
            _buildStatCard(
                '❤️', stats.favorites.toString(), 'Favorites', isMobile),
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
    final isEditMode = controller.isEditMode.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.skills,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a))),
            if (isEditMode)
              TextButton.icon(
                onPressed: () => _showAddSkillDialog(context, controller),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: Text(l10n.addSkill),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFF4458),
                ),
              ),
          ],
        ),
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
                        Icons.lightbulb_outline,
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
                      if (isEditMode) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddSkillDialog(context, controller),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addSkill),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4458),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 32,
                              vertical: isMobile ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.skills.map((skill) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              const Color(0xFFFF4458).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          skill,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFFF4458)),
                        ),
                        if (isEditMode) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.removeSkill(skill),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFFFF4458),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
        const SizedBox(height: 24),

        // Interests Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.interests,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a))),
            if (isEditMode)
              TextButton.icon(
                onPressed: () => _showAddInterestDialog(context, controller),
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: Text(l10n.addInterest),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                ),
              ),
          ],
        ),
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
                        Icons.favorite_outline,
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
                      if (isEditMode) ...[
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddInterestDialog(context, controller),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addInterest),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF374151),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 24 : 32,
                              vertical: isMobile ? 12 : 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: user.interests.map((interest) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          interest,
                          style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151)),
                        ),
                        if (isEditMode) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.removeInterest(interest),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  // Show Add Skill Dialog with Presets
  void _showAddSkillDialog(
      BuildContext context, UserProfileController controller) {
    final l10n = AppLocalizations.of(context)!;

    Get.bottomSheet(
      _SkillSelectorSheet(
        controller: controller,
        l10n: l10n,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Show Add Interest Dialog with Presets
  void _showAddInterestDialog(
      BuildContext context, UserProfileController controller) {
    final l10n = AppLocalizations.of(context)!;

    Get.bottomSheet(
      _InterestSelectorSheet(
        controller: controller,
        l10n: l10n,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // Travel History
  Widget _buildTravelHistory(
      BuildContext context, List<TravelHistory> history, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.travelHistory,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a))),
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
                        Icons.explore_outlined,
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
                children: history
                    .map((trip) => _buildTravelHistoryCard(trip))
                    .toList(),
              ),
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
                    Get.toNamed(AppRoutes.cityList);
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

// 技能选择器底部弹窗
class _SkillSelectorSheet extends StatefulWidget {
  final UserProfileController controller;
  final AppLocalizations l10n;

  const _SkillSelectorSheet({
    required this.controller,
    required this.l10n,
  });

  @override
  State<_SkillSelectorSheet> createState() => _SkillSelectorSheetState();
}

class _SkillSelectorSheetState extends State<_SkillSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  String _searchQuery = '';
  bool _showCustomInput = false;

  List<String> get _availableSkills {
    final currentSkills = widget.controller.currentUser.value?.skills ?? [];
    final allSkills = ProfilePresets.skills;

    // 过滤掉已经添加的技能
    var filtered =
        allSkills.where((skill) => !currentSkills.contains(skill)).toList();

    // 如果有搜索词，进一步过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((skill) =>
              skill.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.l10n.addSkill,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索技能...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Custom Input Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCustomInput = !_showCustomInput;
                      });
                    },
                    icon: Icon(_showCustomInput ? Icons.grid_view : Icons.edit),
                    label: Text(_showCustomInput ? '选择预设' : '自定义输入'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF4458),
                      side: const BorderSide(color: Color(0xFFFF4458)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _showCustomInput ? _buildCustomInput() : _buildPresetList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _customController,
            decoration: InputDecoration(
              hintText: widget.l10n.enterSkillName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_customController.text.trim().isNotEmpty) {
                widget.controller.addSkill(_customController.text.trim());
                Get.back();
                AppToast.success('已添加：${_customController.text.trim()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.l10n.add),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSkills.map((skill) {
            return InkWell(
              onTap: () {
                widget.controller.addSkill(skill);
                Get.back();
                AppToast.success('已添加：$skill');
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      skill,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFF4458),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: Color(0xFFFF4458),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// 兴趣选择器底部弹窗
class _InterestSelectorSheet extends StatefulWidget {
  final UserProfileController controller;
  final AppLocalizations l10n;

  const _InterestSelectorSheet({
    required this.controller,
    required this.l10n,
  });

  @override
  State<_InterestSelectorSheet> createState() => _InterestSelectorSheetState();
}

class _InterestSelectorSheetState extends State<_InterestSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customController = TextEditingController();
  String _searchQuery = '';
  bool _showCustomInput = false;

  List<String> get _availableInterests {
    final currentInterests =
        widget.controller.currentUser.value?.interests ?? [];
    final allInterests = ProfilePresets.interests;

    // 过滤掉已经添加的兴趣
    var filtered = allInterests
        .where((interest) => !currentInterests.contains(interest))
        .toList();

    // 如果有搜索词，进一步过滤
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((interest) =>
              interest.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _customController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.l10n.addInterest,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索兴趣...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Custom Input Toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showCustomInput = !_showCustomInput;
                      });
                    },
                    icon: Icon(_showCustomInput ? Icons.grid_view : Icons.edit),
                    label: Text(_showCustomInput ? '选择预设' : '自定义输入'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF374151),
                      side: const BorderSide(color: Color(0xFF374151)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _showCustomInput ? _buildCustomInput() : _buildPresetList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _customController,
            decoration: InputDecoration(
              hintText: widget.l10n.enterInterestName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            textCapitalization: TextCapitalization.words,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_customController.text.trim().isNotEmpty) {
                widget.controller.addInterest(_customController.text.trim());
                Get.back();
                AppToast.success('已添加：${_customController.text.trim()}');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF374151),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(widget.l10n.add),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableInterests.map((interest) {
            return InkWell(
              onTap: () {
                widget.controller.addInterest(interest);
                Get.back();
                AppToast.success('已添加：$interest');
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      interest,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF374151),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.add_circle_outline,
                      size: 18,
                      color: Color(0xFF374151),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}
