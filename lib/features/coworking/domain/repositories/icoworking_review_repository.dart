import '../entities/coworking_review.dart';

/// Coworking Review Repository Interface
abstract class ICoworkingReviewRepository {
  /// 获取指定 Coworking 的评论列表（分页）
  Future<List<CoworkingReview>> getCoworkingReviews({
    required String coworkingId,
    required int page,
    required int pageSize,
  });

  /// 添加评论
  Future<CoworkingReview> addReview({
    required String coworkingId,
    required double rating,
    required String title,
    required String content,
    DateTime? visitDate,
    List<String>? photoUrls,
  });

  /// 更新评论
  Future<CoworkingReview> updateReview({
    required String reviewId,
    double? rating,
    String? title,
    String? content,
    DateTime? visitDate,
    List<String>? photoUrls,
  });

  /// 删除评论
  Future<void> deleteReview(String reviewId);

  /// 获取单个评论详情
  Future<CoworkingReview?> getReviewById(String reviewId);

  /// 获取当前用户对指定 Coworking 的评论
  Future<CoworkingReview?> getUserReviewForCoworking(String coworkingId);
}
