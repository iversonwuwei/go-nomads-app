import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// AddCostPage 控制器
class AddCostPageController extends GetxController {
  final String cityId;
  final String cityName;

  AddCostPageController({
    required this.cityId,
    required this.cityName,
  });

  // Form
  final formKey = GlobalKey<FormState>();

  // 状态
  final RxBool isSubmitting = false.obs;
  final RxString selectedCurrency = 'USD'.obs;

  // Cost category controllers
  final Map<String, TextEditingController> controllers = {
    'accommodation': TextEditingController(),
    'food': TextEditingController(),
    'transportation': TextEditingController(),
    'entertainment': TextEditingController(),
    'gym': TextEditingController(),
    'coworking': TextEditingController(),
    'utilities': TextEditingController(),
    'healthcare': TextEditingController(),
    'shopping': TextEditingController(),
    'other': TextEditingController(),
  };

  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _validateCityId();
  }

  @override
  void onClose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    notesController.dispose();
    super.onClose();
  }

  /// 验证 cityId 是否为有效的 UUID 格式
  void _validateCityId() {
    if (cityId.isEmpty || !_isValidUuid(cityId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppToast.error('城市ID无效,无法提交费用');
        Get.back();
      });
    }
  }

  /// 检查是否为有效的 UUID 格式
  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  /// 获取总费用
  double get totalCost {
    double total = 0;
    controllers.forEach((key, controller) {
      if (controller.text.isNotEmpty) {
        total += double.tryParse(controller.text) ?? 0;
      }
    });
    return total;
  }

  /// 提交费用
  Future<bool> submitCost({
    required String pleaseEnterCost,
    required String errorTitle,
    required String successTitle,
    required String costShared,
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    // 检查是否至少填写了一项费用
    bool hasAnyCost = controllers.values.any((c) => c.text.isNotEmpty);
    if (!hasAnyCost) {
      AppToast.warning(pleaseEnterCost);
      return false;
    }

    isSubmitting.value = true;

    try {
      final repository = Get.find<IUserCityContentRepository>();

      // 提交每个非空的费用项
      final List<UserCityExpense> addedExpenses = [];

      for (var entry in controllers.entries) {
        final controller = entry.value;
        if (controller.text.isNotEmpty) {
          final amount = double.parse(controller.text);

          // 映射类别名称到 ExpenseCategory 枚举
          final category = _mapToExpenseCategory(entry.key);

          final result = await repository.addCityExpense(
            cityId: cityId,
            category: category,
            amount: amount,
            currency: selectedCurrency.value,
            description: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
            date: DateTime.now(),
          );

          switch (result) {
            case Success(:final data):
              addedExpenses.add(data);
            case Failure(:final exception):
              throw exception;
          }
        }
      }

      isSubmitting.value = false;

      // 发送数据变更事件通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'city_expense',
        entityId: cityId,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.created,
      ));
      log('✅ [城市费用] 已发送数据变更事件');

      AppToast.success(costShared);

      return true;
    } catch (e) {
      isSubmitting.value = false;
      AppToast.error('Failed to submit expenses: $e');
      log('❌ 提交费用失败: $e');
      return false;
    }
  }

  // 映射表单类别到 ExpenseCategory 枚举
  ExpenseCategory _mapToExpenseCategory(String key) {
    switch (key) {
      case 'food':
        return ExpenseCategory.food;
      case 'transportation':
        return ExpenseCategory.transport;
      case 'accommodation':
        return ExpenseCategory.accommodation;
      case 'entertainment':
      case 'gym':
      case 'coworking':
      case 'utilities':
      case 'healthcare':
        return ExpenseCategory.activity;
      case 'shopping':
        return ExpenseCategory.shopping;
      default:
        return ExpenseCategory.other;
    }
  }
}
