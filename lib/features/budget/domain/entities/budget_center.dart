class BudgetCenter {
  final double monthlyBudgetTargetUsd;
  final double forecastMonthlyCostUsd;
  final double deltaUsd;
  final int activePlanCount;
  final int trackedCityCount;
  final String budgetHealth;
  final String recommendedAction;
  final DateTime? lastUpdatedAt;
  final BudgetCenterPlan? focusPlan;
  final List<BudgetCenterPlan> plans;

  const BudgetCenter({
    required this.monthlyBudgetTargetUsd,
    required this.forecastMonthlyCostUsd,
    required this.deltaUsd,
    required this.activePlanCount,
    required this.trackedCityCount,
    required this.budgetHealth,
    required this.recommendedAction,
    required this.lastUpdatedAt,
    required this.focusPlan,
    required this.plans,
  });

  bool get hasData => focusPlan != null || plans.isNotEmpty;

  factory BudgetCenter.fromJson(Map<String, dynamic> json) {
    final plansJson = (json['plans'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return BudgetCenter(
      monthlyBudgetTargetUsd: _toDouble(json['monthlyBudgetTargetUsd']),
      forecastMonthlyCostUsd: _toDouble(json['forecastMonthlyCostUsd']),
      deltaUsd: _toDouble(json['deltaUsd']),
      activePlanCount: json['activePlanCount'] as int? ?? 0,
      trackedCityCount: json['trackedCityCount'] as int? ?? 0,
      budgetHealth: json['budgetHealth'] as String? ?? 'no_data',
      recommendedAction: json['recommendedAction'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
      focusPlan: json['focusPlan'] is Map<String, dynamic>
          ? BudgetCenterPlan.fromJson(json['focusPlan'] as Map<String, dynamic>)
          : null,
      plans: plansJson.map(BudgetCenterPlan.fromJson).toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}

class BudgetCenterPlan {
  final String id;
  final String cityId;
  final String cityName;
  final String budgetLevel;
  final String travelStyle;
  final String status;
  final DateTime? departureDate;
  final double declaredMonthlyBudgetUsd;
  final double estimatedMonthlyCostUsd;
  final String templateName;
  final double alertThresholdPercent;
  final bool overrunAlertEnabled;
  final List<BudgetCategoryAllocation> categories;

  const BudgetCenterPlan({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.budgetLevel,
    required this.travelStyle,
    required this.status,
    required this.departureDate,
    required this.declaredMonthlyBudgetUsd,
    required this.estimatedMonthlyCostUsd,
    this.templateName = '',
    this.alertThresholdPercent = 0,
    this.overrunAlertEnabled = true,
    this.categories = const [],
  });

  factory BudgetCenterPlan.fromJson(Map<String, dynamic> json) {
    final categoriesJson = (json['categories'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return BudgetCenterPlan(
      id: json['id']?.toString() ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      budgetLevel: json['budgetLevel'] as String? ?? '',
      travelStyle: json['travelStyle'] as String? ?? '',
      status: json['status'] as String? ?? '',
      departureDate: json['departureDate'] != null
          ? DateTime.tryParse(json['departureDate'] as String)
          : null,
      declaredMonthlyBudgetUsd: BudgetCenter._toDouble(json['declaredMonthlyBudgetUsd']),
      estimatedMonthlyCostUsd: BudgetCenter._toDouble(json['estimatedMonthlyCostUsd']),
      templateName: json['templateName'] as String? ?? '',
      alertThresholdPercent: BudgetCenter._toDouble(json['alertThresholdPercent']),
      overrunAlertEnabled: json['overrunAlertEnabled'] as bool? ?? true,
      categories: categoriesJson.map(BudgetCategoryAllocation.fromJson).toList(),
    );
  }
}

class BudgetCategoryAllocation {
  final String category;
  final double budgetUsd;

  const BudgetCategoryAllocation({
    required this.category,
    required this.budgetUsd,
  });

  factory BudgetCategoryAllocation.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryAllocation(
      category: json['category'] as String? ?? '',
      budgetUsd: BudgetCenter._toDouble(json['budgetUsd']),
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category,
        'budgetUsd': budgetUsd,
      };
}
