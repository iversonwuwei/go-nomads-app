import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/modular_user_profile_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import 'edit_basic_info_page.dart';
import 'edit_interests_page.dart';
import 'edit_skills_page.dart';
import 'edit_social_links_page.dart';

/// 模块化用户资料页面 - 整合所有8个模块
class ModularUserProfilePage extends StatelessWidget {
  final int accountId;
  final String? username;

  const ModularUserProfilePage({
    super.key,
    required this.accountId,
    this.username,
  });

  static String _generateTag(int accountId) => 'ModularUserProfilePage_$accountId';

  ModularUserProfilePageController _useController() {
    final tag = _generateTag(accountId);
    if (Get.isRegistered<ModularUserProfilePageController>(tag: tag)) {
      return Get.find<ModularUserProfilePageController>(tag: tag);
    }
    return Get.put(
      ModularUserProfilePageController(accountId: accountId, username: username),
      tag: tag,
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28.r),
            SizedBox(height: 8.h),
            Text(
              '$value',
              style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required String content,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? Colors.blue,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Icon(FontAwesomeIcons.arrowRight, size: 16.r),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(username ?? l10n.modularProfileTitle),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.arrowsRotate),
            onPressed: controller.loadProfileData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const UserProfileSkeleton();
        }

        return RefreshIndicator(
          onRefresh: controller.loadProfileData,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // 头部 - 头像和基本信息
              Center(
                child: Column(
                  children: [
                    SafeCircleAvatar(
                      imageUrl: controller.basicInfo.value?.avatarUrl,
                      radius: 50,
                      errorWidget: Icon(FontAwesomeIcons.user, size: 50.r),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      controller.basicInfo.value?.name ?? l10n.modularProfileNameUnset,
                      style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                    ),
                    if (controller.basicInfo.value?.occupation != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        controller.basicInfo.value!.occupation!,
                        style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
                      ),
                    ],
                    if (controller.basicInfo.value?.currentCity != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.locationDot, size: 16.r, color: Colors.grey.shade600),
                          SizedBox(width: 4.w),
                          Text(
                            '${controller.basicInfo.value!.currentCity}, ${controller.basicInfo.value!.currentCountry ?? ''}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                    if (controller.basicInfo.value?.bio != null) ...[
                      SizedBox(height: 12.h),
                      Text(
                        controller.basicInfo.value!.bio!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Nomad统计
              if (controller.stats.value != null) ...[
                Text(
                  l10n.modularProfileStatsTitle,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12.h),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 1.2,
                  mainAxisSpacing: 8.w,
                  crossAxisSpacing: 8.w,
                  children: [
                    _buildStatCard('国家', controller.stats.value!.countriesVisited, FontAwesomeIcons.flag, Colors.blue),
                    _buildStatCard(l10n.modularProfileStatCountries, controller.stats.value!.countriesVisited,
                        FontAwesomeIcons.flag, Colors.blue),
                    _buildStatCard(l10n.modularProfileStatCities, controller.stats.value!.citiesLived,
                        FontAwesomeIcons.city, Colors.green),
                    _buildStatCard(
                      l10n.modularProfileStatDays, controller.stats.value!.daysNomading,
                        FontAwesomeIcons.calendar, Colors.orange),
                    _buildStatCard(
                      l10n.modularProfileStatMeetups, controller.stats.value!.meetupsAttended,
                        FontAwesomeIcons.userGroup, Colors.purple),
                    _buildStatCard(
                      l10n.modularProfileStatTrips, controller.stats.value!.tripsCompleted,
                        FontAwesomeIcons.ticketSimple, Colors.red),
                    _buildStatCard(
                      l10n.modularProfileStatReviews, controller.stats.value!.reviewsWritten,
                        FontAwesomeIcons.commentDots, Colors.teal),
                  ],
                ),
                SizedBox(height: 24.h),
              ],

              // 模块卡片
              _buildModuleCard(
                title: l10n.modularProfileModuleBasicInfo,
                icon: FontAwesomeIcons.user,
                content: controller.basicInfo.value != null
                    ? l10n.modularProfileBasicInfoSummary(
                        controller.basicInfo.value!.name,
                        controller.basicInfo.value!.occupation ?? l10n.modularProfileOccupationUnset,
                      )
                    : l10n.modularProfileTapToEditBasicInfo,
                onTap: () async {
                  await NavigationUtil.toWithCallback<bool>(
                    page: () => EditBasicInfoPage(accountId: accountId),
                    onResult: (result) {
                      if (result.needsRefresh) {
                        controller.loadProfileData();
                      }
                    },
                  );
                },
                color: Colors.blue,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleSkills,
                icon: FontAwesomeIcons.star,
                content: controller.skills.isEmpty
                    ? l10n.modularProfileTapToAddSkills
                    : l10n.modularProfileSkillsSummary(
                        controller.skills.length,
                        '${controller.skills.take(3).map((s) => s.skillName).join(", ")}${controller.skills.length > 3 ? "..." : ""}',
                      ),
                onTap: () async {
                  await Get.to(() => EditSkillsPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.amber,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleInterests,
                icon: FontAwesomeIcons.heart,
                content: controller.interests.isEmpty
                    ? l10n.modularProfileTapToAddInterests
                    : l10n.modularProfileInterestsSummary(
                        controller.interests.length,
                        '${controller.interests.take(3).map((i) => i.interestName).join(", ")}${controller.interests.length > 3 ? "..." : ""}',
                      ),
                onTap: () async {
                  await Get.to(() => EditInterestsPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.green,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleSocialLinks,
                icon: FontAwesomeIcons.link,
                content: controller.socialLinks.isEmpty
                    ? l10n.modularProfileTapToAddSocialLinks
                    : l10n.modularProfileSocialLinksCount(controller.socialLinks.length),
                onTap: () async {
                  await Get.to(() => EditSocialLinksPage(accountId: accountId));
                  controller.loadProfileData();
                },
                color: Colors.purple,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleTravelPlans,
                icon: FontAwesomeIcons.map,
                content: controller.travelPlans.isEmpty
                    ? l10n.modularProfileNoTravelPlans
                    : l10n.modularProfileTravelPlansCount(controller.travelPlans.length),
                onTap: () {
                  AppToast.error(l10n.modularProfileTravelPlansComingSoon);
                },
                color: Colors.orange,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleBadges,
                icon: FontAwesomeIcons.medal,
                content: controller.badges.isEmpty
                    ? l10n.modularProfileNoBadges
                    : l10n.modularProfileBadgesCount(controller.badges.length),
                onTap: () {
                  AppToast.error(l10n.modularProfileBadgesComingSoon);
                },
                color: Colors.red,
              ),

              _buildModuleCard(
                title: l10n.modularProfileModuleHistory,
                icon: FontAwesomeIcons.clockRotateLeft,
                content: controller.history.isEmpty
                    ? l10n.modularProfileNoHistory
                    : l10n.modularProfileHistoryCount(controller.history.length),
                onTap: () {
                  AppToast.error(l10n.modularProfileHistoryComingSoon);
                },
                color: Colors.teal,
              ),

              SizedBox(height: 32.h),
            ],
          ),
        );
      }),
    );
  }
}
