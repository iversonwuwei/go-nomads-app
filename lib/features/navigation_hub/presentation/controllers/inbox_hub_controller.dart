import 'dart:async';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/budget/domain/repositories/i_budget_center_repository.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/inbox_summary.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_inbox_summary_repository.dart';
import 'package:go_nomads_app/features/notification/domain/entities/app_notification.dart';
import 'package:go_nomads_app/features/user/presentation/controllers/user_state_controller.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';
import 'package:go_nomads_app/features/visa/domain/repositories/i_visa_center_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

class InboxHubController extends GetxController {
  final IInboxSummaryRepository _repository;
  final IMigrationWorkspaceRepository _migrationWorkspaceRepository;
  final IBudgetCenterRepository _budgetCenterRepository;
  final IVisaCenterRepository _visaCenterRepository;

  InboxHubController(
    this._repository,
    this._migrationWorkspaceRepository,
    this._budgetCenterRepository,
    this._visaCenterRepository,
  );

  final summary = Rxn<InboxSummary>();
  final migrationWorkspace = Rxn<MigrationWorkspace>();
  final budgetCenter = Rxn<BudgetCenter>();
  final visaCenter = Rxn<VisaCenter>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  int get unreadNotifications => summary.value?.unreadNotifications ?? 0;
  int get totalNotifications => summary.value?.totalNotifications ?? 0;
  int get actionRequiredCount => summary.value?.actionRequiredCount ?? 0;
  DateTime? get latestNotificationAt => summary.value?.latestNotificationAt;
  List<AppNotification> get recentNotifications => summary.value?.recentNotifications ?? const [];
  int get unifiedActionCount => actionRequiredCount + systemActionItems.length;

  List<InboxActionItem> get systemActionItems {
    final items = <InboxActionItem>[];

    final workspace = migrationWorkspace.value;
    if (workspace != null && (workspace.activePlans > 0 || workspace.upcomingDepartures > 0)) {
      final count = workspace.upcomingDepartures > 0 ? workspace.upcomingDepartures : workspace.activePlans;
      items.add(
        InboxActionItem(
          title: _l10n.inboxSystemMigrationTitle,
          subtitle: workspace.recommendedAction.isNotEmpty
              ? workspace.recommendedAction
              : _l10n.inboxSystemMigrationFallback(count.toString()),
          routeName: AppRoutes.migrationWorkspace,
          badgeCount: count,
        ),
      );
    }

    final budget = budgetCenter.value;
    if (budget != null && budget.hasData) {
      items.add(
        InboxActionItem(
          title: _l10n.inboxSystemBudgetTitle,
          subtitle: budget.recommendedAction.isNotEmpty
              ? budget.recommendedAction
              : _l10n.inboxSystemBudgetFallback(_formatCurrencyDelta(budget.deltaUsd.round())),
          routeName: AppRoutes.budgetCenter,
          badgeCount: budget.activePlanCount,
        ),
      );
    }

    final visa = visaCenter.value;
    if (visa != null && (visa.attentionRequiredCount > 0 || visa.reminderReadyCount > 0 || visa.hasData)) {
      final count = visa.attentionRequiredCount > 0 ? visa.attentionRequiredCount : visa.reminderReadyCount;
      items.add(
        InboxActionItem(
          title: _l10n.inboxSystemVisaTitle,
          subtitle: visa.recommendedAction.isNotEmpty
              ? visa.recommendedAction
              : _l10n.inboxSystemVisaFallback(count.toString()),
          routeName: AppRoutes.visaCenter,
          badgeCount: count,
        ),
      );
    }

    final membership = Get.isRegistered<UserStateController>()
        ? Get.find<UserStateController>().currentUser.value?.membership
        : null;

    if (membership != null) {
      if (membership.isExpired) {
        items.add(
          InboxActionItem(
            title: _l10n.inboxSystemMembershipTitle,
            subtitle: _l10n.inboxSystemMembershipExpired,
            routeName: AppRoutes.membershipPlan,
            badgeCount: 1,
          ),
        );
      } else if (membership.isExpiringSoon) {
        items.add(
          InboxActionItem(
            title: _l10n.inboxSystemMembershipTitle,
            subtitle: _l10n.inboxSystemMembershipExpiring(membership.remainingDays.toString()),
            routeName: AppRoutes.membershipPlan,
            badgeCount: membership.remainingDays,
          ),
        );
      } else if (membership.aiUsageRemaining >= 0 && membership.aiUsageRemaining <= 3) {
        items.add(
          InboxActionItem(
            title: _l10n.inboxSystemMembershipAiQuotaTitle,
            subtitle: _l10n.inboxSystemMembershipAiQuota(membership.aiUsageRemaining.toString()),
            routeName: AppRoutes.membershipPlan,
            badgeCount: membership.aiUsageRemaining,
          ),
        );
      }
    }

    return items;
  }

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshSummary());
  }

  Future<void> refreshSummary() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final results = await Future.wait([
        _repository.getInboxSummary(),
        _migrationWorkspaceRepository.getMigrationWorkspace(pageSize: 8),
        _budgetCenterRepository.getBudgetCenter(),
        _visaCenterRepository.getVisaCenter(),
      ]);

      final inboxResult = results[0] as Result<InboxSummary>;
      final migrationResult = results[1] as Result<MigrationWorkspace>;
      final budgetResult = results[2] as Result<BudgetCenter>;
      final visaResult = results[3] as Result<VisaCenter>;

      inboxResult.fold(
        onSuccess: (data) => summary.value = data,
        onFailure: (exception) {
          summary.value = null;
          errorMessage.value = exception.message;
        },
      );

      migrationWorkspace.value = migrationResult.dataOrNull;
      budgetCenter.value = budgetResult.dataOrNull;
      visaCenter.value = visaResult.dataOrNull;
    } finally {
      isLoading.value = false;
    }
  }

  String _formatCurrencyDelta(int delta) {
    final prefix = delta > 0 ? '+' : delta < 0 ? '-' : '';
    return '$prefix\$${delta.abs()}';
  }
}

class InboxActionItem {
  final String title;
  final String subtitle;
  final String routeName;
  final int badgeCount;

  const InboxActionItem({
    required this.title,
    required this.subtitle,
    required this.routeName,
    required this.badgeCount,
  });
}