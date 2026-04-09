import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/budget/domain/entities/budget_center.dart';
import 'package:go_nomads_app/features/budget/domain/repositories/i_budget_center_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class BudgetCenterRepository implements IBudgetCenterRepository {
  final HttpService _httpService;

  BudgetCenterRepository(this._httpService);

  @override
  Future<Result<BudgetCenter>> getBudgetCenter() async {
    try {
      final response = await _httpService.get(ApiConfig.budgetCurrentEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(BudgetCenter.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取预算中心失败'));
    } on DioException catch (error) {
      log('❌ Budget center request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Budget center parse failed: $error');
      return Result.failure(UnknownException('获取预算中心失败: $error'));
    }
  }

  @override
  Future<Result<BudgetCenter>> saveBudgetPlan({
    required String planId,
    required String templateName,
    required double monthlyBudgetTargetUsd,
    required double forecastMonthlyCostUsd,
    required double alertThresholdPercent,
    required bool overrunAlertEnabled,
    List<BudgetCategoryAllocation> categories = const [],
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.budgetPlanEndpoint(planId),
        data: {
          'templateName': templateName,
          'monthlyBudgetTargetUsd': monthlyBudgetTargetUsd,
          'forecastMonthlyCostUsd': forecastMonthlyCostUsd,
          'alertThresholdPercent': alertThresholdPercent,
          'overrunAlertEnabled': overrunAlertEnabled,
          'categories': categories.map((item) => item.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(BudgetCenter.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('保存预算基线失败'));
    } on DioException catch (error) {
      log('❌ Save budget plan failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Save budget plan parse failed: $error');
      return Result.failure(UnknownException('保存预算基线失败: $error'));
    }
  }
}
