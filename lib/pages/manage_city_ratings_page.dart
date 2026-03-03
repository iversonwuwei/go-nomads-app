import 'dart:developer';

import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageCityRatingsPage extends StatelessWidget {
  final String cityId;
  final String cityName;

  const ManageCityRatingsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  CityRatingController get _controller => Get.find<CityRatingController>();

  void _loadData() {
    log('🔍 [ManageCityRatingsPage] 加载评分项数据: cityId=$cityId');
    _controller.loadCityRatings(cityId);
  }

  Future<void> _addRating() async {
    final nameController = TextEditingController();
    final nameEnController = TextEditingController();
    final descController = TextEditingController();
    String selectedIcon = 'star';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('添加评分项'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '评分项名称（中文）',
                  hintText: '例如：美食',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  labelText: '评分项名称（英文）',
                  hintText: '例如：Food',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '简短描述',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                initialValue: selectedIcon,
                decoration: const InputDecoration(labelText: '图标'),
                items: const [
                  DropdownMenuItem(value: 'star', child: Text('星星')),
                  DropdownMenuItem(value: 'restaurant', child: Text('餐厅')),
                  DropdownMenuItem(value: 'wifi', child: Text('网络')),
                  DropdownMenuItem(value: 'security', child: Text('安全')),
                  DropdownMenuItem(value: 'directions_bus', child: Text('交通')),
                  DropdownMenuItem(value: 'local_hospital', child: Text('医疗')),
                  DropdownMenuItem(value: 'wb_sunny', child: Text('天气')),
                  DropdownMenuItem(value: 'attach_money', child: Text('成本')),
                  DropdownMenuItem(value: 'people', child: Text('人群')),
                  DropdownMenuItem(value: 'language', child: Text('语言')),
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
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('添加'),
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('删除评分项'),
        content: Text('确定要删除"$categoryName"吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: AppColors.cityPrimary),
            child: const Text('删除'),
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
          title: Text('$cityName - 评分数据'),
          leading: AppBackButton(
            color: Colors.white,
            onPressed: _finish,
          ),
          actions: [
            IconButton(
              icon: const Icon(FontAwesomeIcons.plus),
              tooltip: '添加评分项',
              onPressed: _addRating,
            ),
          ],
        ),
        body: Obx(() {
          log('📊 [ManageCityRatingsPage] 渲染UI:');
          log('  - isLoading: ${_controller.isLoading.value}');
          log('  - categories: ${_controller.categories.length} 项');
          log('  - statistics: ${_controller.statistics.length} 项');

          if (_controller.isLoading.value) {
            return const ManageListSkeleton();
          }

          if (_controller.categories.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemBuilder: (context, index) {
              final category = _controller.categories[index];
              final stat = _controller.statistics.firstWhereOrNull(
                (s) => s.categoryId == category.id,
              );

              return Card(
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
                    '${category.nameEn ?? ""} • 评分: ${stat?.averageRating.toStringAsFixed(1) ?? "0.0"} (${stat?.ratingCount ?? 0}人)',
                  ),
                  trailing: category.isDefault
                      ? Chip(
                          label: Text('默认', style: TextStyle(fontSize: 12.sp)),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                        )
                      : IconButton(
                          icon: const Icon(FontAwesomeIcons.trash),
                          tooltip: '删除',
                          onPressed: () => _deleteRating(category.id, category.name),
                        ),
                ),
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemCount: _controller.categories.length,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.star, size: 72.r, color: Colors.grey.withValues(alpha: 0.4)),
            SizedBox(height: 16.h),
            Text(
              '暂无评分项',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            const Text(
              '点击右上角加号，添加第一个评分项',
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
              label: const Text('添加评分项'),
            ),
          ],
        ),
      ),
    );
  }
}
