import 'dart:async';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_land_hub_repository.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';

class LandHubController extends GetxController {
  final ILandHubRepository _landHubRepository;

  LandHubController(
    this._landHubRepository,
  );

  final migrationWorkspace = Rxn<MigrationWorkspace>();
  final budgetCenter = Rxn<BudgetCenter>();
  final visaCenter = Rxn<VisaCenter>();
  final focusTravelPlan = Rxn<TravelPlan>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  bool get hasData =>
      migrationWorkspace.value != null ||
      (budgetCenter.value?.hasData ?? false) ||
      (visaCenter.value?.hasData ?? false);

  String? get focusPlanId => migrationWorkspace.value?.latestPlan?.id ?? budgetCenter.value?.focusPlan?.id;

  String? get focusCityId => budgetCenter.value?.focusPlan?.cityId ??
      visaCenter.value?.focusProfile?.cityId ??
      migrationWorkspace.value?.latestPlan?.cityId;

  String? get focusCityName => budgetCenter.value?.focusPlan?.cityName ??
      visaCenter.value?.focusProfile?.cityName ??
      migrationWorkspace.value?.latestPlan?.cityName;

  int get activePlansCount => migrationWorkspace.value?.activePlans ?? 0;
  int get trackedCityCount => budgetCenter.value?.trackedCityCount ?? 0;
  int get visaAttentionCount => visaCenter.value?.attentionRequiredCount ?? 0;

  DateTime? get focusDepartureDate => migrationWorkspace.value?.latestPlan?.departureDate;

  bool get hasMigrationPlan => migrationWorkspace.value?.latestPlan != null;

  bool get hasFocusCity => focusCityId?.isNotEmpty == true;

  bool get hasDepartureLocked => focusDepartureDate != null;

  TravelPlan? get detailedFocusPlan => focusTravelPlan.value;

  bool get hasDetailedFocusPlan => detailedFocusPlan != null;

  ArrivalPlan? get focusArrivalPlan => detailedFocusPlan?.transportation.arrival;

  bool get hasArrivalPlan => detailedFocusPlan?.transportation.hasArrivalPlan ?? false;

  LocalTransportPlan? get focusLocalTransportPlan => detailedFocusPlan?.transportation.localTransport;

  bool get hasLocalTransportPlan => detailedFocusPlan?.transportation.hasLocalTransportPlan ?? false;

  TripAccommodation? get focusAccommodationPlan => detailedFocusPlan?.accommodation;

  bool get hasAccommodationPlan => detailedFocusPlan?.accommodation.hasRecommendation ?? false;

  int? get daysUntilDeparture {
    final departureDate = focusDepartureDate;
    if (departureDate == null) {
      return null;
    }

    final today = DateTime.now();
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final normalizedDeparture = DateTime(
      departureDate.year,
      departureDate.month,
      departureDate.day,
    );

    return normalizedDeparture.difference(normalizedToday).inDays;
  }

  double? get focusMonthlyBudgetUsd => budgetCenter.value?.focusPlan?.estimatedMonthlyCostUsd;

  bool get hasBudgetBaseline => focusMonthlyBudgetUsd != null && focusMonthlyBudgetUsd! > 0;

  int? get focusVisaDaysRemaining => visaCenter.value?.focusProfile?.daysRemaining;

  bool get hasVisaProfile => visaCenter.value?.focusProfile != null;

  String get migrationRecommendedAction => migrationWorkspace.value?.recommendedAction ?? '';
  String get budgetRecommendedAction => budgetCenter.value?.recommendedAction ?? '';
  String get visaRecommendedAction => visaCenter.value?.recommendedAction ?? '';

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshHub());
  }

  Future<void> refreshHub() async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _landHubRepository.getLandHub();

      migrationWorkspace.value = result.dataOrNull?.migrationWorkspace;
      budgetCenter.value = result.dataOrNull?.budgetCenter;
      visaCenter.value = result.dataOrNull?.visaCenter;
      focusTravelPlan.value = result.dataOrNull?.focusTravelPlan;
      errorMessage.value = result.exceptionOrNull?.message;
    } finally {
      isLoading.value = false;
    }
  }
}
