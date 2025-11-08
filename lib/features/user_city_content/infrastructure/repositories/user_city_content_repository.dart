import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart'
    as entity;
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/services/user_city_content_api_service.dart';
import 'package:get/get.dart';

/// User City Content Repository Implementation - DDD Infrastructure Layer
class UserCityContentRepository implements IUserCityContentRepository {
  final UserCityContentApiService _apiService = Get.find();

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
      final photo = await _apiService.addCityPhoto(
        cityId: cityId,
        imageUrl: imageUrl,
        caption: caption,
        location: location,
        takenAt: takenAt,
      );
      return Result.success(photo);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to add city photo: ${e.toString()}',
          code: 'ADD_CITY_PHOTO_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.UserCityPhoto>>> getCityPhotos({
    required String cityId,
    bool onlyMine = false,
  }) async {
    try {
      final photos = await _apiService.getCityPhotos(
        cityId: cityId,
        onlyMine: onlyMine,
      );
      return Result.success(photos);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city photos: ${e.toString()}',
          code: 'GET_CITY_PHOTOS_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteCityPhoto({
    required String cityId,
    required String photoId,
  }) async {
    try {
      await _apiService.deleteCityPhoto(
        cityId: cityId,
        photoId: photoId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to delete city photo: ${e.toString()}',
          code: 'DELETE_CITY_PHOTO_ERROR',
          details: {
            'cityId': cityId,
            'photoId': photoId,
            'error': e.toString(),
          },
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.UserCityPhoto>>> getMyPhotos() async {
    try {
      final photos = await _apiService.getMyPhotos();
      return Result.success(photos);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get my photos: ${e.toString()}',
          code: 'GET_MY_PHOTOS_ERROR',
          details: {'error': e.toString()},
        ),
      );
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
      final expense = await _apiService.addCityExpense(
        cityId: cityId,
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        date: date,
      );
      return Result.success(expense);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to add city expense: ${e.toString()}',
          code: 'ADD_CITY_EXPENSE_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.UserCityExpense>>> getCityExpenses({
    required String cityId,
    bool onlyMine = false,
  }) async {
    try {
      final expenses = await _apiService.getCityExpenses(
        cityId: cityId,
        onlyMine: onlyMine,
      );
      return Result.success(expenses);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city expenses: ${e.toString()}',
          code: 'GET_CITY_EXPENSES_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteCityExpense({
    required String cityId,
    required String expenseId,
  }) async {
    try {
      await _apiService.deleteCityExpense(
        cityId: cityId,
        expenseId: expenseId,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to delete city expense: ${e.toString()}',
          code: 'DELETE_CITY_EXPENSE_ERROR',
          details: {
            'cityId': cityId,
            'expenseId': expenseId,
            'error': e.toString(),
          },
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.UserCityExpense>>> getMyExpenses() async {
    try {
      final expenses = await _apiService.getMyExpenses();
      return Result.success(expenses);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get my expenses: ${e.toString()}',
          code: 'GET_MY_EXPENSES_ERROR',
          details: {'error': e.toString()},
        ),
      );
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
  }) async {
    try {
      final review = await _apiService.upsertCityReview(
        cityId: cityId,
        rating: rating,
        title: title,
        content: content,
        visitDate: visitDate,
        internetQualityScore: internetQualityScore,
        safetyScore: safetyScore,
        costScore: costScore,
        communityScore: communityScore,
        weatherScore: weatherScore,
        reviewText: reviewText,
      );
      return Result.success(review);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to upsert city review: ${e.toString()}',
          code: 'UPSERT_CITY_REVIEW_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<List<entity.UserCityReview>>> getCityReviews(
      String cityId) async {
    try {
      final reviews = await _apiService.getCityReviews(cityId);
      return Result.success(reviews);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city reviews: ${e.toString()}',
          code: 'GET_CITY_REVIEWS_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<entity.UserCityReview?>> getMyCityReview(String cityId) async {
    try {
      final review = await _apiService.getMyCityReview(cityId);
      return Result.success(review);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get my city review: ${e.toString()}',
          code: 'GET_MY_CITY_REVIEW_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteMyCityReview(String cityId) async {
    try {
      await _apiService.deleteMyCityReview(cityId);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to delete my city review: ${e.toString()}',
          code: 'DELETE_MY_CITY_REVIEW_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  // ==================== Statistics Operations ====================

  @override
  Future<Result<entity.CityUserContentStats>> getCityStats(
      String cityId) async {
    try {
      final stats = await _apiService.getCityStats(cityId);
      return Result.success(stats);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city stats: ${e.toString()}',
          code: 'GET_CITY_STATS_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<entity.CityCostSummary>> getCityCostSummary(
      String cityId) async {
    try {
      final summary = await _apiService.getCityCostSummary(cityId);
      return Result.success(summary);
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city cost summary: ${e.toString()}',
          code: 'GET_CITY_COST_SUMMARY_ERROR',
          details: {'cityId': cityId, 'error': e.toString()},
        ),
      );
    }
  }
}
