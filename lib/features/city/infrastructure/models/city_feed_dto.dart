// Legacy model import removed - model no longer exists
// import 'package:go_nomads_app/models/city_feed_model.dart' as legacy;
import 'package:go_nomads_app/features/weather/infrastructure/models/weather_dto.dart';

/// CityFeed DTO - ??????(?????>feed)
class CityFeedDto {
  final String id;
  final String name;
  final String country;
  final String? imageUrl;
  final String? description;
  final int meetupCount;
  final WeatherDto? weather;

  CityFeedDto({
    required this.id,
    required this.name,
    required this.country,
    this.imageUrl,
    this.description,
    required this.meetupCount,
    this.weather,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'imageUrl': imageUrl,
      'description': description,
      'meetupCount': meetupCount,
      'weather': weather?.toJson(),
    };
  }

  factory CityFeedDto.fromJson(Map<String, dynamic> json) {
    return CityFeedDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      meetupCount: (json['meetupCount'] as num?)?.toInt() ?? 0,
      weather: json['weather'] != null
          ? WeatherDto.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
    );
  }

  /* Legacy model removed - fromLegacyModel method disabled
  factory CityFeedDto.fromLegacyModel(CityFeedDto model) {
    return CityFeedDto(
      id: model.id,
      name: model.name,
      country: model.country,
      imageUrl: model.imageUrl,
      description: model.description,
      meetupCount: model.meetupCount,
      weather: model.weather != null
          ? WeatherDto.fromLegacyModel(model.weather!)
          : null,
    );
  }
  */
}
