import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/user_city_content/domain/entities/user_city_content.dart';

/// User City Content Repository Interface - DDD Domain Layer
abstract class IUserCityContentRepository {
  // ==================== Photo Operations ====================

  /// Add a photo to a city
  Future<Result<UserCityPhoto>> addCityPhoto({
    required String cityId,
    required String imageUrl,
    String? caption,
    String? location,
    DateTime? takenAt,
  });

  /// Batch submit up to 10 photos with metadata so backend can resolve coordinates
  Future<Result<List<UserCityPhoto>>> submitCityPhotoCollection({
    required String cityId,
    required String title,
    required List<String> imageUrls,
    String? description,
    String? locationNote,
  });

  /// Get photos for a specific city
  Future<Result<List<UserCityPhoto>>> getCityPhotos({
    required String cityId,
    bool onlyMine = false,
  });

  /// Delete a photo
  Future<Result<void>> deleteCityPhoto({
    required String cityId,
    required String photoId,
  });

  /// Get all my photos across cities
  Future<Result<List<UserCityPhoto>>> getMyPhotos();

  // ==================== Expense Operations ====================

  /// Add an expense to a city
  Future<Result<UserCityExpense>> addCityExpense({
    required String cityId,
    required ExpenseCategory category,
    required double amount,
    String currency = 'USD',
    String? description,
    required DateTime date,
  });

  /// Get expenses for a specific city
  Future<Result<List<UserCityExpense>>> getCityExpenses({
    required String cityId,
    bool onlyMine = false,
  });

  /// Delete an expense
  Future<Result<void>> deleteCityExpense({
    required String cityId,
    required String expenseId,
  });

  /// Get all my expenses across cities
  Future<Result<List<UserCityExpense>>> getMyExpenses();

  // ==================== Review Operations ====================

  /// Create or update a city review (Upsert)
  Future<Result<UserCityReview>> upsertCityReview({
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
  });

  /// Get all reviews for a city (public access)
  Future<Result<List<UserCityReview>>> getCityReviews(String cityId);

  /// Get reviews for a city with pagination
  Future<Result<PagedResult<UserCityReview>>> getCityReviewsPaged(
    String cityId, {
    int page = 1,
    int pageSize = 10,
  });

  /// Get my review for a specific city
  Future<Result<UserCityReview?>> getMyCityReview(String cityId);

  /// Delete my review for a city
  Future<Result<void>> deleteMyCityReview(String cityId);

  /// Delete a review by reviewId (admin/moderator)
  Future<Result<void>> deleteCityReview(String cityId, String reviewId);

  // ==================== Statistics Operations ====================

  /// Get city user content statistics
  Future<Result<CityUserContentStats>> getCityStats(String cityId);

  /// Get city cost summary based on user expenses
  Future<Result<CityCostSummary>> getCityCostSummary(String cityId);
}
