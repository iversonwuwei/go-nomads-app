import 'city_rating_category.dart';
import 'city_rating_statistics.dart';

/// 城市评分信息（包含评分项和统计）
class CityRatingInfo {
  final List<CityRatingCategory> categories;
  final List<CityRatingStatistics> statistics;
  final double overallScore;

  const CityRatingInfo({
    required this.categories,
    required this.statistics,
    required this.overallScore,
  });
}
