import '../database/favorite_dao.dart';

/// 收藏数据服务
/// 提供收藏数据的统一访问接口,从 SQLite 数据库读取和存储
class FavoriteDataService {
  final FavoriteDao _favoriteDao = FavoriteDao();

  /// 添加收藏
  Future<int> addFavorite(
    int userId,
    String targetType,
    int targetId,
  ) async {
    return await _favoriteDao.addFavorite(userId, targetType, targetId);
  }

  /// 取消收藏
  Future<int> removeFavorite(
    int userId,
    String targetType,
    int targetId,
  ) async {
    return await _favoriteDao.removeFavorite(userId, targetType, targetId);
  }

  /// 检查是否已收藏
  Future<bool> isFavorited(
    int userId,
    String targetType,
    int targetId,
  ) async {
    return await _favoriteDao.isFavorited(userId, targetType, targetId);
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(
    int userId,
    String targetType,
    int targetId,
  ) async {
    final isFav = await isFavorited(userId, targetType, targetId);
    if (isFav) {
      await removeFavorite(userId, targetType, targetId);
      return false;
    } else {
      await addFavorite(userId, targetType, targetId);
      return true;
    }
  }

  /// 获取用户的所有收藏
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    return await _favoriteDao.getUserFavorites(userId);
  }

  /// 获取用户收藏的城市
  Future<List<Map<String, dynamic>>> getFavoriteCities(int userId) async {
    return await _favoriteDao.getFavoriteCities(userId);
  }

  /// 获取用户收藏的活动
  Future<List<Map<String, dynamic>>> getFavoriteMeetups(int userId) async {
    return await _favoriteDao.getFavoriteMeetups(userId);
  }

  /// 获取用户收藏的共享办公空间
  Future<List<Map<String, dynamic>>> getFavoriteCoworkings(int userId) async {
    final favorites = await getUserFavorites(userId);
    return favorites.where((fav) => fav['target_type'] == 'coworking').toList();
  }

  /// 获取特定类型的收藏数量
  Future<int> getFavoriteCount(int userId, String targetType) async {
    final favorites = await getUserFavorites(userId);
    return favorites.where((fav) => fav['target_type'] == targetType).length;
  }

  /// 获取用户所有收藏数量
  Future<int> getTotalFavoriteCount(int userId) async {
    final favorites = await getUserFavorites(userId);
    return favorites.length;
  }

  /// 按类型分组获取收藏
  Future<Map<String, List<Map<String, dynamic>>>> getFavoritesByType(
    int userId,
  ) async {
    final favorites = await getUserFavorites(userId);
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (var favorite in favorites) {
      final type = favorite['target_type'] as String;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(favorite);
    }

    return grouped;
  }

  /// 批量添加收藏
  Future<void> addFavorites(
    int userId,
    List<Map<String, dynamic>> items,
  ) async {
    for (var item in items) {
      final targetType = item['target_type'] as String;
      final targetId = item['target_id'] as int;
      await addFavorite(userId, targetType, targetId);
    }
  }

  /// 清空用户的所有收藏
  Future<void> clearAllFavorites(int userId) async {
    final favorites = await getUserFavorites(userId);
    for (var favorite in favorites) {
      final targetType = favorite['target_type'] as String;
      final targetId = favorite['target_id'] as int;
      await removeFavorite(userId, targetType, targetId);
    }
  }

  /// 清空用户特定类型的收藏
  Future<void> clearFavoritesByType(int userId, String targetType) async {
    final favorites = await getUserFavorites(userId);
    final typeFavorites =
        favorites.where((fav) => fav['target_type'] == targetType).toList();

    for (var favorite in typeFavorites) {
      final targetId = favorite['target_id'] as int;
      await removeFavorite(userId, targetType, targetId);
    }
  }
}
