import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/application/use_cases/user_city_content_use_cases.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:get/get.dart';

/// User City Content State Controller - DDD Presentation Layer
class UserCityContentStateController extends GetxController {
  // Use Cases
  final AddCityPhotoUseCase _addCityPhotoUseCase;
  final GetCityPhotosUseCase _getCityPhotosUseCase;
  final DeleteCityPhotoUseCase _deleteCityPhotoUseCase;
  final GetMyPhotosUseCase _getMyPhotosUseCase;

  final AddCityExpenseUseCase _addCityExpenseUseCase;
  final GetCityExpensesUseCase _getCityExpensesUseCase;
  final DeleteCityExpenseUseCase _deleteCityExpenseUseCase;
  final GetMyExpensesUseCase _getMyExpensesUseCase;

  final UpsertCityReviewUseCase _upsertCityReviewUseCase;
  final GetCityReviewsUseCase _getCityReviewsUseCase;
  final GetMyCityReviewUseCase _getMyCityReviewUseCase;
  final DeleteMyCityReviewUseCase _deleteMyCityReviewUseCase;

  final GetCityStatsUseCase _getCityStatsUseCase;
  final GetCityCostSummaryUseCase _getCityCostSummaryUseCase;

  // Observable State
  final photos = <UserCityPhoto>[].obs;
  final expenses = <UserCityExpense>[].obs;
  final reviews = <UserCityReview>[].obs;
  final myReview = Rxn<UserCityReview>();
  final stats = Rxn<CityUserContentStats>();
  final costSummary = Rxn<CityCostSummary>();

  final isLoadingPhotos = false.obs;
  final isLoadingExpenses = false.obs;
  final isLoadingReviews = false.obs;
  final isLoadingStats = false.obs;
  final isLoadingCostSummary = false.obs;

  UserCityContentStateController({
    required AddCityPhotoUseCase addCityPhotoUseCase,
    required GetCityPhotosUseCase getCityPhotosUseCase,
    required DeleteCityPhotoUseCase deleteCityPhotoUseCase,
    required GetMyPhotosUseCase getMyPhotosUseCase,
    required AddCityExpenseUseCase addCityExpenseUseCase,
    required GetCityExpensesUseCase getCityExpensesUseCase,
    required DeleteCityExpenseUseCase deleteCityExpenseUseCase,
    required GetMyExpensesUseCase getMyExpensesUseCase,
    required UpsertCityReviewUseCase upsertCityReviewUseCase,
    required GetCityReviewsUseCase getCityReviewsUseCase,
    required GetMyCityReviewUseCase getMyCityReviewUseCase,
    required DeleteMyCityReviewUseCase deleteMyCityReviewUseCase,
    required GetCityStatsUseCase getCityStatsUseCase,
    required GetCityCostSummaryUseCase getCityCostSummaryUseCase,
  })  : _addCityPhotoUseCase = addCityPhotoUseCase,
        _getCityPhotosUseCase = getCityPhotosUseCase,
        _deleteCityPhotoUseCase = deleteCityPhotoUseCase,
        _getMyPhotosUseCase = getMyPhotosUseCase,
        _addCityExpenseUseCase = addCityExpenseUseCase,
        _getCityExpensesUseCase = getCityExpensesUseCase,
        _deleteCityExpenseUseCase = deleteCityExpenseUseCase,
        _getMyExpensesUseCase = getMyExpensesUseCase,
        _upsertCityReviewUseCase = upsertCityReviewUseCase,
        _getCityReviewsUseCase = getCityReviewsUseCase,
        _getMyCityReviewUseCase = getMyCityReviewUseCase,
        _deleteMyCityReviewUseCase = deleteMyCityReviewUseCase,
        _getCityStatsUseCase = getCityStatsUseCase,
        _getCityCostSummaryUseCase = getCityCostSummaryUseCase;

  // ==================== Photo Methods ====================

  Future<void> loadCityPhotos(String cityId, {bool onlyMine = false}) async {
    isLoadingPhotos.value = true;

    final result = await _getCityPhotosUseCase.execute(
      GetCityPhotosUseCaseParams(cityId: cityId, onlyMine: onlyMine),
    );

    result.fold(
      onSuccess: (data) {
        photos.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load photos: ${exception.message}');
      },
    );

    isLoadingPhotos.value = false;
  }

  Future<bool> addPhoto({
    required String cityId,
    required String imageUrl,
    String? caption,
    String? location,
    DateTime? takenAt,
  }) async {
    final result = await _addCityPhotoUseCase.execute(
      AddCityPhotoUseCaseParams(
        cityId: cityId,
        imageUrl: imageUrl,
        caption: caption,
        location: location,
        takenAt: takenAt,
      ),
    );

    return result.fold(
      onSuccess: (photo) {
        photos.insert(0, photo);
        return true;
      },
      onFailure: (exception) {
        // print('Failed to add photo: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> deletePhoto(String cityId, String photoId) async {
    final result = await _deleteCityPhotoUseCase.execute(
      DeleteCityPhotoUseCaseParams(cityId: cityId, photoId: photoId),
    );

    return result.fold(
      onSuccess: (_) {
        photos.removeWhere((photo) => photo.id == photoId);
        return true;
      },
      onFailure: (exception) {
        // print('Failed to delete photo: ${exception.message}');
        return false;
      },
    );
  }

  Future<void> loadMyPhotos() async {
    isLoadingPhotos.value = true;

    final result = await _getMyPhotosUseCase.execute(NoParams());

    result.fold(
      onSuccess: (data) {
        photos.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load my photos: ${exception.message}');
      },
    );

    isLoadingPhotos.value = false;
  }

  // ==================== Expense Methods ====================

  Future<void> loadCityExpenses(String cityId, {bool onlyMine = false}) async {
    isLoadingExpenses.value = true;

    final result = await _getCityExpensesUseCase.execute(
      GetCityExpensesUseCaseParams(cityId: cityId, onlyMine: onlyMine),
    );

    result.fold(
      onSuccess: (data) {
        expenses.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load expenses: ${exception.message}');
      },
    );

    isLoadingExpenses.value = false;
  }

  Future<bool> addExpense({
    required String cityId,
    required ExpenseCategory category,
    required double amount,
    String currency = 'USD',
    String? description,
    required DateTime date,
  }) async {
    final result = await _addCityExpenseUseCase.execute(
      AddCityExpenseUseCaseParams(
        cityId: cityId,
        category: category,
        amount: amount,
        currency: currency,
        description: description,
        date: date,
      ),
    );

    return result.fold(
      onSuccess: (expense) {
        expenses.insert(0, expense);
        return true;
      },
      onFailure: (exception) {
        // print('Failed to add expense: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> deleteExpense(String cityId, String expenseId) async {
    final result = await _deleteCityExpenseUseCase.execute(
      DeleteCityExpenseUseCaseParams(cityId: cityId, expenseId: expenseId),
    );

    return result.fold(
      onSuccess: (_) {
        expenses.removeWhere((expense) => expense.id == expenseId);
        return true;
      },
      onFailure: (exception) {
        // print('Failed to delete expense: ${exception.message}');
        return false;
      },
    );
  }

  Future<void> loadMyExpenses() async {
    isLoadingExpenses.value = true;

    final result = await _getMyExpensesUseCase.execute(NoParams());

    result.fold(
      onSuccess: (data) {
        expenses.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load my expenses: ${exception.message}');
      },
    );

    isLoadingExpenses.value = false;
  }

  // ==================== Review Methods ====================

  Future<void> loadCityReviews(String cityId) async {
    isLoadingReviews.value = true;

    final result = await _getCityReviewsUseCase.execute(
      GetCityReviewsUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (data) {
        reviews.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load reviews: ${exception.message}');
      },
    );

    isLoadingReviews.value = false;
  }

  Future<void> loadMyCityReview(String cityId) async {
    final result = await _getMyCityReviewUseCase.execute(
      GetMyCityReviewUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (review) {
        myReview.value = review;
      },
      onFailure: (exception) {
        // print('Failed to load my review: ${exception.message}');
      },
    );
  }

  Future<bool> upsertReview({
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
    final result = await _upsertCityReviewUseCase.execute(
      UpsertCityReviewUseCaseParams(
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
      ),
    );

    return result.fold(
      onSuccess: (review) {
        myReview.value = review;
        // Update reviews list if exists
        final index = reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          reviews[index] = review;
        } else {
          reviews.insert(0, review);
        }
        return true;
      },
      onFailure: (exception) {
        // print('Failed to upsert review: ${exception.message}');
        return false;
      },
    );
  }

  Future<bool> deleteMyReview(String cityId) async {
    final result = await _deleteMyCityReviewUseCase.execute(
      DeleteMyCityReviewUseCaseParams(cityId: cityId),
    );

    return result.fold(
      onSuccess: (_) {
        final reviewId = myReview.value?.id;
        myReview.value = null;
        if (reviewId != null) {
          reviews.removeWhere((review) => review.id == reviewId);
        }
        return true;
      },
      onFailure: (exception) {
        // print('Failed to delete my review: ${exception.message}');
        return false;
      },
    );
  }

  // ==================== Statistics Methods ====================

  Future<void> loadCityStats(String cityId) async {
    isLoadingStats.value = true;

    final result = await _getCityStatsUseCase.execute(
      GetCityStatsUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (data) {
        stats.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load city stats: ${exception.message}');
      },
    );

    isLoadingStats.value = false;
  }

  Future<void> loadCityCostSummary(String cityId) async {
    isLoadingCostSummary.value = true;

    final result = await _getCityCostSummaryUseCase.execute(
      GetCityCostSummaryUseCaseParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (data) {
        costSummary.value = data;
      },
      onFailure: (exception) {
        // print('Failed to load cost summary: ${exception.message}');
      },
    );

    isLoadingCostSummary.value = false;
  }

  // Clear state
  void clearPhotos() => photos.clear();
  void clearExpenses() => expenses.clear();
  void clearReviews() => reviews.clear();
  void clearMyReview() => myReview.value = null;
  void clearStats() => stats.value = null;
  void clearCostSummary() => costSummary.value = null;

  void clearAll() {
    clearPhotos();
    clearExpenses();
    clearReviews();
    clearMyReview();
    clearStats();
    clearCostSummary();
  }
}
