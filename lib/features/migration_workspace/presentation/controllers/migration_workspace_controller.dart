import 'dart:async';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

class MigrationWorkspaceController extends GetxController {
  final IMigrationWorkspaceRepository _repository;

  MigrationWorkspaceController(this._repository);

  final plans = <TravelPlanSummary>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final workspace = Rxn<MigrationWorkspace>();

  TravelPlanSummary? get latestPlan => workspace.value?.latestPlan ?? (plans.isNotEmpty ? plans.first : null);

  int get totalPlans => workspace.value?.totalPlans ?? plans.length;

  int get activePlansCount => workspace.value?.activePlans ?? plans.where((plan) => plan.status.toLowerCase() != 'archived').length;

  int get draftPlansCount => workspace.value?.draftPlans ?? plans.where((plan) => plan.status.toLowerCase() == 'draft').length;

  int get upcomingDeparturesCount => workspace.value?.upcomingDepartures ?? 0;

  DateTime? get lastUpdatedAt => workspace.value?.lastUpdatedAt;

  String get recommendedAction => workspace.value?.recommendedAction ?? '';

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshWorkspace());
  }

  Future<void> refreshWorkspace() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _repository.getMigrationWorkspace(page: 1, pageSize: 20);
      result.fold(
        onSuccess: (data) {
          workspace.value = data;
          plans.assignAll(data.plans);
        },
        onFailure: (exception) {
          workspace.value = null;
          plans.clear();
          errorMessage.value = exception.message;
        },
      );
    } catch (error) {
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> savePlanState({
    required TravelPlanSummary plan,
    required String stage,
    String? focusNote,
    List<MigrationChecklistItem> checklist = const [],
    List<MigrationTimelineItem> timeline = const [],
  }) async {
    final context = Get.context;

    final result = await _repository.savePlanState(
      planId: plan.id,
      stage: stage,
      focusNote: focusNote,
      checklist: checklist,
      timeline: timeline,
    );

    result.fold(
      onSuccess: (data) {
        workspace.value = data;
        plans.assignAll(data.plans);
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
