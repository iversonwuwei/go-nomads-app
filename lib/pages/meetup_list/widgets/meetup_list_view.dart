import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:go_nomads_app/pages/meetup_list/widgets/meetup_list_card.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// Meetup 列表视图组件
class MeetupListView extends GetView<MeetupListController> {
  final MeetupListTab tab;

  const MeetupListView({super.key, required this.tab});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isLoading = controller.tabLoading[tab]!.value;
      final meetups = controller.tabMeetups[tab]!;
      final isRefreshing = controller.isRefreshing.value;
      final showInitialLoading = isLoading && meetups.isEmpty && !isRefreshing;

      Widget content;
      if (meetups.isEmpty) {
        content = RefreshIndicator(
          color: const Color(0xFFFF4458),
          onRefresh: controller.refreshCurrentTab,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: _buildEmptyState(context, l10n),
                ),
              );
            },
          ),
        );
      } else {
        content = RefreshIndicator(
          color: const Color(0xFFFF4458),
          onRefresh: controller.refreshCurrentTab,
          child: Column(
            children: [
              _buildToolbar(context, l10n, meetups),
              Expanded(
                child: ListView.builder(
                  controller: controller.tabScrollControllers[tab],
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 100),
                  itemCount: meetups.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == meetups.length) {
                      return _buildLoadingIndicator();
                    }
                    return MeetupListCard(
                      meetup: meetups[index],
                      currentTabIndex: tab.index,
                      onTap: () => _onMeetupTap(meetups[index]),
                      onToggleJoin: () => _onToggleJoin(meetups[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }

      return AppLoadingSwitcher(
        isLoading: showInitialLoading,
        loading: const MeetupListSkeleton(),
        child: content,
      );
    });
  }

  /// 工具栏
  Widget _buildToolbar(BuildContext context, AppLocalizations l10n, List<Meetup> meetups) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getTabCountText(l10n, meetups.length),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              PopupMenuButton<String>(
                icon: Icon(
                  FontAwesomeIcons.arrowDownWideShort,
                  color: AppColors.textSecondary,
                  size: 20.sp,
                ),
                onSelected: (value) {
                  // TODO: Handle sort
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'date', child: Text(l10n.date)),
                  PopupMenuItem(value: 'popular', child: Text(l10n.popular)),
                  PopupMenuItem(value: 'nearby', child: Text(l10n.nearby)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 获取 Tab 计数文本
  String _getTabCountText(AppLocalizations l10n, int count) {
    switch (tab) {
      case MeetupListTab.upcoming:
        return l10n.upcomingEvents('$count');
      case MeetupListTab.joined:
        return l10n.joinedEvents('$count');
      case MeetupListTab.past:
        return l10n.pastEvents('$count');
      case MeetupListTab.cancelled:
        return '已取消 ($count)';
    }
  }

  /// 空状态
  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    String emptyMessage;
    String emptyHint;
    IconData emptyIcon;

    switch (tab) {
      case MeetupListTab.joined:
        emptyMessage = l10n.noJoinedMeetupsYet;
        emptyHint = '参加一些活动来认识新朋友吧！';
        emptyIcon = FontAwesomeIcons.calendarPlus;
        break;
      case MeetupListTab.past:
        emptyMessage = l10n.noPastMeetups;
        emptyHint = '还没有参加过任何活动';
        emptyIcon = FontAwesomeIcons.clockRotateLeft;
        break;
      case MeetupListTab.cancelled:
        emptyMessage = '暂无已取消的活动';
        emptyHint = '这里会显示你取消参与的活动记录';
        emptyIcon = FontAwesomeIcons.calendarXmark;
        break;
      case MeetupListTab.upcoming:
        emptyMessage = l10n.noMeetupsAvailable;
        emptyHint = '目前没有即将举行的活动';
        emptyIcon = FontAwesomeIcons.calendarDay;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 80.sp,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: 24.h),
            Text(
              emptyMessage,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              emptyHint,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 加载更多指示器
  Widget _buildLoadingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: const Center(child: AppLoadingWidget(fullScreen: false)),
    );
  }

  /// 点击 Meetup 卡片
  Future<void> _onMeetupTap(Meetup meetup) async {
    await NavigationUtil.toWithCallback<Meetup>(
      page: () => MeetupDetailPage(meetup: meetup),
      binding: MeetupDetailBinding(),
      onResult: (result) {
        if (result.hasData) {
          controller.updateMeetup(result.data!);
        }
        // 从详情页返回时，标记已加入 Tab 需要刷新
        // （无论是否有数据变更，都刷新以确保一致性）
        if (result.needsRefresh || (result.hasData && result.data!.isJoined != meetup.isJoined)) {
          controller.loadTabData(MeetupListTab.joined, refresh: true);
        }
      },
    );
  }

  /// 切换加入状态
  void _onToggleJoin(Meetup meetup) {
    controller.handleToggleJoin(meetup, meetup.isJoined);
  }
}
