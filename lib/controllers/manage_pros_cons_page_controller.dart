import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/city/application/state_controllers/pros_cons_state_controller.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Pros & Cons 管理页面控制器
class ManageProsConsPageController extends GetxController {
  final String cityId;
  final String cityName;

  ManageProsConsPageController({
    required this.cityId,
    required this.cityName,
  });

  /// 是否可以删除（需要管理员权限）
  final RxBool canDelete = false.obs;

  /// 是否正在加载
  final RxBool isLoading = false.obs;

  /// 当前选中的 Tab 索引
  final RxInt currentTabIndex = 0.obs;

  /// 获取 ProsConsStateController
  ProsConsStateController get prosConsController => Get.find<ProsConsStateController>();

  @override
  void onInit() {
    super.onInit();
    // 异步加载数据,不阻塞页面显示
    Future.microtask(() {
      checkPermissions();
      loadData();
    });
  }

  /// 检查权限
  Future<void> checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  /// 加载数据
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await prosConsController.loadCityProsCons(cityId);
    } finally {
      isLoading.value = false;
    }
  }

  /// 更新当前 Tab 索引
  void updateTabIndex(int index) {
    currentTabIndex.value = index;
  }

  /// 删除优点
  Future<void> deletePros(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条优点吗？此操作可以恢复。'),
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

    if (confirmed != true) return;

    try {
      final success = await prosConsController.deleteProsCons(cityId, id, true);

      if (success) {
        AppToast.success('优点已删除');
        await loadData();
      } else {
        AppToast.error('删除失败,请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  /// 删除挑战
  Future<void> deleteCons(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条挑战吗？此操作可以恢复。'),
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

    if (confirmed != true) return;

    try {
      final success = await prosConsController.deleteProsCons(cityId, id, false);

      if (success) {
        AppToast.success('挑战已删除');
        await loadData();
      } else {
        AppToast.error('删除失败,请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
