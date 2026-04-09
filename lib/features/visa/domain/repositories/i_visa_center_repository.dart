import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';

abstract class IVisaCenterRepository {
  Future<Result<VisaCenter>> getVisaCenter();

  Future<Result<VisaCenter>> saveVisaProfile({
    required String planId,
    required String visaType,
    required int stayDurationDays,
    DateTime? entryDate,
    DateTime? expiryDate,
    required double estimatedCostUsd,
    required String requirementsSummary,
    required String processSummary,
    List<String> requiredDocuments = const [],
    List<DateTime> reminderDates = const [],
  });
}
