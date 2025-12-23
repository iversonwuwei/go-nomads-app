import 'dart:developer';

import 'package:dio/dio.dart';

import '../../../../config/api_config.dart';
import '../../../../core/core.dart';
import '../../../../services/token_storage_service.dart';
import '../models/travel_history_api_dto.dart';

/// 旅行历史后端 API Repository
class TravelHistoryApiRepository extends BaseRepository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  TravelHistoryApiRepository({
    required Dio dio,
    required TokenStorageService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  /// 获取当前用户的旅行历史（分页）
  Future<Result<PaginatedResult<TravelHistoryApiDto>>> getTravelHistory({
    int page = 1,
    int pageSize = 20,
    bool? isConfirmed,
  }) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'pageSize': pageSize.toString(),
        if (isConfirmed != null) 'isConfirmed': isConfirmed.toString(),
      };

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryEndpoint}',
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
            .map((e) => TravelHistoryApiDto.fromJson(e as Map<String, dynamic>))
            .toList();

        return PaginatedResult(
          items: items,
          totalCount: data['totalCount'] as int? ?? items.length,
          page: data['page'] as int? ?? page,
          pageSize: data['pageSize'] as int? ?? pageSize,
        );
      }

      throw ServerException('获取旅行历史失败', code: 'GET_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 获取已确认的旅行历史
  Future<Result<List<TravelHistoryApiDto>>> getConfirmedTravelHistory() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryConfirmedEndpoint}',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      log('📋 旅行历史响应类型: ${response.data.runtimeType}');

      // 处理响应数据可能是字符串的情况
      final responseData = response.data is String
          ? (throw ServerException('响应数据格式错误: 期望 JSON 对象，收到字符串', code: 'INVALID_RESPONSE_FORMAT'))
          : response.data as Map<String, dynamic>;

      if (responseData['success'] == true && responseData['data'] != null) {
        final data = responseData['data'];
        log('📋 旅行历史数据类型: ${data.runtimeType}');

        if (data is! List) {
          throw ServerException('响应数据格式错误: data 应为列表，实际类型: ${data.runtimeType}', code: 'INVALID_DATA_FORMAT');
        }

        final items = (data).map((e) {
          if (e is! Map<String, dynamic>) {
            log('⚠️ 旅行历史项类型错误: ${e.runtimeType}, 值: $e');
            throw ServerException('响应数据格式错误: 列表项应为对象', code: 'INVALID_ITEM_FORMAT');
          }
          return TravelHistoryApiDto.fromJson(e);
        }).toList();
        return items;
      }

      throw ServerException('获取已确认旅行历史失败', code: 'GET_CONFIRMED_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 获取未确认的旅行历史
  Future<Result<List<TravelHistoryApiDto>>> getUnconfirmedTravelHistory() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryUnconfirmedEndpoint}',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => TravelHistoryApiDto.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      }

      throw ServerException('获取未确认旅行历史失败', code: 'GET_UNCONFIRMED_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 获取旅行历史详情
  Future<Result<TravelHistoryApiDto>> getTravelHistoryById(String id) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();
      final endpoint = ApiConfig.travelHistoryDetailEndpoint.replaceAll('{id}', id);

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return TravelHistoryApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw NotFoundException('旅行历史记录不存在', code: 'TRAVEL_HISTORY_NOT_FOUND');
    });
  }

  /// 创建旅行历史记录
  Future<Result<TravelHistoryApiDto>> createTravelHistory(CreateTravelHistoryRequest request) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryEndpoint}',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return TravelHistoryApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException(response.data['message'] ?? '创建旅行历史记录失败', code: 'CREATE_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 批量创建旅行历史记录
  Future<Result<List<TravelHistoryApiDto>>> createBatchTravelHistory(BatchCreateTravelHistoryRequest request) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      log('📝 批量创建旅行历史: ${request.items.length} 条');

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryBatchEndpoint}',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => TravelHistoryApiDto.fromJson(e as Map<String, dynamic>))
            .toList();
        log('✅ 批量创建成功: ${items.length} 条');
        return items;
      }

      throw ServerException(response.data['message'] ?? '批量创建旅行历史记录失败', code: 'BATCH_CREATE_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 更新旅行历史记录
  Future<Result<TravelHistoryApiDto>> updateTravelHistory(String id, UpdateTravelHistoryRequest request) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();
      final endpoint = ApiConfig.travelHistoryDetailEndpoint.replaceAll('{id}', id);

      final response = await _dio.put(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        data: request.toJson(),
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return TravelHistoryApiDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException(response.data['message'] ?? '更新旅行历史记录失败', code: 'UPDATE_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 删除旅行历史记录
  Future<Result<bool>> deleteTravelHistory(String id) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();
      final endpoint = ApiConfig.travelHistoryDetailEndpoint.replaceAll('{id}', id);

      final response = await _dio.delete(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['success'] == true;
    });
  }

  /// 确认旅行历史记录
  Future<Result<bool>> confirmTravelHistory(String id) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();
      final endpoint = ApiConfig.travelHistoryConfirmEndpoint.replaceAll('{id}', id);

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      return response.data['success'] == true;
    });
  }

  /// 批量确认旅行历史记录
  Future<Result<int>> confirmBatchTravelHistory(List<String> ids) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryConfirmBatchEndpoint}',
        data: ids,
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'] as int? ?? 0;
      }

      throw ServerException('批量确认旅行历史记录失败', code: 'BATCH_CONFIRM_TRAVEL_HISTORY_FAILED');
    });
  }

  /// 获取旅行统计
  Future<Result<TravelHistoryStatsDto>> getTravelStats() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.travelHistoryStatsEndpoint}',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return TravelHistoryStatsDto.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('获取旅行统计失败', code: 'GET_TRAVEL_STATS_FAILED');
    });
  }

  /// 获取指定用户的旅行历史（公开接口）
  Future<Result<List<TravelHistorySummaryDto>>> getUserTravelHistory(String userId) async {
    return execute(() async {
      final endpoint = ApiConfig.travelHistoryUserEndpoint.replaceAll('{userId}', userId);

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final items = (response.data['data'] as List<dynamic>)
            .map((e) => TravelHistorySummaryDto.fromJson(e as Map<String, dynamic>))
            .toList();
        return items;
      }

      throw ServerException('获取用户旅行历史失败', code: 'GET_USER_TRAVEL_HISTORY_FAILED');
    });
  }
}

/// 分页结果
class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  PaginatedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  int get totalPages => (totalCount / pageSize).ceil();
  bool get hasMore => page < totalPages;
}
