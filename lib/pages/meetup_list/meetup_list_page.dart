import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:go_nomads_app/pages/meetup_list/widgets/meetup_filter_drawer.dart';
import 'package:go_nomads_app/pages/meetup_list/widgets/meetup_list_view.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// Meetup 列表页面 - 符合 GetX 标准
class MeetupListPage extends GetView<MeetupListController> {
  const MeetupListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, l10n),
      body: _buildBody(l10n),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// 构建 AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: const AppBackButton(),
      title: Text(
        l10n.meetups,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        const Visibility(
          visible: false,
          maintainState: true,
          child: _FilterButton(),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    return Obx(() {
      final items = _buildNavItems(l10n);

      return AnimatedBuilder(
        animation: controller.tabController,
        builder: (context, _) {
          final currentIndex = controller.tabController.index;
          final currentItem = items[currentIndex];

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
                child: _MeetupCompactToolbar(
                  items: items,
                  currentIndex: currentIndex,
                  currentItem: currentItem,
                  onTabSelected: (index) => controller.tabController.animateTo(index),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(currentIndex),
                    child: MeetupListView(tab: currentItem.tab),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  List<_MeetupNavItem> _buildNavItems(AppLocalizations l10n) {
    return [
      _MeetupNavItem(
        index: MeetupListTab.upcoming.index,
        tab: MeetupListTab.upcoming,
        label: l10n.allMeetups,
        subtitle: 'Track the next sessions worth joining in your current city orbit.',
        icon: FontAwesomeIcons.calendarDays,
        accent: const Color(0xFF1E5C7A),
        count: controller.tabMeetups[MeetupListTab.upcoming]!.length,
      ),
      _MeetupNavItem(
        index: MeetupListTab.joined.index,
        tab: MeetupListTab.joined,
        label: l10n.joined,
        subtitle: 'Monitor your committed plans and refresh RSVP changes quickly.',
        icon: FontAwesomeIcons.userGroup,
        accent: const Color(0xFF2F6A48),
        count: controller.tabMeetups[MeetupListTab.joined]!.length,
      ),
      _MeetupNavItem(
        index: MeetupListTab.past.index,
        tab: MeetupListTab.past,
        label: l10n.past,
        subtitle: 'Review finished sessions, follow-ups, and participation history.',
        icon: FontAwesomeIcons.clockRotateLeft,
        accent: const Color(0xFF7A4A1E),
        count: controller.tabMeetups[MeetupListTab.past]!.length,
      ),
      _MeetupNavItem(
        index: MeetupListTab.cancelled.index,
        tab: MeetupListTab.cancelled,
        label: '已取消',
        subtitle: 'Audit dropped or closed plans without mixing them into live activity.',
        icon: FontAwesomeIcons.calendarXmark,
        accent: const Color(0xFF7B3559),
        count: controller.tabMeetups[MeetupListTab.cancelled]!.length,
      ),
    ];
  }

  /// 构建悬浮创建按钮 FAB
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () async {
        await NavigationUtil.toWithCallback<bool>(
          page: () => const CreateMeetupPage(),
          onResult: (result) {
            if (result.needsRefresh) {
              controller.refreshCurrentTab();
            }
          },
        );
      },
      backgroundColor: const Color(0xFFFF4458),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r), // 方圆角设计
      ),
      child: Icon(
        FontAwesomeIcons.plus,
        color: Colors.white,
        size: 20.sp,
      ),
    );
  }
}

class _MeetupNavItem {
  const _MeetupNavItem({
    required this.index,
    required this.tab,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.count,
  });

  final int index;
  final MeetupListTab tab;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final int count;
}

class _MeetupPill extends StatelessWidget {
  const _MeetupPill({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  final _MeetupNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [item.accent, Color.lerp(item.accent, Colors.black, 0.18) ?? item.accent],
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isActive ? Colors.transparent : const Color(0xFFE9E2D8),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(item.icon, size: 12.r, color: isActive ? Colors.white : AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeetupCompactToolbar extends StatelessWidget {
  const _MeetupCompactToolbar({
    required this.items,
    required this.currentIndex,
    required this.currentItem,
    required this.onTabSelected,
  });

  final List<_MeetupNavItem> items;
  final int currentIndex;
  final _MeetupNavItem currentItem;
  final ValueChanged<int> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE7DED0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: currentItem.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(currentItem.icon, size: 14.r, color: currentItem.accent),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currentItem.label,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      currentItem.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${currentItem.count}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: currentItem.accent,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Padding(
                  padding: EdgeInsets.only(right: index == items.length - 1 ? 0 : 8.w),
                  child: _MeetupPill(
                    item: item,
                    isActive: currentIndex == index,
                    onTap: () => onTabSelected(index),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// 筛选按钮组件
class _FilterButton extends GetView<MeetupListController> {
  const _FilterButton();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Stack(
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.sliders,
                color: controller.hasActiveFilters ? const Color(0xFFFF4458) : AppColors.textSecondary,
                size: 20.sp,
              ),
              onPressed: () => _showFilterDrawer(context),
            ),
            if (controller.hasActiveFilters)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  width: 8.w,
                  height: 8.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4458),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ));
  }

  void _showFilterDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MeetupFilterDrawer(),
    );
  }
}
