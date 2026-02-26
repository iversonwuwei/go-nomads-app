import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_page.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:go_nomads_app/pages/meetup_list/widgets/meetup_filter_drawer.dart';
import 'package:go_nomads_app/pages/meetup_list/widgets/meetup_list_view.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
    );
  }

  /// 构建 AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
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
        // 创建按钮
        _CreateButton(),
        SizedBox(width: 8.w),
      ],
      bottom: _buildTabBar(context, l10n),
    );
  }

  /// 构建 TabBar
  PreferredSizeWidget _buildTabBar(BuildContext context, AppLocalizations l10n) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 0, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0x11000000), width: 1),
          ),
        ),
        child: TabBar(
          controller: controller.tabController,
          isScrollable: false,
          labelColor: const Color(0xFFFF4458),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13.sp,
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: Color(0xFFFF4458), width: 2.5),
            insets: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          labelPadding: EdgeInsets.symmetric(horizontal: 4.w),
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
                size: 24.sp,
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

/// 创建按钮组件
class _CreateButton extends GetView<MeetupListController> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        FontAwesomeIcons.circlePlus,
        color: const Color(0xFFFF4458),
        size: 24.sp,
      ),
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
    );
  }
}
