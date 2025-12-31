import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/home/home_page_controller.dart';
import 'package:df_admin_mobile/pages/home/widgets/home_city_card.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 城市网格组件
class HomeCityGrid extends GetView<HomePageController> {
  final bool isMobile;

  const HomeCityGrid({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isLoading = controller.isLoadingCities;
      final cities = controller.localCities;

      // 加载中状态
      if (isLoading) {
        return _buildLoadingState(l10n);
      }

      // 空状态
      if (cities.isEmpty) {
        return HomeCityEmptyState(
          isMobile: isMobile,
          isSearching: controller.searchController.text.trim().isNotEmpty,
          onClearSearch: controller.clearSearch,
        );
      }

      // 城市网格
      return _buildCityGrid(l10n);
    });
  }

  Widget _buildLoadingState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.loading,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityGrid(AppLocalizations l10n) {
    final displayCities = controller.displayCities;
    final hasMore = controller.hasMoreCities;
    final crossAxisCount = isMobile ? 2 : 4;

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: isMobile ? 0.68 : 0.72,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: displayCities.length,
          itemBuilder: (context, index) {
            return HomeCityCard(
              city: displayCities[index],
              onReturnFromDetail: controller.clearSearchOnReturn,
            );
          },
        ),
        if (hasMore) ...[
          const SizedBox(height: 24),
          _buildViewAllButton(l10n),
        ],
      ],
    );
  }

  Widget _buildViewAllButton(AppLocalizations l10n) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => controller.checkLoginAndNavigate(
          () => Get.toNamed(AppRoutes.cityList),
        ),
        icon: const Icon(
          FontAwesomeIcons.city,
          size: 20,
          color: Color(0xFFFF4458),
        ),
        label: Text(
          l10n.viewAllCities,
          style: const TextStyle(
            color: Color(0xFFFF4458),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          side: const BorderSide(color: Color(0xFFFF4458), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

/// 城市空状态组件
class HomeCityEmptyState extends StatelessWidget {
  final bool isMobile;
  final bool isSearching;
  final VoidCallback onClearSearch;

  const HomeCityEmptyState({
    super.key,
    required this.isMobile,
    required this.isSearching,
    required this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 48,
        vertical: isMobile ? 40 : 60,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          Container(
            width: isMobile ? 100 : 120,
            height: isMobile ? 100 : 120,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4458).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching ? FontAwesomeIcons.magnifyingGlass : FontAwesomeIcons.city,
              size: isMobile ? 50 : 60,
              color: const Color(0xFFFF4458),
            ),
          ),
          SizedBox(height: isMobile ? 24 : 32),
          // 标题
          Text(
            isSearching ? 'No cities found' : l10n.noCitiesYet,
            style: TextStyle(
              fontSize: isMobile ? 24 : 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          // 描述
          Text(
            isSearching
                ? 'Try searching with a different keyword\n(支持中英文搜索)'
                : 'Start exploring by adding your first city',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: isMobile ? 32 : 40),
          // 按钮
          if (isSearching)
            ElevatedButton.icon(
              onPressed: onClearSearch,
              icon: const Icon(FontAwesomeIcons.xmark),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 12 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.cityList),
              icon: const Icon(FontAwesomeIcons.circlePlus, size: 20),
              label: Text(
                l10n.browseCities,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 32,
                  vertical: isMobile ? 14 : 16,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
