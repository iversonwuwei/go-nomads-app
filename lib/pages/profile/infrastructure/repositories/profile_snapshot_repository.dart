import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/infrastructure/models/user_dto.dart';
import 'package:go_nomads_app/pages/profile/domain/entities/profile_snapshot.dart';
import 'package:go_nomads_app/pages/profile/domain/repositories/i_profile_snapshot_repository.dart';
import 'package:go_nomads_app/services/http_service.dart';

class ProfileSnapshotRepository implements IProfileSnapshotRepository {
  final HttpService _httpService;

  ProfileSnapshotRepository(this._httpService);

  @override
  Future<Result<ProfileSnapshot>> getProfileSnapshot() async {
    try {
      final response = await _httpService.get(ApiConfig.profileSnapshotCurrentEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        return Result.success(
          ProfileSnapshot(
            user: UserDto.fromJson(data['user'] as Map<String, dynamic>).toDomain(),
            nomadStats: NomadStats.fromJson(data['nomadStats'] as Map<String, dynamic>? ?? const {}),
            favoriteCityIds: (data['favoriteCityIds'] as List<dynamic>? ?? const []).whereType<String>().toList(),
            latestTravelPlan: data['latestTravelPlan'] is Map<String, dynamic>
                ? TravelPlanSummary.fromJson(data['latestTravelPlan'] as Map<String, dynamic>)
                : null,
            nextDestinationCity: data['nextDestinationCity'] is Map<String, dynamic>
                ? City.fromJson(data['nextDestinationCity'] as Map<String, dynamic>)
                : null,
            lastUpdatedAt: data['lastUpdatedAt'] != null
                ? DateTime.parse(data['lastUpdatedAt'] as String)
                : DateTime.now(),
          ),
        );
      }

      return Result.failure(const ServerException('获取 Profile Snapshot 失败'));
    } on DioException catch (error) {
      log('❌ Profile snapshot request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Profile snapshot parse failed: $error');
      return Result.failure(UnknownException('获取 Profile Snapshot 失败: $error'));
    }
  }
}
