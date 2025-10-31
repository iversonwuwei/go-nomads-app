import 'package:dio/dio.dart';

import '../models/user_city_content_models.dart';
import 'http_service.dart';

/// 用户城市内容 API 服务
class UserCityContentApiService {
  static final UserCityContentApiService _instance = UserCityContentApiService._internal();
  factory UserCityContentApiService() => _instance;

  final HttpService _httpService = HttpService();

  UserCityContentApiService._internal();

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
      final response = await _httpService.post(
        '/api/cities/$cityId/user-content/photos',
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
      final response = await _httpService.get(
        '/api/cities/$cityId/user-content/photos',
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
      await _httpService.delete('/api/cities/$cityId/user-content/photos/$photoId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的所有照片（跨城市）
  Future<List<UserCityPhoto>> getMyPhotos() async {
    try {
      final response = await _httpService.get('/api/user/city-content/photos');
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
      final response = await _httpService.post(
        '/api/cities/$cityId/user-content/expenses',
        data: {
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
      final response = await _httpService.get(
        '/api/cities/$cityId/user-content/expenses',
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
      await _httpService.delete('/api/cities/$cityId/user-content/expenses/$expenseId');
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的所有费用（跨城市）
  Future<List<UserCityExpense>> getMyExpenses() async {
    try {
      final response = await _httpService.get('/api/user/city-content/expenses');
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityExpense.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 评论相关接口 ====================

  /// 创建或更新城市评论（Upsert）
  Future<UserCityReview> upsertCityReview({
    required String cityId,
    required int rating,
    required String title,
    required String content,
    DateTime? visitDate,
  }) async {
    try {
      final response = await _httpService.post(
        '/api/cities/$cityId/user-content/reviews',
        data: {
          'rating': rating,
          'title': title,
          'content': content,
          'visitDate': visitDate?.toIso8601String(),
        },
      );
      return UserCityReview.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取城市评论列表（公开，无需登录）
  Future<List<UserCityReview>> getCityReviews(String cityId) async {
    try {
      final response = await _httpService.get('/api/cities/$cityId/user-content/reviews');
      final List<dynamic> data = response.data;
      return data.map((json) => UserCityReview.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// 获取我的城市评论
  Future<UserCityReview?> getMyCityReview(String cityId) async {
    try {
      final response = await _httpService.get('/api/cities/$cityId/user-content/reviews/mine');
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
      await _httpService.delete('/api/cities/$cityId/user-content/reviews');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 统计相关接口 ====================

  /// 获取城市用户内容统计（公开）
  Future<CityUserContentStats> getCityStats(String cityId) async {
    try {
      final response = await _httpService.get('/api/cities/$cityId/user-content/stats');
      return CityUserContentStats.fromJson(response.data);
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
