import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';

class ManageCityRatingsPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const ManageCityRatingsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  CityRatingController get _controller => Get.find<CityRatingController>();

  Future<void> _loadData() async {
    log('🔍 [ManageCityRatingsPage] 加载评分项数据: cityId=$cityId');
    await _controller.loadCityRatings(cityId);
  }

  Future<void> _addRating() async {
    final l10n = AppLocalizations.of(Get.context!)!;
    final nameController = TextEditingController();
    final nameEnController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = 'star';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.manageCityRatingsAddItem),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.manageCityRatingsNameZh,
                  hintText: l10n.manageCityRatingsNameZhHint,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: nameEnController,
                decoration: InputDecoration(
                  labelText: l10n.manageCityRatingsNameEn,
                  hintText: l10n.manageCityRatingsNameEnHint,
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  labelText: l10n.manageCityRatingsDescriptionOptional,
                  hintText: l10n.manageCityRatingsDescriptionHint,
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: InputDecoration(labelText: l10n.manageCityRatingsIcon),
                items: [
                  DropdownMenuItem(value: 'star', child: Text(l10n.manageCityRatingsIconStar)),
                  DropdownMenuItem(value: 'restaurant', child: Text(l10n.manageCityRatingsIconRestaurant)),
                  DropdownMenuItem(value: 'wifi', child: Text(l10n.manageCityRatingsIconNetwork)),
                  DropdownMenuItem(value: 'security', child: Text(l10n.manageCityRatingsIconSafety)),
                  DropdownMenuItem(value: 'directions_bus', child: Text(l10n.manageCityRatingsIconTransport)),
                  DropdownMenuItem(value: 'local_hospital', child: Text(l10n.manageCityRatingsIconHealthcare)),
                  DropdownMenuItem(value: 'wb_sunny', child: Text(l10n.manageCityRatingsIconWeather)),
                  DropdownMenuItem(value: 'attach_money', child: Text(l10n.manageCityRatingsIconCost)),
                  DropdownMenuItem(value: 'people', child: Text(l10n.manageCityRatingsIconPeople)),
                  DropdownMenuItem(value: 'language', child: Text(l10n.manageCityRatingsIconLanguage)),
                ],
                onChanged: (value) {
                  if (value != null) selectedIcon = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (confirmed == true && nameController.text.trim().isNotEmpty) {
      await _controller.createCategory(
        name: nameController.text.trim(),
        nameEn: nameEnController.text.trim().isEmpty ? null : nameEnController.text.trim(),
        description: descController.text.trim().isEmpty ? null : descController.text.trim(),
        icon: selectedIcon,
      );
    }
  }

  Future<void> _deleteRating(String categoryId, String categoryName) async {
    final l10n = AppLocalizations.of(Get.context!)!;
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(l10n.manageCityRatingsDeleteItem),
        content: Text(l10n.manageCityRatingsDeleteConfirm(categoryName)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _controller.deleteCategory(categoryId);
    }
  }

  void _finish() {
    Get.back();
  }

  IconData _getIcon(String? iconName) {
    final iconMap = {
      'attach_money': FontAwesomeIcons.dollarSign,
      'wb_sunny': FontAwesomeIcons.sun,
      'directions_bus': FontAwesomeIcons.bus,
      'restaurant': FontAwesomeIcons.utensils,
      'security': FontAwesomeIcons.shieldHalved,
      'wifi': FontAwesomeIcons.wifi,
      'local_activity': FontAwesomeIcons.ticket,
      'local_hospital': FontAwesomeIcons.hospitalUser,
      'people': FontAwesomeIcons.users,
      'language': FontAwesomeIcons.globe,
      'star': FontAwesomeIcons.star,
    };
    return iconMap[iconName] ?? FontAwesomeIcons.star;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 初始化时加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.cityPrimary,
          foregroundColor: Colors.white,
          title: Text(l10n.manageCityRatingsTitle(cityName)),
          leading: AppBackButton(
            color: Colors.white,
            onPressed: _finish,
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.plus),
              tooltip: l10n.manageCityRatingsAddItem,
              onPressed: _addRating,
            ),
          ],
        ),
        body: Obx(() {
          log('📊 [ManageCityRatingsPage] 渲染UI:');
          log('  - isLoading: ${_controller.isLoading.value}');
          log('  - categories: ${_controller.categories.length} 项');
          log('  - statistics: ${_controller.statistics.length} 项');

          final content = RefreshIndicator(
            onRefresh: _loadData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                if (_controller.categories.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.all(16.w),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = _controller.categories[index];
                          final stat = _controller.statistics.firstWhereOrNull(
                            (s) => s.categoryId == category.id,
                          );

                          return Padding(
                            padding: EdgeInsets.only(bottom: index == _controller.categories.length - 1 ? 0 : 12.h),
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                                  child: Icon(
                                    _getIcon(category.icon),
                                    color: const Color(0xFFFF4458),
                                  ),
                                ),
                                title: Text(category.name),
                                subtitle: Text(
                                  l10n.manageCityRatingsSubtitle(
                                    category.nameEn ?? '',
                                    stat?.averageRating.toStringAsFixed(1) ?? '0.0',
                                    stat?.ratingCount ?? 0,
                                  ),
                                ),
                                trailing: category.isDefault
                                    ? Chip(
                                        label: Text(l10n.defaultStatus, style: TextStyle(fontSize: 12.sp)),
                                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                                      )
                                    : IconButton(
                                        icon: const Icon(FontAwesomeIcons.trash),
                                        tooltip: l10n.delete,
                                        onPressed: () => _deleteRating(category.id, category.name),
                                      ),
                              ),
                            ),
                          );
                        },
                        childCount: _controller.categories.length,
                      ),
                    ),
                  ),
              ],
            ),
          );

          return AppLoadingSwitcher(
            isLoading: _controller.isLoading.value,
            loading: const ManageListSkeleton(),
            child: content,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(Get.context!)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.star, size: 72.r, color: Colors.grey.withValues(alpha: 0.4)),
            SizedBox(height: 16.h),
            Text(
              l10n.manageCityRatingsEmptyTitle,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.manageCityRatingsEmptyHint,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: _addRating,
              icon: const Icon(FontAwesomeIcons.plus),
              label: Text(l10n.manageCityRatingsAddItem),
            ),
          ],
        ),
      ),
    );
  }
}
