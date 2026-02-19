import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/features/city_list/widgets/widgets.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/global_map_page.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

/// 城市列表页面 - 使用 GetView 符合 GetX 标准
class CityListPage extends GetView<CityListController> {
  const CityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(l10n, isMobile),
      body: SafeArea(
        top: false,
        child: _buildBody(isMobile),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isMobile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        l10n.exploreCities,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 20 : 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: const AppBackButton(),
      actions: [
        // 全球地图按钮
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.mapLocationDot,
            color: AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            Get.to(() => const GlobalMapPage());
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.borderLight,
        ),
      ),
    );
  }

  Widget _buildBody(bool isMobile) {
    return Obx(() {
      // 阶段1：tabs 还没加载完 → 全页骨架屏
      if (controller.isLoadingTabs.value && controller.regionTabs.isEmpty) {
        return const CityListSkeleton();
      }

      // 阶段2+：tabs 已加载，显示 FilterBar + 列表区域
      return Column(
        children: [
          // 搜索栏 + 区域 Tab 栏
          CityFilterBar(isMobile: isMobile),
          // 城市网格列表区域
          Expanded(
            child: Obx(() {
              // 城市数据加载中 → 列表区域骨架屏
              if (controller.isLoading.value && controller.cities.isEmpty) {
                return const CityListSkeleton();
              }

              // 错误状态
              if (controller.errorMessage.value != null && controller.cities.isEmpty) {
                return const CityListErrorState();
              }

              // 空状态
              if (controller.cities.isEmpty) {
                return const CityListEmptyState();
              }

              return _CityGridContent(isMobile: isMobile);
            }),
          ),
        ],
      );
    });
  }
}

/// 城市网格列表内容组件 - 2列网格布局
class _CityGridContent extends GetView<CityListController> {
  final bool isMobile;

  const _CityGridContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cityList = controller.cities.toList();

      return RefreshIndicator(
        onRefresh: () => controller.loadCities(refresh: true),
        color: const Color(0xFFFF4458),
        child: CustomScrollView(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // 城市网格
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 12 : 20,
                isMobile ? 12 : 20,
                isMobile ? 12 : 20,
                0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 3,
                  crossAxisSpacing: isMobile ? 10 : 16,
                  mainAxisSpacing: isMobile ? 10 : 16,
                  childAspectRatio: 0.68,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final city = cityList[index];
                    return CityCard(cityId: city.id, isMobile: isMobile);
                  },
                  childCount: cityList.length,
                ),
              ),
            ),
            // 加载更多指示器 - 全宽居中显示
            if (controller.hasMore.value)
              const SliverToBoxAdapter(
                child: CityListLoadingIndicator(),
              ),
            // 底部留白
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      );
    });
  }
}
