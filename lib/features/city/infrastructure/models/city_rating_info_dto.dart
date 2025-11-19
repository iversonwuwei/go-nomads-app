import '../../domain/entities/city_rating_info.dart';
import 'city_rating_category_dto.dart';
import 'city_rating_statistics_dto.dart';

/// 城市评分信息 DTO
class CityRatingInfoDto {
  final List<CityRatingCategoryDto> categories;
  final List<CityRatingStatisticsDto> statistics;
  final double overallScore;

  const CityRatingInfoDto({
    required this.categories,
    required this.statistics,
    required this.overallScore,
  });

  factory CityRatingInfoDto.fromJson(Map<String, dynamic> json) {
    return CityRatingInfoDto(
      categories: (json['categories'] as List<dynamic>?)
              ?.map((e) =>
                  CityRatingCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      statistics: (json['statistics'] as List<dynamic>?)
              ?.map((e) =>
                  CityRatingStatisticsDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  CityRatingInfo toEntity() {
    return CityRatingInfo(
      categories: categories.map((dto) => dto.toEntity()).toList(),
      statistics: statistics.map((dto) => dto.toEntity()).toList(),
      overallScore: overallScore,
    );
  }
}
