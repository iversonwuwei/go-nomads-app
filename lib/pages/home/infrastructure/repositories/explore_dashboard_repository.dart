import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/pages/home/domain/entities/explore_dashboard_snapshot.dart';
import 'package:go_nomads_app/pages/home/domain/repositories/i_explore_dashboard_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class ExploreDashboardRepository implements IExploreDashboardRepository {
  final HttpService _httpService;

  ExploreDashboardRepository(this._httpService);

  @override
  Future<Result<ExploreDashboardSnapshot>> getExploreDashboard() async {
    try {
      final response = await _httpService.get(ApiConfig.exploreDashboardCurrentEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(ExploreDashboardSnapshot.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取 Explore Dashboard 失败'));
    } on DioException catch (error) {
      log('❌ Explore dashboard request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Explore dashboard parse failed: $error');
      return Result.failure(UnknownException('获取 Explore Dashboard 失败: $error'));
    }
  }
}
