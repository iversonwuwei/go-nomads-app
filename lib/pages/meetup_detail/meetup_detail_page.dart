import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/edit_button.dart';
import 'package:df_admin_mobile/widgets/share_bottom_sheet.dart';
import 'package:df_admin_mobile/widgets/share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'meetup_detail_attendees_section.dart';
import 'meetup_detail_bottom_bar.dart';
import 'meetup_detail_image_section.dart';
import 'meetup_detail_info_section.dart';
import 'meetup_detail_organizer_section.dart';

/// Meetup 详情页面 - 符合 GetX 标准的组件化架构
///
/// 使用方式:
/// 1. 通过路由跳转 (推荐): Get.toNamed('/meetup-detail', arguments: meetup)
/// 2. 直接导航: MeetupDetailPage.navigateTo(meetup)
class MeetupDetailPage extends StatelessWidget {
  final Meetup meetup;

  const MeetupDetailPage({super.key, required this.meetup});

  /// 导航到详情页的便捷方法
  static Future<Meetup?> navigateTo(Meetup meetup) async {
    final tag = _generateTag(meetup.id);
    
    // 注册 Controller
    Get.put(
      MeetupDetailPageController(initialMeetup: meetup),
      tag: tag,
    );
    
    final result = await Get.to<Meetup>(
      () => MeetupDetailPage(meetup: meetup),
    );

    return result;
  }

  static String _generateTag(String meetupId) => 'meetup_detail_$meetupId';

  String get _controllerTag => _generateTag(meetup.id);

  MeetupDetailPageController get controller {
    if (!Get.isRegistered<MeetupDetailPageController>(tag: _controllerTag)) {
      return Get.put(
        MeetupDetailPageController(initialMeetup: meetup),
        tag: _controllerTag,
      );
    }
    return Get.find<MeetupDetailPageController>(tag: _controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    // 确保 controller 初始化
    final c = controller;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _handleBack(c);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: CustomScrollView(
          slivers: [
            // 顶部 AppBar 与图片
            _MeetupDetailAppBar(
              controllerTag: _controllerTag,
              onBack: () => _handleBack(c),
              onEdit: () => _handleEdit(c),
              onShare: () => _shareMeetup(context, c),
            ),

            // 内容区域
            SliverToBoxAdapter(
              child: _MeetupDetailContent(controllerTag: _controllerTag),
            ),
          ],
        ),
        bottomNavigationBar: MeetupDetailBottomBar(controllerTag: _controllerTag),
      ),
    );
  }

  void _handleBack(MeetupDetailPageController c) {
    final result = c.hasDataChanged.value ? c.meetup.value : null;
    Get.delete<MeetupDetailPageController>(tag: _controllerTag);
    Get.back(result: result);
  }

  Future<void> _handleEdit(MeetupDetailPageController c) async {
    final result = await Get.to(() => CreateMeetupPage(editingMeetup: c.meetup.value));
    if (result == true) {
      await c.loadEventDetails();
      c.hasDataChanged.value = true;
    }
  }

  void _shareMeetup(BuildContext context, MeetupDetailPageController c) {
    final meetupData = c.meetup.value;
    final l10n = AppLocalizations.of(context)!;

    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');
    final timeStr = dateFormat.format(meetupData.schedule.startTime);

    final String title = '${meetupData.title} - ${l10n.meetup}';
    final String description = '📅 ${l10n.dateAndTime}: $timeStr\n'
        '📍 ${l10n.venue}: ${meetupData.venue.name}\n'
        '👥 ${l10n.organizer}: ${meetupData.organizer.name}\n\n'
        '${meetupData.description}';

    final String shareUrl = 'https://nomadcities.app/meetups/${meetupData.id}';

    ShareBottomSheet.show(
      context,
      title: title,
      description: description,
      shareUrl: shareUrl,
    );
  }
}

/// AppBar 组件
class _MeetupDetailAppBar extends StatelessWidget {
  final String controllerTag;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const _MeetupDetailAppBar({
    required this.controllerTag,
    required this.onBack,
    required this.onEdit,
    required this.onShare,
  });

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.h,
      pinned: true,
      backgroundColor: Colors.white,
      leading: SliverBackButton(onPressed: onBack),
      actions: [
        // 编辑按钮 - 只有组织者可见
        Obx(() {
          if (_c.isOrganizer) {
            return SliverEditButton(onPressed: onEdit, size: 18);
          }
          return const SizedBox.shrink();
        }),
        SliverShareButton(onPressed: onShare),
        SizedBox(width: 8.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: MeetupDetailImageSection(controllerTag: controllerTag),
      ),
    );
  }
}

/// 内容区域组件
class _MeetupDetailContent extends StatelessWidget {
  final String controllerTag;

  const _MeetupDetailContent({required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.isLoading.value) {
        return Container(
          padding: EdgeInsets.all(40.w),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF4458)),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 基本信息
          MeetupDetailBasicInfoSection(controllerTag: controllerTag),
          SizedBox(height: 16.h),

          // 时间地点
          MeetupDetailTimeLocationSection(controllerTag: controllerTag),
          SizedBox(height: 16.h),

          // 描述
          MeetupDetailDescriptionSection(controllerTag: controllerTag),
          SizedBox(height: 16.h),

          // 组织者信息
          MeetupDetailOrganizerSection(controllerTag: controllerTag),
          SizedBox(height: 16.h),

          // 参与者列表
          MeetupDetailAttendeesSection(controllerTag: controllerTag),
          SizedBox(height: 100.h),
        ],
      );
    });
  }
}
