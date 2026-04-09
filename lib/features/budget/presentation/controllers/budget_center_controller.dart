import 'dart:async';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/budget/domain/repositories/i_budget_center_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

class BudgetCenterController extends GetxController {
  final IBudgetCenterRepository _repository;

  BudgetCenterController(this._repository);

  final budgetCenter = Rxn<BudgetCenter>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  BudgetCenterPlan? get focusPlan => budgetCenter.value?.focusPlan;

  List<BudgetCenterPlan> get plans => budgetCenter.value?.plans ?? const [];

  bool get hasData => budgetCenter.value?.hasData ?? false;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshBudgetCenter());
  }

  Future<void> refreshBudgetCenter() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _repository.getBudgetCenter();
      result.fold(
        onSuccess: (data) => budgetCenter.value = data,
        onFailure: (exception) {
          budgetCenter.value = null;
          errorMessage.value = exception.message;
        },
      );
    } catch (error) {
      budgetCenter.value = null;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveBudgetPlan({
    required BudgetCenterPlan plan,
    required String templateName,
    required double monthlyBudgetTargetUsd,
    required double forecastMonthlyCostUsd,
    required double alertThresholdPercent,
    required bool overrunAlertEnabled,
    List<BudgetCategoryAllocation> categories = const [],
  }) async {
    final context = Get.context;
    final result = await _repository.saveBudgetPlan(
      planId: plan.id,
      templateName: templateName,
      monthlyBudgetTargetUsd: monthlyBudgetTargetUsd,
      forecastMonthlyCostUsd: forecastMonthlyCostUsd,
      alertThresholdPercent: alertThresholdPercent,
      overrunAlertEnabled: overrunAlertEnabled,
      categories: categories,
    );

    result.fold(
      onSuccess: (data) {
        budgetCenter.value = data;
        if (context != null) {
          AppToast.success(AppLocalizations.of(context)!.saveSuccess);
        }
      },
      onFailure: (exception) {
        if (context != null) {
          AppToast.error(AppLocalizations.of(context)!.operationFailedWithError(exception.message));
        }
      },
    );
  }
}
