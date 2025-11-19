/// 城市评分统计实体
class CityRatingStatistics {
  final String categoryId;
  final String categoryName;
  final String? categoryNameEn;
  final String? icon;
  final int displayOrder;
  final int ratingCount;
  final double averageRating;
  final int? userRating; // 当前用户的评分

  const CityRatingStatistics({
    required this.categoryId,
    required this.categoryName,
    this.categoryNameEn,
    this.icon,
    this.displayOrder = 0,
    this.ratingCount = 0,
    this.averageRating = 0.0,
    this.userRating,
  });
}
