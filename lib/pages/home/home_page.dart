import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/pages/home/widgets/home_city_grid.dart';
import 'package:go_nomads_app/pages/home/widgets/home_hero_section.dart';
import 'package:go_nomads_app/pages/home/widgets/home_meetups_section.dart';
import 'package:go_nomads_app/pages/home/widgets/home_nomad_dashboard.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 首页 - 使用 GetView 实现
/// 路由监听由 HomePageController 内部管理
class HomePage extends GetView<HomePageController> {
  final bool scrollToCities;

  const HomePage({super.key, this.scrollToCities = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    // 如果需要滚动到城市列表
    if (scrollToCities) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scrollToCitiesList();
      });
    }

    // 重置 GlobalKey 避免 permanent 控制器在页面重建时产生重复 key
    controller.citiesListKey = GlobalKey();

    // 首页重新可见时执行一次轻量数据自愈检查。
    // 控制器内部有节流，不会因 build 频繁导致重复请求。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.onHomeVisible();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        color: const Color(0xFFFF4458),
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Hero区域
            SliverToBoxAdapter(
              child: HomeHeroSection(isMobile: isMobile),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isMobile ? 16 : 32,
                  14,
                  isMobile ? 16 : 32,
                  0,
                ),
                child: HomeNomadDashboard(isMobile: isMobile),
              ),
            ),

            // 城市列表锚点
            SliverToBoxAdapter(
              child: Container(key: controller.citiesListKey, height: 0),
            ),

            // 城市网格
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
              sliver: SliverToBoxAdapter(
                child: HomeCityGrid(isMobile: isMobile),
              ),
            ),

            // 底部间距
            SliverToBoxAdapter(child: SizedBox(height: 28.h)),

            // Meetups 区域
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                child: HomeMeetupsSection(isMobile: isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 36.h)),

            // 特性列表
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 6 : 14,
                ),
                child: HomeFeatureHighlights(isMobile: isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),

            // 版权信息
            const SliverToBoxAdapter(
              child: CopyrightWidget(useTopMargin: false),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}
