import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/entities/land_hub_snapshot.dart';
import 'package:go_nomads_app/features/navigation_hub/domain/repositories/i_land_hub_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class LandHubRepository implements ILandHubRepository {
  final HttpService _httpService;

  LandHubRepository(this._httpService);

  @override
  Future<Result<LandHubSnapshot>> getLandHub() async {
    try {
      final response = await _httpService.get(ApiConfig.landHubCurrentEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(LandHubSnapshot.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取落地中心失败'));
    } on DioException catch (error) {
      log('❌ Land hub request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Land hub parse failed: $error');
      return Result.failure(UnknownException('获取落地中心失败: $error'));
    }
  }
}
