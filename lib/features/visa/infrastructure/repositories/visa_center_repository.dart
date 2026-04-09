import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/visa/domain/entities/visa_center.dart';
import 'package:go_nomads_app/features/visa/domain/repositories/i_visa_center_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class VisaCenterRepository implements IVisaCenterRepository {
  final HttpService _httpService;

  VisaCenterRepository(this._httpService);

  @override
  Future<Result<VisaCenter>> getVisaCenter() async {
    try {
      final response = await _httpService.get(ApiConfig.visaProfilesEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(VisaCenter.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取签证中心失败'));
    } on DioException catch (error) {
      log('❌ Visa center request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Visa center parse failed: $error');
      return Result.failure(UnknownException('获取签证中心失败: $error'));
    }
  }

  @override
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
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.visaProfilePlanEndpoint(planId),
        data: {
          'visaType': visaType,
          'stayDurationDays': stayDurationDays,
          'entryDate': entryDate?.toIso8601String(),
          'expiryDate': expiryDate?.toIso8601String(),
          'estimatedCostUsd': estimatedCostUsd,
          'requirementsSummary': requirementsSummary,
          'processSummary': processSummary,
          'requiredDocuments': requiredDocuments,
          'reminderDates': reminderDates.map((item) => item.toIso8601String()).toList(),
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(VisaCenter.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('保存签证档案失败'));
    } on DioException catch (error) {
      log('❌ Save visa profile failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Save visa profile parse failed: $error');
      return Result.failure(UnknownException('保存签证档案失败: $error'));
    }
  }
}
