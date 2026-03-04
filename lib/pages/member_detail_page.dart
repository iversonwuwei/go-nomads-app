import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart' as models;
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/member_detail_page_controller.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'tencent_im_direct_chat_page.dart';
import 'invite_to_meetup_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      if (controller.isLoading.value) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: const AppBackButton(),
          ),
          body: const UserProfileSkeleton(),
        );
      }

      if (controller.user.value == null) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
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
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value ?? '用户信息不存在',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: controller.retry,
                  child: Text(AppLocalizations.of(context)!.retry),
                ),
              ],
            ),
          ),
        );
      }

      final user = controller.user.value!;
      return _buildContent(context, controller, user);
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
            backgroundColor: Colors.white,
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
                          const Color(0xFFFF4458).withValues(alpha: 0.1),
                          Colors.white,
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
                              color: Colors.white,
                              width: 4,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20.r,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SafeCircleAvatar(
                            imageUrl: user.avatarUrl,
                            radius: 73,
                            backgroundColor: Colors.grey[200],
                            errorWidget: Icon(FontAwesomeIcons.user, size: 40.r, color: Colors.grey),
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
                                color: const Color(0xFF10B981),
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
                  Center(
                    child: Column(
                      children: [
                        Text(
                          user.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a1a1a),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Color(0xFF9ca3af),
                          ),
                        ),
                        if (user.currentCity != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.locationDot,
                                  size: 16.r,
                                  color: Color(0xFFFF4458),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '${user.currentCity}, ${user.currentCountry ?? ''}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Color(0xFF6b7280),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  if (user.bio != null && user.bio!.isNotEmpty) ...[
                    _buildSectionTitle(AppLocalizations.of(context)!.about),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        user.bio!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.6,
                          color: Color(0xFF4b5563),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                  _buildInterestsSection(context, user),
                  SizedBox(height: 24.h),
                  _buildSkillsSection(context, user),
                  SizedBox(height: 24.h),
                  _buildBadgesSection(context, user),
                  SizedBox(height: 24.h),
                  _buildTravelHistorySection(context, user),
                  SizedBox(height: 24.h),
                  _buildSectionTitle(AppLocalizations.of(context)!.stats),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.cities,
                          user.stats.citiesVisited.toString(),
                          FontAwesomeIcons.city,
                          const Color(0xFFFF4458),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.countries,
                          user.stats.countriesVisited.toString(),
                          FontAwesomeIcons.flag,
                          const Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildStatCard(
                          AppLocalizations.of(context)!.meetups,
                          user.stats.reviewsWritten.toString(),
                          FontAwesomeIcons.users,
                          const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  if (!controller.isCurrentUser)
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Get.to(() => InviteToMeetupPage(user: user)),
                                icon: const Icon(FontAwesomeIcons.calendarDays),
                                label: Text(l10n.inviteToMeetup),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
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
                                  backgroundColor: const Color(0xFFFF4458),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                                borderRadius: BorderRadius.circular(12.r),
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
                                  color: Color(0xFFFF4458),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1a1a1a),
      ),
    );
  }

  Widget _buildBadgeCard(models.Badge badge) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.15),
            const Color(0xFFFFA500).withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFFB020).withValues(alpha: 0.3),
          width: 1.5,
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
              color: Color(0xFF1a1a1a),
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

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFFF3E0),
                Color(0xFFFFE0B2),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFFFB020),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB020).withValues(alpha: 0.2),
                blurRadius: 8.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    FontAwesomeIcons.trophy,
                    color: Color(0xFFFF6F00),
                    size: 24.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Badges',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              user.badges.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Text(
                          AppLocalizations.of(context)!.noBadgesYet,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xFFFF6F00).withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
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
                    ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTravelHistorySection(BuildContext context, models.User user) {
    final latestTravel = user.latestTravelHistory;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.earthAmericas,
                color: Color(0xFF1976D2),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Travel History',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          latestTravel == null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      AppLocalizations.of(context)!.noTravelHistoryYet,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF1976D2).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : _buildLatestTravelHistoryCard(latestTravel, context),
        ],
      ),
    );
  }

  Widget _buildLatestTravelHistoryCard(models.LatestTravelHistory travel, BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF8E1),
            Color(0xFFFFF3CD),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFF9800),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF9800).withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFE082),
                  Color(0xFFFFD54F),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFFFFA726),
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
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  travel.country,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF6b7280),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.calendar,
                      size: 14.r,
                      color: Color(0xFF9ca3af),
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        _formatTravelDate(travel.arrivalTime, travel.departureTime),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Color(0xFF9ca3af),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (travel.isOngoing) ...[
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
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
              color: Color(0xFF6b7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(BuildContext context, models.User user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFCE4EC),
            Color(0xFFF8BBD0),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE91E63),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE91E63).withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.heart,
                color: Color(0xFFC2185B),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Interests',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          user.interests.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No interests added yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFC2185B).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: user.interests.map((interest) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF4458),
                            Color(0xFFE91E63),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            interest.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(BuildContext context, models.User user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFBBDEFB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFF2196F3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.star,
                color: Color(0xFF1976D2),
                size: 24.r,
              ),
              SizedBox(width: 8.w),
              Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          user.skills.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Text(
                      'No skills added yet',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF1976D2).withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              : Wrap(
                  spacing: 8.w,
                  runSpacing: 8.w,
                  children: user.skills.map((skill) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF1976D2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            skill.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}
