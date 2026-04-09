import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/inbox_summary.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';

class ExploreDashboardSnapshot {
  final MigrationWorkspace? migrationWorkspace;
  final BudgetCenter? budgetCenter;
  final VisaCenter? visaCenter;
  final InboxSummary? inboxSummary;
  final DateTime? lastUpdatedAt;

  const ExploreDashboardSnapshot({
    required this.migrationWorkspace,
    required this.budgetCenter,
    required this.visaCenter,
    required this.inboxSummary,
    required this.lastUpdatedAt,
  });

  factory ExploreDashboardSnapshot.fromJson(Map<String, dynamic> json) {
    return ExploreDashboardSnapshot(
      migrationWorkspace: json['migrationWorkspace'] is Map<String, dynamic>
          ? MigrationWorkspace.fromJson(json['migrationWorkspace'] as Map<String, dynamic>)
          : null,
      budgetCenter: json['budgetCenter'] is Map<String, dynamic>
          ? BudgetCenter.fromJson(json['budgetCenter'] as Map<String, dynamic>)
          : null,
      visaCenter: json['visaCenter'] is Map<String, dynamic>
          ? VisaCenter.fromJson(json['visaCenter'] as Map<String, dynamic>)
          : null,
      inboxSummary: json['inboxSummary'] is Map<String, dynamic>
          ? InboxSummary.fromJson(json['inboxSummary'] as Map<String, dynamic>)
          : null,
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
    );
  }
}
