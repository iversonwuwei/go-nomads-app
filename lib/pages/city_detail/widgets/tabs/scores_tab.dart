import 'package:df_admin_mobile/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:df_admin_mobile/features/city/presentation/widgets/city_ratings_card.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/city_detail/city_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Scores Tab - 城市评分
/// 使用 GetView 绑定 CityDetailController
class ScoresTab extends GetView<CityDetailController> {
  @override
  final String? tag;

  const ScoresTab({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cityDetailController = Get.find<CityDetailStateController>();

    return Obx(() {
      // 显示加载状态
      if (cityDetailController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final city = cityDetailController.currentCity.value;
      if (city == null) {
        return Center(child: Text(l10n.noData));
      }

      return RefreshIndicator(
        onRefresh: () => cityDetailController.loadCityDetail(controller.cityId),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: [
            // 用户评分系统
            CityRatingsCard(cityId: city.id),
          ],
        ),
      );
    });
  }
}
