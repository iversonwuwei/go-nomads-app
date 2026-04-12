import 'dart:async';

import 'package:get/get.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';
import 'package:go_nomads_app/features/visa/domain/repositories/i_visa_center_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/openclaw_automation_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

class VisaCenterController extends GetxController {
  final IVisaCenterRepository _repository;
  final OpenClawAutomationService _openClawAutomationService;

  VisaCenterController(this._repository, this._openClawAutomationService);

  final visaCenter = Rxn<VisaCenter>();
  final isLoading = false.obs;
  final isSettingReminder = false.obs;
  final errorMessage = RxnString();

  VisaProfile? get focusProfile => visaCenter.value?.focusProfile;

  List<VisaProfile> get profiles => visaCenter.value?.profiles ?? const [];

  bool get hasData => visaCenter.value?.hasData ?? false;

  @override
  void onInit() {
    super.onInit();
    unawaited(refreshVisaCenter());
  }

  Future<void> refreshVisaCenter() async {
    final previousData = visaCenter.value;

    try {
      isLoading.value = true;
      errorMessage.value = null;

      final result = await _repository.getVisaCenter();
      result.fold(
        onSuccess: (data) => visaCenter.value = data,
        onFailure: (exception) {
          visaCenter.value = previousData;
          errorMessage.value = exception.message;
        },
      );
    } catch (error) {
      visaCenter.value = previousData;
      errorMessage.value = error.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setReminderForFocusProfile() async {
    final profile = focusProfile;
    final context = Get.context;
    if (profile == null || context == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    if (profile.expiryDate == null) {
      AppToast.info(l10n.visaCenterNoReminderTarget);
      return;
    }

    try {
      isSettingReminder.value = true;
      final result = await _openClawAutomationService.setVisaReminder(profile.cityName, profile.expiryDate!);

      if (result.success) {
        AppToast.success(l10n.visaCenterReminderSet(profile.cityName));
      } else {
        AppToast.error(result.error ?? l10n.visaCenterReminderFailed);
      }
    } catch (error) {
      AppToast.error(l10n.visaCenterReminderFailedWithError(error.toString()));
    } finally {
      isSettingReminder.value = false;
    }
  }

  Future<bool> saveVisaProfile({
    required VisaProfile profile,
    required String visaType,
    required int stayDurationDays,
    DateTime? entryDate,
    DateTime? expiryDate,
    required double estimatedCostUsd,
    required String requirementsSummary,
    required String processSummary,
    List<String> requiredDocuments = const [],
    List<DateTime> reminderDates = const [],
  }) async {
    final context = Get.context;
    final result = await _repository.saveVisaProfile(
      planId: profile.id,
      visaType: visaType,
      stayDurationDays: stayDurationDays,
      entryDate: entryDate,
      expiryDate: expiryDate,
      estimatedCostUsd: estimatedCostUsd,
      requirementsSummary: requirementsSummary,
      processSummary: processSummary,
      requiredDocuments: requiredDocuments,
      reminderDates: reminderDates,
    );

    result.fold(
      onSuccess: (data) {
        visaCenter.value = data;
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

    return result.isSuccess;
  }
}
