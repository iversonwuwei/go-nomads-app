/// UserFavoriteCity Domain Entity - 用户收藏城市
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

  // Business logic methods
  bool get isRecent {
    final now = DateTime.now();
    return now.difference(createdAt).inDays < 7;
  }
}
