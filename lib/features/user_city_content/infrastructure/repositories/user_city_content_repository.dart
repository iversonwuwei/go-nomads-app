import 'package:df_admin_mobile/config/api_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart' as entity;
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/features/user_city_content/infrastructure/models/user_city_content_dto.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// User City Content Repository Implementation - DDD Infrastructure Layer
class UserCityContentRepository implements IUserCityContentRepository {
  final HttpService _httpService = Get.find();

  String _buildUrl(String path) => '${ApiConfig.apiBaseUrl}$path';

  // ==================== Photo Operations ====================

  @override
  Future<Result<entity.UserCityPhoto>> addCityPhoto({
    required String cityId,
    required String imageUrl,
    String? caption,
    String? location,
    DateTime? takenAt,
  }) async {
    try {
      final endpoint = ApiConfig.cityPhotosEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(_buildUrl(endpoint), data: {
        'imageUrl': imageUrl,
        'caption': caption,
        'location': location,
        'takenAt': takenAt?.toIso8601String(),
      });
      return Result.success(UserCityPhotoDto.fromJson(response.data).toDomain());
    } catch (e) {
      return Result.failure(UnknownException('Failed to add city photo: ${e.toString()}',
          code: 'ADD_CITY_PHOTO_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<List<entity.UserCityPhoto>>> submitCityPhotoCollection({
    required String cityId,
    required String title,
    required List<String> imageUrls,
    String? description,
    String? locationNote,
  }) async {
    try {
      final endpoint = ApiConfig.cityPhotoBatchEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(
        _buildUrl(endpoint),
        data: {
          'title': title,
          'description': description,
          'locationNote': locationNote,
          'imageUrls': imageUrls,
        },
      );

      final dataPayload = response.data;
      // 后端返回 ApiResponse，数据在 'data' 字段中
      final List<dynamic> rawList = dataPayload is List ? dataPayload : (dataPayload['data'] as List<dynamic>? ?? []);

      final createdPhotos = rawList.map((json) => UserCityPhotoDto.fromJson(json).toDomain()).toList();

      return Result.success(createdPhotos);
    } catch (e) {
      return Result.failure(UnknownException(
        'Failed to submit city photos: ${e.toString()}',
        code: 'SUBMIT_CITY_PHOTOS_ERROR',
        details: {
          'cityId': cityId,
          'error': e.toString(),
        },
      ));
    }
  }

  @override
  Future<Result<List<entity.UserCityPhoto>>> getCityPhotos({required String cityId, bool onlyMine = false}) async {
    try {
      final endpoint = ApiConfig.cityPhotosEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint), queryParameters: {'onlyMine': onlyMine});
      final List<dynamic> data = response.data;
      return Result.success(data.map((json) => UserCityPhotoDto.fromJson(json).toDomain()).toList());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get city photos: ${e.toString()}',
          code: 'GET_CITY_PHOTOS_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<void>> deleteCityPhoto({required String cityId, required String photoId}) async {
    try {
      final endpoint =
          ApiConfig.cityPhotoDetailEndpoint.replaceAll('{cityId}', cityId).replaceAll('{photoId}', photoId);
      await _httpService.delete(_buildUrl(endpoint));
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException('Failed to delete city photo: ${e.toString()}',
          code: 'DELETE_CITY_PHOTO_ERROR', details: {'cityId': cityId, 'photoId': photoId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<List<entity.UserCityPhoto>>> getMyPhotos() async {
    try {
      final response = await _httpService.get(_buildUrl(ApiConfig.myPhotosEndpoint));
      final List<dynamic> data = response.data;
      return Result.success(data.map((json) => UserCityPhotoDto.fromJson(json).toDomain()).toList());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get my photos: ${e.toString()}',
          code: 'GET_MY_PHOTOS_ERROR', details: {'error': e.toString()}));
    }
  }

  // ==================== Expense Operations ====================

  @override
  Future<Result<entity.UserCityExpense>> addCityExpense({
    required String cityId,
    required entity.ExpenseCategory category,
    required double amount,
    String currency = 'USD',
    String? description,
    required DateTime date,
  }) async {
    try {
      final endpoint = ApiConfig.cityExpensesEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(_buildUrl(endpoint), data: {
        'cityId': cityId,
        'category': category.value,
        'amount': amount,
        'currency': currency,
        'description': description,
        'date': date.toIso8601String(),
      });
      return Result.success(UserCityExpenseDto.fromJson(response.data).toDomain());
    } catch (e) {
      return Result.failure(UnknownException('Failed to add city expense: ${e.toString()}',
          code: 'ADD_CITY_EXPENSE_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<List<entity.UserCityExpense>>> getCityExpenses({required String cityId, bool onlyMine = false}) async {
    try {
      final endpoint = ApiConfig.cityExpensesEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint), queryParameters: {'onlyMine': onlyMine});
      final List<dynamic> data = response.data;
      return Result.success(data.map((json) => UserCityExpenseDto.fromJson(json).toDomain()).toList());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get city expenses: ${e.toString()}',
          code: 'GET_CITY_EXPENSES_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<void>> deleteCityExpense({required String cityId, required String expenseId}) async {
    try {
      final endpoint =
          ApiConfig.cityExpenseDetailEndpoint.replaceAll('{cityId}', cityId).replaceAll('{expenseId}', expenseId);
      await _httpService.delete(_buildUrl(endpoint));
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException('Failed to delete city expense: ${e.toString()}',
          code: 'DELETE_CITY_EXPENSE_ERROR',
          details: {'cityId': cityId, 'expenseId': expenseId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<List<entity.UserCityExpense>>> getMyExpenses() async {
    try {
      final response = await _httpService.get(_buildUrl(ApiConfig.myExpensesEndpoint));
      final List<dynamic> data = response.data;
      return Result.success(data.map((json) => UserCityExpenseDto.fromJson(json).toDomain()).toList());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get my expenses: ${e.toString()}',
          code: 'GET_MY_EXPENSES_ERROR', details: {'error': e.toString()}));
    }
  }

  // ==================== Review Operations ====================

  @override
  Future<Result<entity.UserCityReview>> upsertCityReview({
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
    List<String>? photoUrls, // ✅ 添加评论关联照片
  }) async {
    try {
      final endpoint = ApiConfig.cityReviewsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.post(_buildUrl(endpoint), data: {
        'cityId': cityId,
        'rating': rating,
        'title': title,
        'content': content,
        if (visitDate != null) 'visitDate': visitDate.toIso8601String(),
        if (internetQualityScore != null) 'internetQualityScore': internetQualityScore,
        if (safetyScore != null) 'safetyScore': safetyScore,
        if (costScore != null) 'costScore': costScore,
        if (communityScore != null) 'communityScore': communityScore,
        if (weatherScore != null) 'weatherScore': weatherScore,
        if (reviewText != null) 'reviewText': reviewText,
        if (photoUrls != null && photoUrls.isNotEmpty) 'photoUrls': photoUrls, // ✅ 传递照片 URL
      });
      return Result.success(UserCityReviewDto.fromJson(response.data).toDomain());
    } catch (e) {
      return Result.failure(UnknownException('Failed to upsert city review: ${e.toString()}',
          code: 'UPSERT_CITY_REVIEW_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<List<entity.UserCityReview>>> getCityReviews(String cityId) async {
    try {
      final endpoint = ApiConfig.cityReviewsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      final List<dynamic> data = response.data['items'] ?? response.data;
      return Result.success(data.map((json) => UserCityReviewDto.fromJson(json).toDomain()).toList());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get city reviews: ${e.toString()}',
          code: 'GET_CITY_REVIEWS_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<entity.PagedResult<entity.UserCityReview>>> getCityReviewsPaged(
    String cityId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final endpoint = ApiConfig.cityReviewsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(
        _buildUrl(endpoint),
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      // 后端返回格式是 ApiResponse<PagedResult>，实际数据在 data 字段中
      final responseData =
          response.data is Map && response.data['data'] != null ? response.data['data'] : response.data;

      debugPrint('📡 Reviews API 响应: page=$page, responseData=$responseData');

      final pagedDto = PagedResultDto<UserCityReviewDto>.fromJson(
        responseData,
        (json) => UserCityReviewDto.fromJson(json),
      );

      debugPrint(
          '📡 解析结果: items=${pagedDto.items.length}, totalCount=${pagedDto.totalCount}, hasMore=${pagedDto.hasMore}');

      return Result.success(pagedDto.toDomain((dto) => dto.toDomain()));
    } catch (e) {
      debugPrint('❌ getCityReviewsPaged 错误: $e');
      return Result.failure(UnknownException('Failed to get city reviews: ${e.toString()}',
          code: 'GET_CITY_REVIEWS_PAGED_ERROR', details: {'cityId': cityId, 'page': page, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<entity.UserCityReview?>> getMyCityReview(String cityId) async {
    try {
      final endpoint = ApiConfig.myCityReviewEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      if (response.data == null) return Result.success(null);
      return Result.success(UserCityReviewDto.fromJson(response.data).toDomain());
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return Result.success(null);
      }
      return Result.failure(UnknownException('Failed to get my city review: ${e.toString()}',
          code: 'GET_MY_CITY_REVIEW_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<void>> deleteMyCityReview(String cityId) async {
    try {
      final endpoint = ApiConfig.myCityReviewEndpoint.replaceAll('{cityId}', cityId);
      await _httpService.delete(_buildUrl(endpoint));
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException('Failed to delete my city review: ${e.toString()}',
          code: 'DELETE_MY_CITY_REVIEW_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<void>> deleteCityReview(String cityId, String reviewId) async {
    try {
      final endpoint = '/cities/$cityId/user-content/reviews/$reviewId';
      await _httpService.delete(_buildUrl(endpoint));
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownException('Failed to delete city review: ${e.toString()}',
          code: 'DELETE_CITY_REVIEW_ERROR', details: {'cityId': cityId, 'reviewId': reviewId, 'error': e.toString()}));
    }
  }

  // ==================== Statistics Operations ====================

  @override
  Future<Result<entity.CityUserContentStats>> getCityStats(String cityId) async {
    try {
      final endpoint = ApiConfig.cityUserContentStatsEndpoint.replaceAll('{cityId}', cityId);
      final response = await _httpService.get(_buildUrl(endpoint));
      return Result.success(CityUserContentStatsDto.fromJson(response.data).toDomain());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get city stats: ${e.toString()}',
          code: 'GET_CITY_STATS_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }

  @override
  Future<Result<entity.CityCostSummary>> getCityCostSummary(String cityId) async {
    try {
      final endpoint = '/cities/$cityId/user-content/cost-summary';
      final response = await _httpService.get(_buildUrl(endpoint));
      return Result.success(CityCostSummaryDto.fromJson(response.data).toDomain());
    } catch (e) {
      return Result.failure(UnknownException('Failed to get city cost summary: ${e.toString()}',
          code: 'GET_CITY_COST_SUMMARY_ERROR', details: {'cityId': cityId, 'error': e.toString()}));
    }
  }
}
