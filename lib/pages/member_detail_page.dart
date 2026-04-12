import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/member_detail_page_controller.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

import 'invite_to_meetup_page.dart';
import 'tencent_im_direct_chat_page.dart';

class MemberDetailPage extends StatelessWidget {
  final models.User? user;
  final String? userId;
  final String _tag;

  MemberDetailPage({
    super.key,
    this.user,
    this.userId,
  })  : assert(user != null || userId != null, 'Either user or userId must be provided'),
        _tag = 'MemberDetailPage-${userId ?? user?.id ?? 'self'}';

  MemberDetailPageController get _controller {
    if (!Get.isRegistered<MemberDetailPageController>(tag: _tag)) {
      Get.put(
        MemberDetailPageController(
          initialUser: user,
          userId: userId,
        ),
        tag: _tag,
      );
    }
    return Get.find<MemberDetailPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Obx(() {
      final loadingView = Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceElevated,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: const AppBackButton(),
        ),
        body: const UserProfileSkeleton(),
      );

      Widget content;
      final user = controller.user.value;

      if (user == null) {
        content = Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: const AppBackButton(),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.circleExclamation,
                  size: 48.r,
                  color: AppColors.feedbackError,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value ?? AppLocalizations.of(context)!.userNotFound,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: controller.retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        );
      } else {
        content = _buildContent(context, controller, user);
      }

      return AppLoadingSwitcher(
        isLoading: controller.isLoading.value,
        loading: loadingView,
        child: content,
      );
    });
  }

  Widget _buildContent(BuildContext context, MemberDetailPageController controller, models.User user) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: const SliverBackButton(),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.cityPrimaryLight,
                          AppColors.backgroundSecondary,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'user_avatar_${user.id}',
                        child: Container(
                          width: 150.w,
                          height: 150.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surfaceElevated,
                              width: 4,
                            ),
                            boxShadow: AppUiTokens.heroCardShadow,
                          ),
                          child: SafeCircleAvatar(
                            imageUrl: user.avatarUrl,
                            radius: 73,
                            backgroundColor: AppColors.surfaceSubtle,
                            errorWidget: Icon(FontAwesomeIcons.user, size: 40.r, color: AppColors.textTertiary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (user.isVerified)
                    Positioned(
                      top: 180.h,
                      right: 0,
                      left: 0,
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.travelMint,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.circleCheck,
                                    color: Colors.white,
                                    size: 16.r,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    l10n.verified,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: Offset(0, -48.h),
                    child: _buildProfileSummaryCard(context, controller, user),
                  ),
                  SizedBox(height: 8.h),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    _buildSectionCard(
                      title: AppLocalizations.of(context)!.about,
                      icon: FontAwesomeIcons.solidUser,
                      accent: AppColors.travelSky,
                      child: Text(
                        user.bio!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                  _buildSectionCard(
                    title: AppLocalizations.of(context)!.interests,
                    icon: FontAwesomeIcons.heart,
                    accent: AppColors.cityPrimary,
                    child: _buildInterestsSection(context, user),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionCard(
                    title: AppLocalizations.of(context)!.skills,
                    icon: FontAwesomeIcons.star,
                    accent: AppColors.travelSky,
                    child: _buildSkillsSection(context, user),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionCard(
                    title: AppLocalizations.of(context)!.badges,
                    icon: FontAwesomeIcons.trophy,
                    accent: AppColors.travelAmber,
                    child: _buildBadgesSection(context, user),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionCard(
                    title: AppLocalizations.of(context)!.travelHistory,
                    icon: FontAwesomeIcons.earthAmericas,
                    accent: AppColors.travelMint,
                    child: _buildTravelHistorySection(context, user),
                  ),
                  SizedBox(height: 24.h),
                  _buildSectionCard(
                    title: AppLocalizations.of(context)!.stats,
                    icon: FontAwesomeIcons.chartColumn,
                    accent: AppColors.travelAmber,
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.cities,
                            user.stats.citiesVisited.toString(),
                            FontAwesomeIcons.city,
                            AppColors.cityPrimary,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.countries,
                            user.stats.countriesVisited.toString(),
                            FontAwesomeIcons.flag,
                            AppColors.travelSky,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildStatCard(
                            AppLocalizations.of(context)!.meetups,
                            user.stats.reviewsWritten.toString(),
                            FontAwesomeIcons.users,
                            AppColors.travelMint,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummaryCard(
    BuildContext context,
    MemberDetailPageController controller,
    models.User user,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.heroCardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '@${user.username}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
                if (user.currentCity != null)
                  Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: Wrap(
                      spacing: 8.w,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.locationDot,
                          size: 14.r,
                          color: AppColors.cityPrimary,
                        ),
                        Text(
                          '${user.currentCity}, ${user.currentCountry ?? ''}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.cities,
                  user.stats.citiesVisited.toString(),
                  FontAwesomeIcons.city,
                  AppColors.cityPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  l10n.countries,
                  user.stats.countriesVisited.toString(),
                  FontAwesomeIcons.flag,
                  AppColors.travelSky,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  l10n.meetups,
                  user.stats.reviewsWritten.toString(),
                  FontAwesomeIcons.users,
                  AppColors.travelMint,
                ),
              ),
            ],
          ),
          if (!controller.isCurrentUser) ...[
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => InviteToMeetupPage(user: user)),
                    icon: const Icon(FontAwesomeIcons.calendarDays),
                    label: Text(l10n.inviteToMeetup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.travelMint,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(() => TencentIMDirectChatPage(user: user));
                    },
                    icon: const Icon(FontAwesomeIcons.message),
                    label: Text(l10n.sendMessage),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cityPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    border: Border.all(color: AppColors.borderLight),
                    borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
                  ),
                  child: IconButton(
                    onPressed: () {
                      AppToast.success(
                        l10n.favoriteAdded,
                        title: l10n.favorites,
                      );
                    },
                    icon: const Icon(
                      FontAwesomeIcons.heart,
                      color: AppColors.cityPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accent,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusXl),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 16.r, color: accent),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildBadgeCard(models.Badge badge) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(
          color: AppColors.travelAmber.withValues(alpha: 0.24),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            badge.icon,
            style: TextStyle(fontSize: 32.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            badge.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context, models.User user) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 768;
        final crossAxisCount = isMobile ? 3 : 5;

        if (user.badges.isEmpty) {
          return _buildEmptySectionMessage(AppLocalizations.of(context)!.noBadgesYet);
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.w,
            childAspectRatio: 1,
          ),
          itemCount: user.badges.length,
          itemBuilder: (context, index) {
            return _buildBadgeCard(user.badges[index]);
          },
        );
      },
    );
  }

  Widget _buildTravelHistorySection(BuildContext context, models.User user) {
    final latestTravel = user.latestTravelHistory;

    if (latestTravel == null) {
      return _buildEmptySectionMessage(AppLocalizations.of(context)!.noTravelHistoryYet);
    }

    return _buildLatestTravelHistoryCard(latestTravel, context);
  }

  Widget _buildLatestTravelHistoryCard(models.LatestTravelHistory travel, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(
          color: AppColors.travelAmber.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColors.travelAmber.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.travelAmber.withValues(alpha: 0.24),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                _getCountryFlag(travel.country),
                style: TextStyle(fontSize: 32.sp),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.city,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  travel.country,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.calendar,
                      size: 14.r,
                      color: AppColors.textTertiary,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        _formatTravelDate(travel.arrivalTime, travel.departureTime),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (travel.isOngoing) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.travelMint,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.currentLocation,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTravelDate(DateTime arrivalTime, DateTime? departureTime) {
    final arrival = '${arrivalTime.year}/${arrivalTime.month}/${arrivalTime.day}';
    if (departureTime == null) {
      return '$arrival - 至今';
    }
    final departure = '${departureTime.year}/${departureTime.month}/${departureTime.day}';
    return '$arrival - $departure';
  }

  String _getCountryFlag(String country) {
    final flagMap = {
      'Thailand': '🇹🇭',
      'Portugal': '🇵🇹',
      'Indonesia': '��🇩',
      'Mexico': '🇲🇽',
      'Spain': '🇪🇸',
      'Vietnam': '🇻🇳',
      'Japan': '🇯🇵',
      'United States': '🇺🇸',
      'USA': '🇺🇸',
      'United Kingdom': '🇬🇧',
      'UK': '🇬🇧',
      'France': '🇫🇷',
      'Germany': '🇩��',
      'Italy': '🇮🇹',
      'Netherlands': '��🇱',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'New Zealand': '🇳🇿',
      'Singapore': '🇸🇬',
      'Malaysia': '🇲🇾',
      'South Korea': '🇰🇷',
      'China': '🇨🇳',
    };

    return flagMap[country] ?? '🌍';
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.r,
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context, models.User user) {
    if (user.interests.isEmpty) {
      return _buildEmptySectionMessage(AppLocalizations.of(context)!.noInterestsAddedYet);
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: user.interests.map((interest) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.cityPrimaryLight,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.cityPrimary.withValues(alpha: 0.18)),
          ),
          child: Text(
            interest.name,
            style: TextStyle(
              color: AppColors.cityPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSkillsSection(BuildContext context, models.User user) {
    if (user.skills.isEmpty) {
      return _buildEmptySectionMessage(AppLocalizations.of(context)!.noSkillsAddedYet);
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.w,
      children: user.skills.map((skill) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.travelSky.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.travelSky.withValues(alpha: 0.22)),
          ),
          child: Text(
            skill.name,
            style: TextStyle(
              color: const Color(0xFF276A88),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptySectionMessage(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AppUiTokens.radiusMd),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
