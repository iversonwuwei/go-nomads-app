import 'package:df_admin_mobile/core/application/use_case.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/entities/user_city_content.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';

// ==================== Photo Use Cases ====================

/// Add City Photo Use Case
class AddCityPhotoUseCase extends UseCase<UserCityPhoto, AddCityPhotoUseCaseParams> {
  final IUserCityContentRepository _repository;

  AddCityPhotoUseCase(this._repository);

  @override
  Future<Result<UserCityPhoto>> execute(AddCityPhotoUseCaseParams params) async {
    return await _repository.addCityPhoto(
      cityId: params.cityId,
      imageUrl: params.imageUrl,
      caption: params.caption,
      location: params.location,
      takenAt: params.takenAt,
    );
  }
}

/// Submit multiple photos with metadata
class SubmitCityPhotosUseCase extends UseCase<List<UserCityPhoto>, SubmitCityPhotosParams> {
  final IUserCityContentRepository _repository;

  SubmitCityPhotosUseCase(this._repository);

  @override
  Future<Result<List<UserCityPhoto>>> execute(SubmitCityPhotosParams params) async {
    return await _repository.submitCityPhotoCollection(
      cityId: params.cityId,
      title: params.title,
      imageUrls: params.imageUrls,
      description: params.description,
      locationNote: params.locationNote,
    );
  }
}

class SubmitCityPhotosParams {
  final String cityId;
  final String title;
  final List<String> imageUrls;
  final String? description;
  final String? locationNote;

  SubmitCityPhotosParams({
    required this.cityId,
    required this.title,
    required this.imageUrls,
    this.description,
    this.locationNote,
  });
}

class AddCityPhotoUseCaseParams {
  final String cityId;
  final String imageUrl;
  final String? caption;
  final String? location;
  final DateTime? takenAt;

  AddCityPhotoUseCaseParams({
    required this.cityId,
    required this.imageUrl,
    this.caption,
    this.location,
    this.takenAt,
  });
}

/// Get City Photos Use Case
class GetCityPhotosUseCase extends UseCase<List<UserCityPhoto>, GetCityPhotosUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetCityPhotosUseCase(this._repository);

  @override
  Future<Result<List<UserCityPhoto>>> execute(GetCityPhotosUseCaseParams params) async {
    return await _repository.getCityPhotos(
      cityId: params.cityId,
      onlyMine: params.onlyMine,
    );
  }
}

class GetCityPhotosUseCaseParams {
  final String cityId;
  final bool onlyMine;

  GetCityPhotosUseCaseParams({
    required this.cityId,
    this.onlyMine = false,
  });
}

/// Delete City Photo Use Case
class DeleteCityPhotoUseCase extends UseCase<void, DeleteCityPhotoUseCaseParams> {
  final IUserCityContentRepository _repository;

  DeleteCityPhotoUseCase(this._repository);

  @override
  Future<Result<void>> execute(DeleteCityPhotoUseCaseParams params) async {
    return await _repository.deleteCityPhoto(
      cityId: params.cityId,
      photoId: params.photoId,
    );
  }
}

class DeleteCityPhotoUseCaseParams {
  final String cityId;
  final String photoId;

  DeleteCityPhotoUseCaseParams({
    required this.cityId,
    required this.photoId,
  });
}

/// Get My Photos Use Case
class GetMyPhotosUseCase extends UseCase<List<UserCityPhoto>, NoParams> {
  final IUserCityContentRepository _repository;

  GetMyPhotosUseCase(this._repository);

  @override
  Future<Result<List<UserCityPhoto>>> execute(NoParams params) async {
    return await _repository.getMyPhotos();
  }
}

// ==================== Expense Use Cases ====================

/// Add City Expense Use Case
class AddCityExpenseUseCase extends UseCase<UserCityExpense, AddCityExpenseUseCaseParams> {
  final IUserCityContentRepository _repository;

  AddCityExpenseUseCase(this._repository);

  @override
  Future<Result<UserCityExpense>> execute(AddCityExpenseUseCaseParams params) async {
    return await _repository.addCityExpense(
      cityId: params.cityId,
      category: params.category,
      amount: params.amount,
      currency: params.currency,
      description: params.description,
      date: params.date,
    );
  }
}

class AddCityExpenseUseCaseParams {
  final String cityId;
  final ExpenseCategory category;
  final double amount;
  final String currency;
  final String? description;
  final DateTime date;

  AddCityExpenseUseCaseParams({
    required this.cityId,
    required this.category,
    required this.amount,
    this.currency = 'USD',
    this.description,
    required this.date,
  });
}

/// Get City Expenses Use Case
class GetCityExpensesUseCase extends UseCase<List<UserCityExpense>, GetCityExpensesUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetCityExpensesUseCase(this._repository);

  @override
  Future<Result<List<UserCityExpense>>> execute(GetCityExpensesUseCaseParams params) async {
    return await _repository.getCityExpenses(
      cityId: params.cityId,
      onlyMine: params.onlyMine,
    );
  }
}

class GetCityExpensesUseCaseParams {
  final String cityId;
  final bool onlyMine;

  GetCityExpensesUseCaseParams({
    required this.cityId,
    this.onlyMine = false,
  });
}

/// Delete City Expense Use Case
class DeleteCityExpenseUseCase extends UseCase<void, DeleteCityExpenseUseCaseParams> {
  final IUserCityContentRepository _repository;

  DeleteCityExpenseUseCase(this._repository);

  @override
  Future<Result<void>> execute(DeleteCityExpenseUseCaseParams params) async {
    return await _repository.deleteCityExpense(
      cityId: params.cityId,
      expenseId: params.expenseId,
    );
  }
}

class DeleteCityExpenseUseCaseParams {
  final String cityId;
  final String expenseId;

  DeleteCityExpenseUseCaseParams({
    required this.cityId,
    required this.expenseId,
  });
}

/// Get My Expenses Use Case
class GetMyExpensesUseCase extends UseCase<List<UserCityExpense>, NoParams> {
  final IUserCityContentRepository _repository;

  GetMyExpensesUseCase(this._repository);

  @override
  Future<Result<List<UserCityExpense>>> execute(NoParams params) async {
    return await _repository.getMyExpenses();
  }
}

// ==================== Review Use Cases ====================

/// Upsert City Review Use Case
class UpsertCityReviewUseCase extends UseCase<UserCityReview, UpsertCityReviewUseCaseParams> {
  final IUserCityContentRepository _repository;

  UpsertCityReviewUseCase(this._repository);

  @override
  Future<Result<UserCityReview>> execute(UpsertCityReviewUseCaseParams params) async {
    return await _repository.upsertCityReview(
      cityId: params.cityId,
      rating: params.rating,
      title: params.title,
      content: params.content,
      visitDate: params.visitDate,
      internetQualityScore: params.internetQualityScore,
      safetyScore: params.safetyScore,
      costScore: params.costScore,
      communityScore: params.communityScore,
      weatherScore: params.weatherScore,
      reviewText: params.reviewText,
      photoUrls: params.photoUrls, // ✅ 传递照片 URL
    );
  }
}

class UpsertCityReviewUseCaseParams {
  final String cityId;
  final int rating;
  final String title;
  final String content;
  final DateTime? visitDate;
  final int? internetQualityScore;
  final int? safetyScore;
  final int? costScore;
  final int? communityScore;
  final int? weatherScore;
  final String? reviewText;
  final List<String>? photoUrls; // ✅ 添加评论关联照片

  UpsertCityReviewUseCaseParams({
    required this.cityId,
    required this.rating,
    required this.title,
    required this.content,
    this.visitDate,
    this.internetQualityScore,
    this.safetyScore,
    this.costScore,
    this.communityScore,
    this.weatherScore,
    this.reviewText,
    this.photoUrls, // ✅ 添加参数
  });
}

/// Get City Reviews Paged Use Case - 分页获取评论
class GetCityReviewsPagedUseCase extends UseCase<PagedResult<UserCityReview>, GetCityReviewsPagedUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetCityReviewsPagedUseCase(this._repository);

  @override
  Future<Result<PagedResult<UserCityReview>>> execute(GetCityReviewsPagedUseCaseParams params) async {
    return await _repository.getCityReviewsPaged(
      params.cityId,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

class GetCityReviewsPagedUseCaseParams {
  final String cityId;
  final int page;
  final int pageSize;

  GetCityReviewsPagedUseCaseParams({
    required this.cityId,
    this.page = 1,
    this.pageSize = 10,
  });
}

/// Get My City Review Use Case
class GetMyCityReviewUseCase extends UseCase<UserCityReview?, GetMyCityReviewUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetMyCityReviewUseCase(this._repository);

  @override
  Future<Result<UserCityReview?>> execute(GetMyCityReviewUseCaseParams params) async {
    return await _repository.getMyCityReview(params.cityId);
  }
}

class GetMyCityReviewUseCaseParams {
  final String cityId;

  GetMyCityReviewUseCaseParams({required this.cityId});
}

/// Delete My City Review Use Case
class DeleteMyCityReviewUseCase extends UseCase<void, DeleteMyCityReviewUseCaseParams> {
  final IUserCityContentRepository _repository;

  DeleteMyCityReviewUseCase(this._repository);

  @override
  Future<Result<void>> execute(DeleteMyCityReviewUseCaseParams params) async {
    return await _repository.deleteMyCityReview(params.cityId);
  }
}

class DeleteMyCityReviewUseCaseParams {
  final String cityId;

  DeleteMyCityReviewUseCaseParams({required this.cityId});
}

/// Delete City Review Use Case (admin/moderator)
class DeleteCityReviewUseCase extends UseCase<void, DeleteCityReviewUseCaseParams> {
  final IUserCityContentRepository _repository;

  DeleteCityReviewUseCase(this._repository);

  @override
  Future<Result<void>> execute(DeleteCityReviewUseCaseParams params) async {
    return await _repository.deleteCityReview(params.cityId, params.reviewId);
  }
}

class DeleteCityReviewUseCaseParams {
  final String cityId;
  final String reviewId;

  DeleteCityReviewUseCaseParams({required this.cityId, required this.reviewId});
}

// ==================== Statistics Use Cases ====================

/// Get City Stats Use Case
class GetCityStatsUseCase extends UseCase<CityUserContentStats, GetCityStatsUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetCityStatsUseCase(this._repository);

  @override
  Future<Result<CityUserContentStats>> execute(GetCityStatsUseCaseParams params) async {
    return await _repository.getCityStats(params.cityId);
  }
}

class GetCityStatsUseCaseParams {
  final String cityId;

  GetCityStatsUseCaseParams({required this.cityId});
}

/// Get City Cost Summary Use Case
class GetCityCostSummaryUseCase extends UseCase<CityCostSummary, GetCityCostSummaryUseCaseParams> {
  final IUserCityContentRepository _repository;

  GetCityCostSummaryUseCase(this._repository);

  @override
  Future<Result<CityCostSummary>> execute(GetCityCostSummaryUseCaseParams params) async {
    return await _repository.getCityCostSummary(params.cityId);
  }
}

class GetCityCostSummaryUseCaseParams {
  final String cityId;

  GetCityCostSummaryUseCaseParams({required this.cityId});
}
