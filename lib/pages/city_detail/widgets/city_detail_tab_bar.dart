import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';

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
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[700],
      labelStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 14.sp,
        letterSpacing: 0.5,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent, // 隐藏默认分割线
      indicatorPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      indicator: BoxDecoration(
        color: AppColors.cityPrimary,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.cityPrimary.withAlpha(80),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      tabAlignment: TabAlignment.start,
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

/// Tab 导航 SliverPersistentHeader 委托 - 加入毛玻璃透明效果
class CityDetailTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget tabBarWidget;
  final double height;

  CityDetailTabBarDelegate(this.tabBarWidget, {this.height = 56.0});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          // 背景透明加高斯模糊，显得特别轻盈现代
          color: Colors.white.withAlpha(200),
          child: tabBarWidget,
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
