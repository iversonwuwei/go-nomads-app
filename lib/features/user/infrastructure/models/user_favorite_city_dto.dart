import '../../domain/entities/user_favorite_city.dart' as domain;

// Type alias for backward compatibility
typedef UserFavoriteCity = UserFavoriteCityDto;

/// UserFavoriteCity DTO
class UserFavoriteCityDto {
  final String id;
  final String userId;
  final String cityId;
  final DateTime createdAt;

  UserFavoriteCityDto({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.createdAt,
  });

  factory UserFavoriteCityDto.fromJson(Map<String, dynamic> json) {
    return UserFavoriteCityDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cityId: json['city_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'city_id': cityId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  domain.UserFavoriteCity toDomain() {
    return domain.UserFavoriteCity(
      id: id,
      userId: userId,
      cityId: cityId,
      createdAt: createdAt,
    );
  }
}
