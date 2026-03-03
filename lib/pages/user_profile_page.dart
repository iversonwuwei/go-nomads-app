import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/user_profile_page_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 用户个人资料页面
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  static const bool _travelHistoryEnabled = true;
  static const String _tag = 'UserProfilePage';

  UserProfilePageController _useController() {
    if (Get.isRegistered<UserProfilePageController>(tag: _tag)) {
      return Get.find<UserProfilePageController>(tag: _tag);
    }
    return Get.put(UserProfilePageController(args: Get.arguments), tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(controller),
      body: SafeArea(
        child: Obx(() {
          final chatUser = controller.chatTargetUser;

          if (controller.shouldBlockForRemoteProfile) {
            return const UserProfileSkeleton();
          }

          final remoteError = controller.remoteProfileError.value;
          if (remoteError != null) {
            return _buildRemoteErrorState(isMobile, controller, remoteError);
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 16 : 24,
              isMobile ? 24 : 32,
              isMobile ? 16 : 24,
              100,
            ),
            children: [
              _buildUserInfoCard(isMobile, chatUser, controller),
              SizedBox(height: 24.h),
              _buildStatsSection(isMobile, controller),
              SizedBox(height: 24.h),
              _buildBadgesSection(isMobile, controller),
              if (_travelHistoryEnabled) ...[
                SizedBox(height: 24.h),
                _buildTravelHistorySection(isMobile, controller),
              ],
              SizedBox(height: 24.h),
              _buildSkillsSection(isMobile, controller),
              SizedBox(height: 24.h),
              _buildInterestsSection(isMobile, controller),
            ],
          );
        }),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(UserProfilePageController controller) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      leading: const AppBackButton(),
      title: Obx(() {
        final username = controller.userInfo['username'] ?? 'Profile';
        return Text(
          username,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
    );
  }

  Widget _buildRemoteErrorState(bool isMobile, UserProfilePageController controller, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 48),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 20 : 32),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(FontAwesomeIcons.circleExclamation, color: Colors.redAccent, size: 56.r),
              SizedBox(height: 16.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: controller.requestedUserId == null
                    ? null
                    : () => controller.fetchUserProfile(controller.requestedUserId!),
                icon: const Icon(FontAwesomeIcons.arrowsRotate),
                label: const Text('重新加载'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 24 : 32,
                    vertical: isMobile ? 12 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('返回上一页'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard(bool isMobile, User? chatUser, UserProfilePageController controller) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() {
            final info = controller.userInfo;
            return SafeCircleAvatar(
              imageUrl: info['avatar'],
              radius: isMobile ? 50 : 70,
              backgroundColor: AppColors.containerBlueGrey,
            );
          }),
          SizedBox(height: isMobile ? 16 : 24),
          Obx(() {
            final info = controller.userInfo;
            return Text(
              info['name'] ?? '',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          SizedBox(height: 6.h),
          Obx(() {
            final info = controller.userInfo;
            return Text(
              info['email'] ?? '',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 14 : 16,
              ),
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final info = controller.userInfo;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.calendar,
                    color: AppColors.accent,
                    size: isMobile ? 14 : 16,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Member since ${info['memberSince'] ?? '--'}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: isMobile ? 20 : 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: chatUser == null ? null : () => _openChat(chatUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 14 : 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 0,
              ),
              icon: const Icon(FontAwesomeIcons.message),
              label: Text(
                'Message',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(bool isMobile, UserProfilePageController controller) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Obx(() {
            final info = controller.userInfo;
            return Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    FontAwesomeIcons.earthAmericas,
                    'Countries',
                    (info['countriesCount'] ?? 0).toString(),
                    Colors.blue,
                    isMobile,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: _buildStatItem(
                    FontAwesomeIcons.city,
                    'Cities',
                    (info['citiesCount'] ?? 0).toString(),
                    Colors.orange,
                    isMobile,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(bool isMobile, UserProfilePageController controller) {
    final user = controller.displayUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final badges = user.badges;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.trophy, color: AppColors.accent, size: isMobile ? 24 : 28),
              SizedBox(width: 8.w),
              Text(
                'Achievements & Badges',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (badges.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 40 : 60,
                horizontal: isMobile ? 20 : 40,
              ),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border.all(color: AppColors.borderLight),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.trophy,
                    size: isMobile ? 48 : 64,
                    color: AppColors.accent,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No badges earned yet',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Start exploring and attending events to earn badges!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 3 : 5,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.w,
                childAspectRatio: 1,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                final badge = badges[index];
                return _buildBadgeCard(badge, isMobile);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(fontSize: isMobile ? 32 : 40),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelHistorySection(bool isMobile, UserProfilePageController controller) {
    final user = controller.displayUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final latestTravel = user.latestTravelHistory;
    final stats = user.stats;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.earthAmericas, color: AppColors.accent, size: isMobile ? 24 : 28),
                  SizedBox(width: 8.w),
                  Text(
                    'Travel Stats',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isMobile ? 16 : 20),
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTravelStatItem(
                  icon: FontAwesomeIcons.flag,
                  value: '${stats.countriesVisited}',
                  label: 'Countries',
                  isMobile: isMobile,
                ),
                _buildStatDivider(),
                _buildTravelStatItem(
                  icon: FontAwesomeIcons.city,
                  value: '${stats.citiesVisited}',
                  label: 'Cities',
                  isMobile: isMobile,
                ),
                _buildStatDivider(),
                _buildTravelStatItem(
                  icon: FontAwesomeIcons.calendarDays,
                  value: '${stats.totalDistanceTraveled.toInt()}',
                  label: 'Days',
                  isMobile: isMobile,
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 16 : 20),
          if (latestTravel != null) ...[
            Text(
              'Latest Location',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            _buildLatestTravelCard(latestTravel, isMobile, controller),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 30 : 40),
                child: Column(
                  children: [
                    Icon(
                      FontAwesomeIcons.plane,
                      size: isMobile ? 40 : 48,
                      color: AppColors.iconSecondary,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No travel history yet',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTravelStatItem({
    required IconData icon,
    required String value,
    required String label,
    required bool isMobile,
  }) {
    return Column(
      children: [
        Icon(icon, size: isMobile ? 16 : 18, color: AppColors.accent),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: isMobile ? 11 : 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40.h,
      width: 1.w,
      color: AppColors.border,
    );
  }

  Widget _buildLatestTravelCard(LatestTravelHistory travel, bool isMobile, UserProfilePageController controller) {
    return GestureDetector(
      onTap: travel.canNavigateToCityDetail ? () => Get.toNamed(AppRoutes.cityDetail, arguments: travel.cityId) : null,
      child: Container(
        padding: EdgeInsets.all(isMobile ? 14 : 18),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 54 : 64,
              height: isMobile ? 54 : 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.border),
              ),
              child: Center(
                child: Text(
                  controller.getCountryFlag(travel.country),
                  style: TextStyle(fontSize: isMobile ? 28 : 36),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    travel.city,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: isMobile ? 17 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    travel.country,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isMobile ? 13 : 15,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        travel.isOngoing ? FontAwesomeIcons.locationDot : FontAwesomeIcons.calendar,
                        size: isMobile ? 12 : 14,
                        color: travel.isOngoing ? Colors.green : AppColors.accent,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        travel.isOngoing
                            ? 'Currently here'
                            : controller.formatTravelDates(
                                travel.arrivalTime, travel.departureTime, travel.durationDays),
                        style: TextStyle(
                          color: travel.isOngoing ? Colors.green : AppColors.textTertiary,
                          fontSize: isMobile ? 12 : 14,
                          fontWeight: travel.isOngoing ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (travel.canNavigateToCityDetail)
              Icon(
                FontAwesomeIcons.chevronRight,
                size: isMobile ? 14 : 16,
                color: AppColors.iconSecondary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: isMobile ? 32 : 40),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 24 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: isMobile ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(bool isMobile, UserProfilePageController controller) {
    final user = controller.displayUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final skills = user.skills;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Skills',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          if (skills.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
                child: Text(
                  'No skills added yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: skills.map((skill) {
                return Chip(
                  label: Text(skill.name),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  side: BorderSide(
                    color: AppColors.accent.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(bool isMobile, UserProfilePageController controller) {
    final user = controller.displayUser;

    if (user == null) {
      return Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final interests = user.interests;

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interests',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          if (interests.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 24 : 32),
                child: Text(
                  'No interests added yet',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              ),
            )
          else
            Wrap(
              spacing: 8.w,
              runSpacing: 8.w,
              children: interests.map((interest) {
                return Chip(
                  label: Text(interest.name),
                  backgroundColor: AppColors.containerBlueGrey.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                  ),
                  side: BorderSide(
                    color: AppColors.containerBlueGrey.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _openChat(User user) {
    Get.toNamed(AppRoutes.directChat, arguments: user);
  }
}
