import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';

abstract class IBudgetCenterRepository {
  Future<Result<BudgetCenter>> getBudgetCenter();

  Future<Result<BudgetCenter>> saveBudgetPlan({
    required String planId,
    required String templateName,
    required double monthlyBudgetTargetUsd,
    required double forecastMonthlyCostUsd,
    required double alertThresholdPercent,
    required bool overrunAlertEnabled,
    List<BudgetCategoryAllocation> categories = const [],
  });
}
