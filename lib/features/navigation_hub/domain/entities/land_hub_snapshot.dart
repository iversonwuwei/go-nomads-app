import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/features/travel_plan/infrastructure/models/travel_plan_dto.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';

class LandHubSnapshot {
  final MigrationWorkspace? migrationWorkspace;
  final BudgetCenter? budgetCenter;
  final VisaCenter? visaCenter;
  final TravelPlan? focusTravelPlan;
  final DateTime? lastUpdatedAt;

  const LandHubSnapshot({
    required this.migrationWorkspace,
    required this.budgetCenter,
    required this.visaCenter,
    required this.focusTravelPlan,
    required this.lastUpdatedAt,
  });

  factory LandHubSnapshot.fromJson(Map<String, dynamic> json) {
    return LandHubSnapshot(
      migrationWorkspace: json['migrationWorkspace'] is Map<String, dynamic>
          ? MigrationWorkspace.fromJson(json['migrationWorkspace'] as Map<String, dynamic>)
          : null,
      budgetCenter: json['budgetCenter'] is Map<String, dynamic>
          ? BudgetCenter.fromJson(json['budgetCenter'] as Map<String, dynamic>)
          : null,
      visaCenter: json['visaCenter'] is Map<String, dynamic>
          ? VisaCenter.fromJson(json['visaCenter'] as Map<String, dynamic>)
          : null,
      focusTravelPlan: json['focusTravelPlan'] is Map<String, dynamic>
          ? TravelPlanDto.fromJson(json['focusTravelPlan'] as Map<String, dynamic>).toDomain()
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
    );
  }
}
