import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel_review.dart';

/// Hotel Review Repository Interface - 酒店评论仓储接口
abstract class IHotelReviewRepository {
  /// 获取酒店的评论列表（分页）
  Future<Result<HotelReviewListResponse>> getHotelReviews({
    required String hotelId,
    int page = 1,
    int pageSize = 10,
    String sortBy = 'newest',
  });

  /// 获取评论详情
  Future<Result<HotelReview>> getReviewById(String reviewId);

  /// 获取当前用户对某酒店的评论
  Future<Result<HotelReview?>> getMyReview(String hotelId);

  /// 创建评论
  Future<Result<HotelReview>> createReview({
    required String hotelId,
    required CreateHotelReviewRequest request,
  });

  /// 更新评论
  Future<Result<HotelReview>> updateReview({
    required String reviewId,
    required UpdateHotelReviewRequest request,
  });

  /// 删除评论
  Future<Result<void>> deleteReview(String reviewId);

  /// 标记评论为有帮助
  Future<Result<void>> markReviewHelpful(String reviewId);

  /// 获取酒店评分统计
  Future<Result<Map<String, dynamic>>> getRatingStats(String hotelId);
}
