import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/user_city_content_models.dart';
import 'http_service.dart';

/// 用户城市内容 API 服务
class UserCityContentApiService {
  static final UserCityContentApiService _instance =
      UserCityContentApiService._internal();
  factory UserCityContentApiService() => _instance;

  late final HttpService _httpService;

  UserCityContentApiService._internal() {
    _httpService = HttpService();
  }

  /// 构建完整的 URL
  String _buildUrl(String path) {
    return '${ApiConfig.apiBaseUrl}$path';
  }

  // ==================== 照片相关接口 ====================

  /// 添加城市照片
  Future<UserCityPhoto> addCityPhoto({
    required String cityId,
    required String imageUrl,
    String? caption,
    String? location,
    DateTime? takenAt,
  }) async {
    try {
      final endpoint =
          ApiConfig.cityPhotosEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(
        _buildUrl(endpoint),
        data: {
          'imageUrl': imageUrl,
          'caption': caption,
          'location': location,
          'takenAt': takenAt?.toIso8601String(),
        },
      );
      return UserCityPhoto.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取城市照片列表
  Future<List<UserCityPhoto>> getCityPhotos({
    required String cityId,
    bool onlyMine = false,
  }) async {
    try {
      final endpoint =
          ApiConfig.cityPhotosEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(
        _buildUrl(endpoint),
        queryParameters: {'onlyMine': onlyMine},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityPhoto.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除照片
  Future<void> deleteCityPhoto({
    required String cityId,
    required String photoId,
  }) async {
    try {
      final endpoint = ApiConfig.cityPhotoDetailEndpoint
          .replaceAll('{cityId}', cityId)
          .replaceAll('{photoId}', photoId);
      await _httpService.delete(_buildUrl(endpoint));
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的所有照片(跨城市)
  Future<List<UserCityPhoto>> getMyPhotos() async {
    try {
      final response =
          await _httpService.get(_buildUrl(ApiConfig.myPhotosEndpoint));
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityPhoto.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 费用相关接口 ====================

  /// 添加城市费用
  Future<UserCityExpense> addCityExpense({
    required String cityId,
    required ExpenseCategory category,
    required double amount,
    String currency = 'USD',
    String? description,
    required DateTime date,
  }) async {
    try {
      final endpoint =
          ApiConfig.cityExpensesEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(
        _buildUrl(endpoint),
        data: {
          'cityId': cityId, // ✅ 添加 cityId 到请求体 (后端 DTO 需要)
          'category': category.value,
          'amount': amount,
          'currency': currency,
          'description': description,
          'date': date.toIso8601String(),
        },
      );
      return UserCityExpense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取城市费用列表
  Future<List<UserCityExpense>> getCityExpenses({
    required String cityId,
    bool onlyMine = false,
  }) async {
    try {
      final endpoint =
          ApiConfig.cityExpensesEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(
        _buildUrl(endpoint),
        queryParameters: {'onlyMine': onlyMine},
      );
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityExpense.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 删除费用
  Future<void> deleteCityExpense({
    required String cityId,
    required String expenseId,
  }) async {
    try {
      final endpoint = ApiConfig.cityExpenseDetailEndpoint
          .replaceAll('{cityId}', cityId)
          .replaceAll('{expenseId}', expenseId);
      await _httpService.delete(_buildUrl(endpoint));
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的所有费用(跨城市)
  Future<List<UserCityExpense>> getMyExpenses() async {
    try {
      final response =
          await _httpService.get(_buildUrl(ApiConfig.myExpensesEndpoint));
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityExpense.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 评论相关接口 ====================

  /// 创建或更新城市评论(Upsert)
  Future<UserCityReview> upsertCityReview({
    required String cityId,
    required int rating,
    required String title,
    required String content,
    DateTime? visitDate,
    int? internetQualityScore,
    int? safetyScore,
    int? costScore,
    int? communityScore,
    int? weatherScore,
    String? reviewText,
  }) async {
    try {
      final endpoint =
          ApiConfig.cityReviewsEndpoint.replaceAll('{cityId}', cityId);

      final requestData = {
        'cityId': cityId, // ✅ 添加 cityId 到请求体 (后端 DTO 需要)
        'rating': rating,
        'title': title,
        'content': content,
        if (visitDate != null) 'visitDate': visitDate.toIso8601String(),
        if (internetQualityScore != null)
          'internetQualityScore': internetQualityScore,
        if (safetyScore != null) 'safetyScore': safetyScore,
        if (costScore != null) 'costScore': costScore,
        if (communityScore != null) 'communityScore': communityScore,
        if (weatherScore != null) 'weatherScore': weatherScore,
        if (reviewText != null) 'reviewText': reviewText,
      };

      // 调试日志
      print('📝 提交评论数据:');
      print('CityId: $cityId');
      print('Data: $requestData');

      final response = await _httpService.post(
        _buildUrl(endpoint),
        data: requestData,
      );
      return UserCityReview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取城市评论列表(公开,无需登录)
  Future<List<UserCityReview>> getCityReviews(String cityId) async {
    try {
      final endpoint =
          ApiConfig.cityReviewsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityReview.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的城市评论
  Future<UserCityReview?> getMyCityReview(String cityId) async {
    try {
      final endpoint =
          ApiConfig.myCityReviewEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      if (response.data == null) return null;
      return UserCityReview.fromJson(response.data);
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null; // 未找到评论
      }
      throw _handleError(e);
    }
  }

  /// 删除我的城市评论
  Future<void> deleteMyCityReview(String cityId) async {
    try {
      final endpoint =
          ApiConfig.myCityReviewEndpoint.replaceAll('{cityId}', cityId);
      await _httpService.delete(_buildUrl(endpoint));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 统计相关接口 ====================

  /// 获取城市用户内容统计(公开)
  Future<CityUserContentStats> getCityStats(String cityId) async {
    try {
      final endpoint =
          ApiConfig.cityUserContentStatsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      return CityUserContentStats.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取城市综合费用统计 - 基于用户提交的实际费用数据
  Future<CityCostSummary> getCityCostSummary(String cityId) async {
    try {
      final endpoint = '/api/v1/cities/$cityId/user-content/cost-summary';
      final response = await _httpService.get(_buildUrl(endpoint));
      return CityCostSummary.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 错误处理 ====================

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final message = error.response?.data?['message'] ?? error.message;

      switch (statusCode) {
        case 400:
          return Exception('Invalid request: $message');
        case 401:
          return Exception('Unauthorized: Please login');
        case 403:
          return Exception('Forbidden: You do not have permission');
        case 404:
          return Exception('Not found: $message');
        case 409:
          return Exception('Conflict: $message');
        case 500:
          return Exception('Server error: $message');
        default:
          return Exception('Network error: $message');
      }
    }
    return Exception('Unknown error: $error');
  }
}
