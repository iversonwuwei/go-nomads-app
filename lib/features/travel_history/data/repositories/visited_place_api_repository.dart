import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../config/api_config.dart';
import '../../../../core/core.dart';
import '../../../../services/token_storage_service.dart';
import '../models/visited_place_api_dto.dart';
import 'travel_history_api_repository.dart' show PaginatedResult;

/// 访问地点后端 API Repository
class VisitedPlaceApiRepository extends BaseRepository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  static const String _basePath = '/api/v1/visited-places';

  VisitedPlaceApiRepository({
    required Dio dio,
    required TokenStorageService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  /// 获取旅行的访问地点列表
  Future<Result<List<VisitedPlaceApiDto>>> getByTravelHistoryId(String travelHistoryId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$_basePath/by-travel-history/$travelHistoryId',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => VisitedPlaceApiDto.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      }

      throw ServerException('获取访问地点列表失败', code: 'GET_VISITED_PLACES_FAILED');
    });
  }

  /// 获取旅行的精选地点
  Future<Result<List<VisitedPlaceApiDto>>> getHighlightsByTravelHistoryId(String travelHistoryId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$_basePath/by-travel-history/$travelHistoryId/highlights',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => VisitedPlaceApiDto.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      }

      throw ServerException('获取精选地点列表失败', code: 'GET_HIGHLIGHTS_FAILED');
    });
  }

  /// 获取当前用户的所有访问地点（分页）
  Future<Result<PaginatedResult<VisitedPlaceApiDto>>> getMyVisitedPlaces({
    int page = 1,
    int pageSize = 50,
  }) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
      };

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$_basePath/my',
        queryParameters: queryParams,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'];
        final items = (data['items'] as List<dynamic>)
            .map((e) => VisitedPlaceApiDto.fromJson(e as Map<String, dynamic>))
            .toList();

        return PaginatedResult(
          items: items,
          totalCount: data['totalCount'] as int? ?? items.length,
          page: data['page'] as int? ?? page,
          pageSize: data['pageSize'] as int? ?? pageSize,
        );
      }

      throw ServerException('获取访问地点列表失败', code: 'GET_MY_VISITED_PLACES_FAILED');
    });
  }

  /// 创建单个访问地点
  Future<Result<VisitedPlaceApiDto>> create(CreateVisitedPlaceRequest request) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}$_basePath',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return VisitedPlaceApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('创建访问地点失败', code: 'CREATE_VISITED_PLACE_FAILED');
    });
  }

  /// 批量创建访问地点
  Future<Result<List<VisitedPlaceApiDto>>> createBatch(BatchCreateVisitedPlaceRequest request) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      log('📤 批量创建访问地点 - travelHistoryId: ${request.travelHistoryId}, count: ${request.items.length}');

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}$_basePath/batch',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => VisitedPlaceApiDto.fromJson(e as Map<String, dynamic>))
            .toList();
        log('✅ 成功创建 ${items.length} 个访问地点');
        return items;
      }

      throw ServerException('批量创建访问地点失败', code: 'BATCH_CREATE_VISITED_PLACES_FAILED');
    });
  }

  /// 更新访问地点
  Future<Result<VisitedPlaceApiDto>> update(String id, Map<String, dynamic> updates) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.put(
        '${ApiConfig.currentApiBaseUrl}$_basePath/$id',
        data: updates,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return VisitedPlaceApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('更新访问地点失败', code: 'UPDATE_VISITED_PLACE_FAILED');
    });
  }

  /// 删除访问地点
  Future<Result<bool>> delete(String id) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.delete(
        '${ApiConfig.currentApiBaseUrl}$_basePath/$id',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return true;
      }

      throw ServerException('删除访问地点失败', code: 'DELETE_VISITED_PLACE_FAILED');
    });
  }

  /// 切换精选状态
  Future<Result<VisitedPlaceApiDto>> toggleHighlight(String id, bool isHighlight) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.patch(
        '${ApiConfig.currentApiBaseUrl}$_basePath/$id/highlight',
        data: {'isHighlight': isHighlight},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return VisitedPlaceApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('切换精选状态失败', code: 'TOGGLE_HIGHLIGHT_FAILED');
    });
  }

  /// 获取旅行访问地点统计
  Future<Result<VisitedPlaceStatsDto>> getStats(String travelHistoryId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$_basePath/by-travel-history/$travelHistoryId/stats',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return VisitedPlaceStatsDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('获取统计失败', code: 'GET_STATS_FAILED');
    });
  }
}
