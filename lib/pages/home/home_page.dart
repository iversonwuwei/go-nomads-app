import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/pages/home/widgets/home_ai_entry_card.dart';
import 'package:go_nomads_app/pages/home/widgets/home_city_grid.dart';
import 'package:go_nomads_app/pages/home/widgets/home_hero_section.dart';
import 'package:go_nomads_app/pages/home/widgets/home_meetups_section.dart';
import 'package:go_nomads_app/pages/home/widgets/home_search_bar.dart';
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

            // 搜索栏
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: 20.h,
                ),
                child: HomeSearchBar(isMobile: isMobile),
              ),
            ),

            // 工具栏
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                child: const HomeToolbar(),
              ),
            ),

            // AI Chat 入口
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: isMobile ? 12 : 16),
                child: HomeAiEntryCard(isMobile: isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 8.h)),

            // 搜索结果提示
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.localSearchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                  child: HomeSearchResultHint(isMobile: isMobile),
                );
              }),
            ),

            // 搜索结果提示后的间距
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.localSearchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return SizedBox(height: 8.h);
              }),
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
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),

            // Meetups 区域
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                child: HomeMeetupsSection(isMobile: isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 60.h)),

            // 特性列表
            SliverToBoxAdapter(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 16 : 32,
                  vertical: isMobile ? 10 : 20,
                ),
                child: HomeFeatureHighlights(isMobile: isMobile),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 40.h)),

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
