import '../database/review_dao.dart';

/// 评论数据服务
/// 提供评论数据的统一访问接口,从 SQLite 数据库读取和存储
class ReviewDataService {
  final ReviewDao _reviewDao = ReviewDao();

  /// 获取目标对象的所有评论
  /// targetType: 'city', 'meetup', 'coworking' 等
  Future<List<Map<String, dynamic>>> getReviewsByTarget(
    String targetType,
    int targetId,
  ) async {
    return await _reviewDao.getReviewsByTarget(targetType, targetId);
  }

  /// 获取用户的所有评论
  Future<List<Map<String, dynamic>>> getReviewsByUser(int userId) async {
    return await _reviewDao.getReviewsByUser(userId);
  }

  /// 添加新评论
  Future<int> addReview(Map<String, dynamic> reviewData) async {
    return await _reviewDao.insertReview(reviewData);
  }

  /// 更新评论
  Future<int> updateReview(int id, Map<String, dynamic> reviewData) async {
    return await _reviewDao.updateReview(id, reviewData);
  }

  /// 删除评论
  Future<int> deleteReview(int id) async {
    return await _reviewDao.deleteReview(id);
  }

  /// 获取目标对象的平均评分
  Future<double> getAverageRating(String targetType, int targetId) async {
    return await _reviewDao.getAverageRating(targetType, targetId);
  }

  /// 获取目标对象的评论数量
  Future<int> getReviewCount(String targetType, int targetId) async {
    return await _reviewDao.getReviewCount(targetType, targetId);
  }

  /// 获取评论详情(包含用户信息)
  Future<Map<String, dynamic>?> getReviewById(int id) async {
    return await _reviewDao.getReviewById(id);
  }

  /// 检查用户是否已评论过某个对象
  Future<bool> hasUserReviewed(
    int userId,
    String targetType,
    int targetId,
  ) async {
    final reviews = await getReviewsByTarget(targetType, targetId);
    return reviews.any((review) => review['user_id'] == userId);
  }

  /// 获取用户对某个对象的评论
  Future<Map<String, dynamic>?> getUserReviewForTarget(
    int userId,
    String targetType,
    int targetId,
  ) async {
    final reviews = await getReviewsByTarget(targetType, targetId);
    try {
      return reviews.firstWhere((review) => review['user_id'] == userId);
    } catch (e) {
      return null;
    }
  }

  /// 排序评论
  List<Map<String, dynamic>> sortReviews(
    List<Map<String, dynamic>> reviews,
    String sortBy,
  ) {
    final List<Map<String, dynamic>> sortedReviews = List.from(reviews);

    switch (sortBy) {
      case 'date_desc':
        sortedReviews.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] as String? ?? '');
          final dateB = DateTime.tryParse(b['created_at'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
        break;

      case 'date_asc':
        sortedReviews.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] as String? ?? '');
          final dateB = DateTime.tryParse(b['created_at'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateA.compareTo(dateB);
        });
        break;

      case 'rating_desc':
        sortedReviews.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0;
          return ratingB.compareTo(ratingA);
        });
        break;

      case 'rating_asc':
        sortedReviews.sort((a, b) {
          final ratingA = (a['rating'] as num?)?.toDouble() ?? 0;
          final ratingB = (b['rating'] as num?)?.toDouble() ?? 0;
          return ratingA.compareTo(ratingB);
        });
        break;

      default:
        // 默认按日期降序
        sortedReviews.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] as String? ?? '');
          final dateB = DateTime.tryParse(b['created_at'] as String? ?? '');
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });
    }

    return sortedReviews;
  }

  /// 筛选评论
  List<Map<String, dynamic>> filterReviews(
    List<Map<String, dynamic>> reviews, {
    double? minRating,
    double? maxRating,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<Map<String, dynamic>> filtered = List.from(reviews);

    // 按评分筛选
    if (minRating != null) {
      filtered = filtered.where((review) {
        final rating = (review['rating'] as num?)?.toDouble() ?? 0;
        return rating >= minRating;
      }).toList();
    }

    if (maxRating != null) {
      filtered = filtered.where((review) {
        final rating = (review['rating'] as num?)?.toDouble() ?? 0;
        return rating <= maxRating;
      }).toList();
    }

    // 按日期筛选
    if (startDate != null) {
      filtered = filtered.where((review) {
        final createdAt =
            DateTime.tryParse(review['created_at'] as String? ?? '');
        return createdAt != null && createdAt.isAfter(startDate);
      }).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((review) {
        final createdAt =
            DateTime.tryParse(review['created_at'] as String? ?? '');
        return createdAt != null && createdAt.isBefore(endDate);
      }).toList();
    }

    return filtered;
  }
}
