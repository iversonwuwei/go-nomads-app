import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/city_detail_page.dart';
import 'package:df_admin_mobile/pages/global_map_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'city_list_controller.dart';
import 'widgets/city_list_card.dart';

/// 城市列表页面 - 支持国家、城市和搜索筛选
/// 使用 GetView 模式，符合 GetX 标准
class CityListPage extends GetView<CityListController> {
  const CityListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        top: false,
        child: Obx(() {
          // 加载中状态
          if (controller.isLoading.value) {
            return const CityListSkeleton();
          }

          // 错误状态
          if (controller.errorMessage.value != null) {
            return _buildErrorState(context);
          }

          return Column(
            children: [
              // 筛选栏
              _buildFilterBar(context, isMobile),

              // 城市列表
              Expanded(
                child: controller.cities.isEmpty
                    ? _buildEmptyState(context)
                    : _buildCityList(context, isMobile),
              ),
            ],
          );
        }),
      ),
    );
  }

  // 筛选栏
  Widget _buildFilterBar(BuildContext context, bool isMobile) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          // 搜索框
          _buildSearchField(context),
          const SizedBox(height: 12),

          // 筛选状态
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() {
                if (controller.searchQuery.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.filtered,
                    style: const TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  // 搜索框
  Widget _buildSearchField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.magnifyingGlass, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: l10n.searchCityOrCountry,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: (value) {
                controller.updateSearchQuery(value);
              },
              onSubmitted: (value) {
                controller.performSearch();
              },
            ),
          ),
          const SizedBox(width: 12),
          // 清除按钮
          Obx(() {
            if (controller.searchQuery.value.isEmpty) {
              return const SizedBox.shrink();
            }
            return InkWell(
              onTap: () {
                controller.clearFilters();
              },
              borderRadius: BorderRadius.circular(4),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  FontAwesomeIcons.xmark,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }),
          // 搜索按钮
          InkWell(
            onTap: () {
              controller.performSearch();
            },
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                l10n.search,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 城市列表
  Widget _buildCityList(BuildContext context, bool isMobile) {
    return Obx(() {
      final cityList = controller.cities.toList();

      return RefreshIndicator(
        onRefresh: () async {
          await controller.loadCities(refresh: true);
        },
        color: const Color(0xFFFF4458),
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          // 预加载更多卡片，优化滚动体验
          cacheExtent: 500,
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            100,
          ),
          itemCount: cityList.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // 加载指示器
            if (index == cityList.length) {
              return _buildLoadingIndicator();
            }

            final city = cityList[index];
            // 使用 Obx 包裹以监听 followedCities 的变化
            return Obx(() => CityListCard(
              city: city,
              isMobile: isMobile,
              isFollowed: controller.isCityFollowed(city),
              onTap: () => _navigateToCityDetail(context, city),
              onFollowTap: () => controller.toggleFollow(city),
                ));
          },
        ),
      );
    });
  }

  // 加载指示器
  Widget _buildLoadingIndicator() {
    return Obx(() {
      if (!controller.isLoadingMore.value) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '加载更多城市...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // 导航到城市详情
  void _navigateToCityDetail(BuildContext context, City city) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(
          cityId: city.id,
          cityName: city.name,
          cityImage: city.imageUrl ?? 'https://images.unsplash.com/photo-1514565131-fce0801e5785?w=400',
          overallScore: city.overallScore ?? 0.0,
          reviewCount: city.reviewCount ?? 0,
        ),
      ),
    );
  }

  // 错误状态
  Widget _buildErrorState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.circleExclamation,
                size: 64,
                color: Color(0xFFFF4458),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.loadFailed,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Text(
                  controller.errorMessage.value?.isNotEmpty == true
                      ? controller.errorMessage.value!
                      : l10n.networkError,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.loadCities(refresh: true);
              },
              icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 空状态
  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.magnifyingGlass,
                size: 64,
                color: Color(0xFFFF4458),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noCitiesFound,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.tryAdjustingFilters,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                controller.clearFilters();
              },
              icon: const Icon(FontAwesomeIcons.arrowsRotate, size: 18),
              label: Text(l10n.clearFilters),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
