import 'package:flutter/material.dart';
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
                  vertical: 20,
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

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

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
                return const SizedBox(height: 8);
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
            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // Meetups 区域
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                child: HomeMeetupsSection(isMobile: isMobile),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),

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

            const SliverToBoxAdapter(child: SizedBox(height: 40)),

            // 版权信息
            const SliverToBoxAdapter(
              child: CopyrightWidget(useTopMargin: false),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
