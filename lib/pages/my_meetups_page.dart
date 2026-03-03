import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/my_meetups_page_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 我的 Meetups 页面 - 显示用户创建的活动
class MyMeetupsPage extends StatelessWidget {
  const MyMeetupsPage({super.key});

  static const String _tag = 'MyMeetupsPage';

  MyMeetupsPageController get _controller {
    if (!Get.isRegistered<MyMeetupsPageController>(tag: _tag)) {
      Get.put(MyMeetupsPageController(), tag: _tag);
    }
    return Get.find<MyMeetupsPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final controller = _controller;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a0a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a1a1a),
        elevation: 0,
        title: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myMeetups,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${controller.meetups.length} ${l10n.meetups}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 12 : 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            )),
        leading: const AppBackButton(color: AppColors.backButtonLight),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus, color: Colors.white, size: 20.r),
            onPressed: () async {
              // 使用接口自动处理刷新
              await NavigationUtil.toNamedAndRefresh<Meetup>(
                route: AppRoutes.createMeetup,
                refresher: controller,
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const MyMeetupsSkeleton();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _buildErrorState(isMobile, controller);
        }

        if (controller.meetups.isEmpty) {
          return _buildEmptyState(isMobile, l10n, controller);
        }

        final showFooter = controller.showFooter;

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          color: Colors.orange,
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            itemCount: controller.meetups.length + (showFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.meetups.length) {
                return _buildLoadingFooter();
              }

              final meetup = controller.meetups[index];
              return _buildMeetupCard(meetup, isMobile, l10n, controller);
            },
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(bool isMobile, MyMeetupsPageController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: isMobile ? 60 : 80,
              color: Colors.red.withValues(alpha: 0.6),
            ),
            SizedBox(height: 24.h),
            Text(
              'Failed to load meetups',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Obx(() => Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: isMobile ? 14 : 16,
                  ),
                )),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: controller.refreshAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isMobile, AppLocalizations l10n, MyMeetupsPageController controller) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.calendarPlus,
              size: isMobile ? 80 : 120,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            SizedBox(height: 24.h),
            Text(
              l10n.noMeetups,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 24 : 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              l10n.createFirstMeetup,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () async {
                // 使用接口自动处理刷新
                await NavigationUtil.toNamedAndRefresh<Meetup>(
                  route: AppRoutes.createMeetup,
                  refresher: controller,
                );
              },
              icon: Icon(FontAwesomeIcons.plus, size: 16.r),
              label: Text(
                l10n.createMeetup,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 32 : 48,
                  vertical: isMobile ? 16 : 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetupCard(Meetup meetup, bool isMobile, AppLocalizations l10n, MyMeetupsPageController controller) {
    final dateFormat = DateFormat('MMM d, yyyy • HH:mm');
    final statusColor = controller.getStatusColor(meetup.status);
    final imageUrl = meetup.images.isNotEmpty ? meetup.images.first : null;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a1a),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () async {
          // 使用接口自动处理刷新
          await NavigationUtil.toAndRefresh<Meetup>(
            page: () => MeetupDetailPage(meetup: meetup),
            refresher: controller,
            binding: MeetupDetailBinding(),
          );
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            width: isMobile ? 80 : 120,
                            height: isMobile ? 80 : 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage(isMobile);
                            },
                          )
                        : _buildPlaceholderImage(isMobile),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                meetup.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                controller.getStatusText(meetup.status, l10n),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.calendar,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 12.r,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                dateFormat.format(meetup.schedule.startTime),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: isMobile ? 12 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.locationDot,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 12.r,
                            ),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: Text(
                                meetup.venue.fullInfo,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: isMobile ? 12 : 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              FontAwesomeIcons.users,
                              color: Colors.orange,
                              size: 12.r,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${meetup.capacity.currentAttendees}/${meetup.capacity.maxAttendees} ${l10n.attendees}',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              _buildActionButtons(meetup, l10n, controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage(bool isMobile) {
    return Container(
      width: isMobile ? 80 : 120,
      height: isMobile ? 80 : 120,
      color: Colors.white.withValues(alpha: 0.1),
      child: Icon(
        FontAwesomeIcons.calendarDay,
        color: Colors.white54,
        size: 32.r,
      ),
    );
  }

  Widget _buildActionButtons(Meetup meetup, AppLocalizations l10n, MyMeetupsPageController controller) {
    if (meetup.isOrganizer) {
      return Align(
        alignment: Alignment.centerRight,
        child: _buildPrimaryButton(
          label: l10n.cancel,
          color: Colors.red,
          onPressed: meetup.canCancelEvent ? () => _confirmCancelMeetup(meetup, l10n, controller) : null,
        ),
      );
    }

    if (!meetup.isJoined) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            label: l10n.chat,
            icon: FontAwesomeIcons.message,
            onPressed: () => _openChat(meetup, l10n),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildPrimaryButton(
            label: l10n.leaveMeetup,
            color: Colors.orange,
            onPressed: meetup.canLeave ? () => _confirmLeaveMeetup(meetup, l10n, controller) : null,
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      child: Text(label),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      icon: Icon(icon, size: 16.r),
      label: Text(label),
    );
  }

  Widget _buildLoadingFooter() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.h,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmCancelMeetup(Meetup meetup, AppLocalizations l10n, MyMeetupsPageController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmCancelMeetupTitle),
        content: Text(l10n.confirmCancelMeetupMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await controller.cancelMeetup(meetup.id, l10n);
  }

  Future<void> _confirmLeaveMeetup(Meetup meetup, AppLocalizations l10n, MyMeetupsPageController controller) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.confirmLeaveMeetupTitle),
        content: Text(l10n.confirmLeaveMeetupMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await controller.leaveMeetup(meetup.id, l10n);
  }

  void _openChat(Meetup meetup, AppLocalizations l10n) {
    // 组织者或已加入的成员都可以访问聊天室
    if (!meetup.isJoined && !meetup.isOrganizer) {
      AppToast.warning(l10n.joinToAccessChat, title: l10n.chat);
      return;
    }

    // 跳转到群聊页面
    Get.toNamed(
      AppRoutes.cityChat,
      arguments: {
        'city': meetup.title,
        'country': '${meetup.type} Meetup',
        'meetupId': meetup.id,
        'isMeetupChat': true,
      },
    );
  }
}
