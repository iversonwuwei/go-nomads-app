import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city_list/city_list_controller.dart';
import 'package:df_admin_mobile/features/city_list/widgets/widgets.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/global_map_page.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
      // 加载中状态
      if (controller.isLoading.value) {
        return const CityListSkeleton();
      }

      // 错误状态
      if (controller.errorMessage.value != null) {
        return const CityListErrorState();
      }

      return Column(
        children: [
          // 筛选栏
          CityFilterBar(isMobile: isMobile),
          // 城市列表
          Expanded(
            child: controller.cities.isEmpty ? const CityListEmptyState() : _CityListContent(isMobile: isMobile),
          ),
        ],
      );
    });
  }
}

/// 城市列表内容组件
class _CityListContent extends GetView<CityListController> {
  final bool isMobile;

  const _CityListContent({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cityList = controller.cities.toList();

      return RefreshIndicator(
        onRefresh: () => controller.loadCities(refresh: true),
        color: const Color(0xFFFF4458),
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            isMobile ? 16 : 20,
            100, // 底部留白给导航栏
          ),
          itemCount: cityList.length + (controller.hasMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // 加载指示器
            if (index == cityList.length) {
              return const CityListLoadingIndicator();
            }

            final city = cityList[index];
            return CityCard(city: city, isMobile: isMobile);
          },
        ),
      );
    });
  }
}
