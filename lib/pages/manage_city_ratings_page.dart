import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/city/presentation/controllers/city_rating_controller.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class ManageCityRatingsPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const ManageCityRatingsPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<ManageCityRatingsPage> createState() => _ManageCityRatingsPageState();
}

class _ManageCityRatingsPageState extends State<ManageCityRatingsPage> {
  late final CityRatingController _controller;

  @override
  void initState() {
    super.initState();
    // 确保 Controller 已初始化
    _controller = Get.find<CityRatingController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    print('🔍 [ManageCityRatingsPage] 加载评分项数据: cityId=${widget.cityId}');
    await _controller.loadCityRatings(widget.cityId);
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
              const SizedBox(height: 12),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  labelText: '评分项名称（英文）',
                  hintText: '例如：Food',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  hintText: '简短描述',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedIcon,
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
    return PopScope(
      canPop: true,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.cityPrimary,
          foregroundColor: Colors.white,
          title: Text('${widget.cityName} - 评分数据'),
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
          print('📊 [ManageCityRatingsPage] 渲染UI:');
          print('  - isLoading: ${_controller.isLoading.value}');
          print('  - categories: ${_controller.categories.length} 项');
          print('  - statistics: ${_controller.statistics.length} 项');

          if (_controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.categories.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final category = _controller.categories[index];
              final stat = _controller.statistics.firstWhereOrNull(
                (s) => s.categoryId == category.id,
              );

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
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
                      ? const Chip(
                          label: Text('默认', style: TextStyle(fontSize: 12)),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        )
                      : IconButton(
                          icon: const Icon(FontAwesomeIcons.trash),
                          tooltip: '删除',
                          onPressed: () => _deleteRating(category.id, category.name),
                        ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: _controller.categories.length,
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.star,
                size: 72, color: Colors.grey.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text(
              '暂无评分项',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '点击右上角加号，添加第一个评分项',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
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
