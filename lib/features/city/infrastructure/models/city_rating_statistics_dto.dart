import 'package:df_admin_mobile/features/city/domain/entities/city_rating_statistics.dart';

/// 城市评分统计 DTO
class CityRatingStatisticsDto {
  final String categoryId;
  final String categoryName;
  final String? categoryNameEn;
  final String? icon;
  final int displayOrder;
  final int ratingCount;
  final double averageRating;
  final int? userRating;

  const CityRatingStatisticsDto({
    required this.categoryId,
    required this.categoryName,
    this.categoryNameEn,
    this.icon,
    this.displayOrder = 0,
    this.ratingCount = 0,
    this.averageRating = 0.0,
    this.userRating,
  });

  factory CityRatingStatisticsDto.fromJson(Map<String, dynamic> json) {
    return CityRatingStatisticsDto(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      categoryNameEn: json['categoryNameEn'] as String?,
      icon: json['icon'] as String?,
      displayOrder: json['displayOrder'] as int? ?? 0,
      ratingCount: json['ratingCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      userRating: json['userRating'] as int?,
    );
  }

  CityRatingStatistics toEntity() {
    return CityRatingStatistics(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryNameEn: categoryNameEn,
      icon: icon,
      displayOrder: displayOrder,
      ratingCount: ratingCount,
      averageRating: averageRating,
      userRating: userRating,
    );
  }
}
