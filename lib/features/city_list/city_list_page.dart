import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city_list/city_list_controller.dart';
import 'package:go_nomads_app/features/city_list/widgets/widgets.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/global_map_page.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
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
      backgroundColor: AppColors.background,
      elevation: 0,
      title: Text(
        l10n.exploreCities,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: isMobile ? 20 : 24,
          fontWeight: FontWeight.w800,
        ),
      ),
      leading: const AppBackButton(),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: IconButton(
              icon: FaIcon(
                FontAwesomeIcons.mapLocationDot,
                color: AppColors.textPrimary,
                size: 16.r,
              ),
              onPressed: () {
                Get.to(() => const GlobalMapPage());
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(bool isMobile) {
    return Obx(() {
      final showTabsInitialLoading = controller.isLoadingTabs.value && controller.regionTabs.isEmpty;

      final content = Column(
        children: [
          CityFilterBar(isMobile: isMobile),
          Expanded(
            child: Obx(() {
              final showCitiesInitialLoading = controller.isLoading.value && controller.cities.isEmpty;
              final cityContent = controller.errorMessage.value != null && controller.cities.isEmpty
                  ? const CityListErrorState()
                  : controller.cities.isEmpty
                      ? const CityListEmptyState()
                      : _CityGridContent(isMobile: isMobile);

              return AppLoadingSwitcher(
                isLoading: showCitiesInitialLoading,
                loading: const CityListSkeleton(),
                child: cityContent,
              );
            }),
          ),
        ],
      );

      return AppLoadingSwitcher(
        isLoading: showTabsInitialLoading,
        loading: const CityListSkeleton(),
        child: content,
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
                isMobile ? 18 : 28,
                isMobile ? 16 : 20,
                isMobile ? 18 : 28,
                0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 3,
                  crossAxisSpacing: isMobile ? 12 : 18,
                  mainAxisSpacing: isMobile ? 12 : 18,
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
            SliverPadding(padding: EdgeInsets.only(bottom: 100.h)),
          ],
        ),
      );
    });
  }
}
