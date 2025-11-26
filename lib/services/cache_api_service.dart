import 'package:dio/dio.dart';

import 'package:df_admin_mobile/config/api_config.dart';

/// Cache Service API 客户端
/// 用于获取城市和共享办公空间的评分缓存数据
/// 注意: 所有请求通过 Gateway 统一转发到 CacheService
class CacheApiService {
  static final CacheApiService _instance = CacheApiService._internal();
  factory CacheApiService() => _instance;

  late final Dio _dio;

  CacheApiService._internal() {
    // 创建 Dio 实例,通过 Gateway 访问 CacheService
    _dio = Dio(BaseOptions(
      baseUrl: '${ApiConfig.baseUrl}/api',
      connectTimeout: const Duration(milliseconds: 10000),
      receiveTimeout: const Duration(milliseconds: 30000),
      sendTimeout: const Duration(milliseconds: 10000),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加日志拦截器
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print('🔵 [CacheService via Gateway] $obj'),
    ));
  }

  /// 获取单个城市评分
  Future<CityScoreResponse> getCityScore(String cityId) async {
    try {
      final response = await _dio.get('/v1/cache/scores/city/$cityId');
      return CityScoreResponse.fromJson(response.data);
    } catch (e) {
      print('❌ 获取城市评分失败: $e');
      rethrow;
    }
  }

  /// 批量获取城市评分
  Future<BatchCityScoreResponse> getCityScoresBatch(List<String> cityIds) async {
    try {
      print('📊 批量获取城市评分: ${cityIds.length} 个城市');
      
      final response = await _dio.post(
        '/v1/cache/scores/city/batch',
        data: cityIds,
      );

      return BatchCityScoreResponse.fromJson(response.data);
    } catch (e) {
      print('❌ 批量获取城市评分失败: $e');
      rethrow;
    }
  }

  /// 获取共享办公空间评分
  Future<CityScoreResponse> getCoworkingScore(String coworkingId) async {
    try {
      final response = await _dio.get('/v1/cache/scores/coworking/$coworkingId');
      return CityScoreResponse.fromJson(response.data);
    } catch (e) {
      print('❌ 获取共享空间评分失败: $e');
      rethrow;
    }
  }

  /// 批量获取共享办公空间评分
  Future<BatchCityScoreResponse> getCoworkingScoresBatch(
      List<String> coworkingIds) async {
    try {
      final response = await _dio.post(
        '/v1/cache/scores/coworking/batch',
        data: coworkingIds,
      );

      return BatchCityScoreResponse.fromJson(response.data);
    } catch (e) {
      print('❌ 批量获取共享空间评分失败: $e');
      rethrow;
    }
  }

  /// 使城市评分缓存失效
  Future<void> invalidateCityScore(String cityId) async {
    try {
      await _dio.delete('/v1/cache/scores/city/$cityId');
      print('✅ 城市评分缓存已失效: $cityId');
    } catch (e) {
      print('❌ 使城市评分缓存失效失败: $e');
      rethrow;
    }
  }

  /// 使共享办公空间评分缓存失效
  Future<void> invalidateCoworkingScore(String coworkingId) async {
    try {
      await _dio.delete('/v1/cache/scores/coworking/$coworkingId');
      print('✅ 共享空间评分缓存已失效: $coworkingId');
    } catch (e) {
      print('❌ 使共享空间评分缓存失效失败: $e');
      rethrow;
    }
  }
}

/// 城市评分响应
class CityScoreResponse {
  final String entityId;
  final double overallScore;
  final bool fromCache;
  final Map<String, dynamic>? statistics;

  CityScoreResponse({
    required this.entityId,
    required this.overallScore,
    required this.fromCache,
    this.statistics,
  });

  factory CityScoreResponse.fromJson(Map<String, dynamic> json) {
    return CityScoreResponse(
      entityId: json['entityId'] as String,
      overallScore: (json['overallScore'] as num).toDouble(),
      fromCache: json['fromCache'] as bool,
      statistics: json['statistics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entityId': entityId,
      'overallScore': overallScore,
      'fromCache': fromCache,
      if (statistics != null) 'statistics': statistics,
    };
  }
}

/// 批量城市评分响应
class BatchCityScoreResponse {
  final List<CityScoreResponse> scores;
  final int totalCount;
  final int cachedCount;
  final int calculatedCount;

  BatchCityScoreResponse({
    required this.scores,
    required this.totalCount,
    required this.cachedCount,
    required this.calculatedCount,
  });

  factory BatchCityScoreResponse.fromJson(Map<String, dynamic> json) {
    return BatchCityScoreResponse(
      scores: (json['scores'] as List<dynamic>)
          .map((e) => CityScoreResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: json['totalCount'] as int,
      cachedCount: json['cachedCount'] as int,
      calculatedCount: json['calculatedCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scores': scores.map((s) => s.toJson()).toList(),
      'totalCount': totalCount,
      'cachedCount': cachedCount,
      'calculatedCount': calculatedCount,
    };
  }
}
