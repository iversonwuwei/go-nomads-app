import 'weather_model.dart';

/// 城市信息模型 (用于首页 feed)
class CityFeedModel {
  final String id;
  final String name;
  final String country;
  final String? imageUrl;
  final String? description;
  final int meetupCount;
  final WeatherModel? weather;

  CityFeedModel({
    required this.id,
    required this.name,
    required this.country,
    this.imageUrl,
    this.description,
    required this.meetupCount,
    this.weather,
  });

  factory CityFeedModel.fromJson(Map<String, dynamic> json) {
    return CityFeedModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      country: json['country'] as String? ?? '',
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      meetupCount: (json['meetupCount'] as num?)?.toInt() ?? 0,
      weather: json['weather'] != null
          ? WeatherModel.fromJson(json['weather'] as Map<String, dynamic>)
          : null,
    );
  }

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
}
