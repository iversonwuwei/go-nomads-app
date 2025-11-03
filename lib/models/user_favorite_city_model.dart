/// 用户收藏城市模型
class UserFavoriteCity {
  final String id;
  final String userId;
  final String cityId;
  final DateTime createdAt;

  UserFavoriteCity({
    required this.id,
    required this.userId,
    required this.cityId,
    required this.createdAt,
  });

  factory UserFavoriteCity.fromJson(Map<String, dynamic> json) {
    return UserFavoriteCity(
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
}
