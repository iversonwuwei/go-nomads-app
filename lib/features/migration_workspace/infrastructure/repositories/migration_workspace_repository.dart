import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/entities/migration_workspace.dart';
import 'package:go_nomads_app/features/migration_workspace/domain/repositories/i_migration_workspace_repository.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan_summary.dart';
import 'package:go_nomads_app/services/http_service.dart';

class MigrationWorkspaceRepository implements IMigrationWorkspaceRepository {
  final HttpService _httpService;

  MigrationWorkspaceRepository(this._httpService);

  @override
  Future<Result<MigrationWorkspace>> getMigrationWorkspace({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        ApiConfig.migrationWorkspaceEndpoint,
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(MigrationWorkspace.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('获取迁移工作台失败'));
    } on DioException catch (error) {
      log('❌ Migration workspace request failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Migration workspace parse failed: $error');
      return Result.failure(UnknownException('获取迁移工作台失败: $error'));
    }
  }

  @override
  Future<Result<MigrationWorkspace>> savePlanState({
    required String planId,
    required String stage,
    String? focusNote,
    List<MigrationChecklistItem> checklist = const [],
    List<MigrationTimelineItem> timeline = const [],
  }) async {
    try {
      final response = await _httpService.post(
        ApiConfig.migrationWorkspacePlanStateEndpoint(planId),
        data: {
          'stage': stage,
          'focusNote': focusNote,
          'checklist': checklist.map((item) => item.toJson()).toList(),
          'timeline': timeline.map((item) => item.toJson()).toList(),
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return Result.success(MigrationWorkspace.fromJson(response.data as Map<String, dynamic>));
      }

      return Result.failure(const ServerException('保存迁移工作台状态失败'));
    } on DioException catch (error) {
      log('❌ Save migration workspace state failed: ${error.message}');
      if (error.response?.statusCode == 401) {
        return Result.failure(const UnauthorizedException('请先登录'));
      }
      return Result.failure(NetworkException('网络连接失败: ${error.message}'));
    } catch (error) {
      log('❌ Save migration workspace state parse failed: $error');
      return Result.failure(UnknownException('保存迁移工作台状态失败: $error'));
    }
  }
}
