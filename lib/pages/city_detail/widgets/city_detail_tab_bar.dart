import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 城市详情页 Tab 导航
class CityDetailTabBar extends StatelessWidget {
  final CityDetailController controller;

  const CityDetailTabBar({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TabBar(
      controller: controller.tabController,
      isScrollable: true,
      labelColor: AppColors.cityPrimary,
      unselectedLabelColor: Colors.grey[600],
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15.sp,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 15.sp,
      ),
      indicatorSize: TabBarIndicatorSize.label,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border(
          bottom: BorderSide(
            color: AppColors.cityPrimary,
            width: 3,
          ),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      tabs: [
        Tab(text: l10n.scores),
        Tab(text: l10n.guide),
        Tab(text: l10n.prosAndCons),
        Tab(text: l10n.reviews),
        Tab(text: l10n.cost),
        Tab(text: l10n.photos),
        Tab(text: l10n.weather),
        Tab(text: l10n.hotels),
        Tab(text: l10n.neighborhoods),
        Tab(text: l10n.coworking),
      ],
    );
  }
}

/// Tab 导航 SliverPersistentHeader 委托
class CityDetailTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBarWidget;
  final double height;

  CityDetailTabBarDelegate(this.tabBarWidget, {this.height = 52.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBarWidget,
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
