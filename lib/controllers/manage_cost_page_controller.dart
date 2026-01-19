import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:go_nomads_app/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:go_nomads_app/pages/add_cost/add_cost_page.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ManageCostPage 控制器
class ManageCostPageController extends GetxController {
  final String cityId;
  final String cityName;

  ManageCostPageController({
    required this.cityId,
    required this.cityName,
  });

  final RxBool canDelete = false.obs;
  final RxBool isLoading = false.obs;

  UserCityContentStateController get contentController => Get.find<UserCityContentStateController>();

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
    loadData();
  }

  Future<void> _checkPermissions() async {
    final isAdmin = await TokenStorageService().isAdmin();
    canDelete.value = isAdmin;
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await contentController.loadCityExpenses(cityId);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(String expenseId) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条费用记录吗？此操作可以恢复。'),
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
      final success = await contentController.deleteExpense(cityId, expenseId);

      if (success) {
        AppToast.success('费用记录已删除');
        await loadData();
      } else {
        AppToast.error('删除失败,请重试');
      }
    } catch (e) {
      AppToast.error('删除失败: $e');
    }
  }

  /// 导航到添加费用页面
  Future<void> navigateToAddCost() async {
    final result = await Get.to(() => AddCostPage(
          cityId: cityId,
          cityName: cityName,
        ));
    if (result != null && result['success'] == true) {
      await loadData();
    }
  }

  /// 获取分类名称
  String getCategoryName(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return '餐饮';
      case ExpenseCategory.transport:
        return '交通';
      case ExpenseCategory.accommodation:
        return '住宿';
      case ExpenseCategory.activity:
        return '活动';
      case ExpenseCategory.shopping:
        return '购物';
      case ExpenseCategory.other:
        return '其他';
    }
  }

  /// 获取分类颜色
  Color getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.transport:
        return Colors.blue;
      case ExpenseCategory.accommodation:
        return Colors.purple;
      case ExpenseCategory.activity:
        return Colors.green;
      case ExpenseCategory.shopping:
        return Colors.pink;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }

  /// 格式化日期
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
