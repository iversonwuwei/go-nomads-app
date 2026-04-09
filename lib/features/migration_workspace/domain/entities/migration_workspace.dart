import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';

class MigrationWorkspace {
  final int totalPlans;
  final int activePlans;
  final int draftPlans;
  final int upcomingDepartures;
  final String recommendedAction;
  final DateTime? lastUpdatedAt;
  final TravelPlanSummary? latestPlan;
  final List<TravelPlanSummary> plans;

  const MigrationWorkspace({
    required this.totalPlans,
    required this.activePlans,
    required this.draftPlans,
    required this.upcomingDepartures,
    required this.recommendedAction,
    required this.lastUpdatedAt,
    required this.latestPlan,
    required this.plans,
  });

  factory MigrationWorkspace.fromJson(Map<String, dynamic> json) {
    final plansJson = (json['plans'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];
    final latestPlanJson = json['latestPlan'] as Map<String, dynamic>?;

    return MigrationWorkspace(
      totalPlans: json['totalPlans'] as int? ?? 0,
      activePlans: json['activePlans'] as int? ?? 0,
      draftPlans: json['draftPlans'] as int? ?? 0,
      upcomingDepartures: json['upcomingDepartures'] as int? ?? 0,
      recommendedAction: json['recommendedAction'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
      latestPlan: latestPlanJson != null ? TravelPlanSummary.fromJson(latestPlanJson) : null,
      plans: plansJson.map(TravelPlanSummary.fromJson).toList(),
    );
  }
}