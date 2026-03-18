import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_detail_state_controller.dart';
import 'package:go_nomads_app/features/city/presentation/widgets/city_ratings_card.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail_controller.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

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
      final city = cityDetailController.currentCity.value;
      final content = city == null
          ? Center(child: Text(l10n.noData))
          : RefreshIndicator(
              onRefresh: () => cityDetailController.loadCityDetail(controller.cityId),
              child: ListView(
                padding: EdgeInsets.only(bottom: 80.h),
                children: [
                  CityRatingsCard(cityId: city.id),
                ],
              ),
            );

      return AppLoadingSwitcher(
        isLoading: cityDetailController.isLoading.value,
        loading: const ScoresTabSkeleton(),
        child: content,
      );
    });
  }
}
