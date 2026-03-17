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
      body: TabBarView(
        controller: controller.tabController,
        children: MeetupListTab.values.map((tab) => MeetupListView(tab: tab)).toList(),
      ),
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
        // 筛选按钮 - 暂时隐藏，保留逻辑代码
        const Visibility(
          visible: false,
          maintainState: true,
          child: _FilterButton(),
        ),
        SizedBox(width: 8.w),
      ],
      bottom: _buildTabBar(context, l10n),
    );
  }

  /// 构建胶囊形态的 TabBar
  PreferredSizeWidget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: Container(
        height: 44.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(22.r),
        ),
        child: TabBar(
          controller: controller.tabController,
          isScrollable: false, // 允许滚动或者铺满
          labelColor: Colors.white,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: Colors.transparent, // 移除底部的默认长横线
          indicator: BoxDecoration(
            color: const Color(0xFFFF4458), // Highlight Theme Color
            borderRadius: BorderRadius.circular(22.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF4458).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(text: l10n.allMeetups),
            Tab(text: l10n.joined),
            Tab(text: l10n.past),
            const Tab(text: '已取消'),
          ],
        ),
      ),
    );
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
