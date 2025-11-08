import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../features/user/infrastructure/models/user_favorite_city_dto.dart';
import 'http_service.dart';

/// 用户收藏城市API服务
class UserFavoriteCityApiService {
  static final UserFavoriteCityApiService _instance =
      UserFavoriteCityApiService._internal();
  factory UserFavoriteCityApiService() => _instance;
  UserFavoriteCityApiService._internal();

  final HttpService _httpService = HttpService();

  /// 检查城市是否已收藏
  Future<bool> isCityFavorited(String cityId) async {
    try {
      final response = await _httpService.get(
        '${ApiConfig.apiBaseUrl}/user-favorite-cities/check/$cityId',
      );

      return response.data['isFavorited'] as bool? ?? false;
    } catch (e) {
      print('❌ 检查收藏状态失败: $e');
      return false;
    }
  }

  /// 添加收藏城市
  Future<bool> addFavoriteCity(String cityId) async {
    try {
      await _httpService.post(
        '${ApiConfig.apiBaseUrl}/user-favorite-cities',
        data: {'cityId': cityId},
      );

      print('✅ 收藏城市成功: $cityId');
      return true;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 409) {
        print('ℹ️ 城市已在收藏列表中');
        return true;
      }
      print('❌ 收藏城市失败: $e');
      return false;
    }
  }

  /// 移除收藏城市
  Future<bool> removeFavoriteCity(String cityId) async {
    try {
      await _httpService.delete(
        '${ApiConfig.apiBaseUrl}/user-favorite-cities/$cityId',
      );

      print('✅ 取消收藏成功: $cityId');
      return true;
    } catch (e) {
      print('❌ 取消收藏失败: $e');
      return false;
    }
  }

  /// 切换收藏状态
  Future<bool> toggleFavorite(String cityId) async {
    final isFavorited = await isCityFavorited(cityId);
    if (isFavorited) {
      return await removeFavoriteCity(cityId);
    } else {
      return await addFavoriteCity(cityId);
    }
  }

  /// 获取用户所有收藏的城市ID列表
  Future<List<String>> getUserFavoriteCityIds() async {
    try {
      final response = await _httpService.get(
        '${ApiConfig.apiBaseUrl}/user-favorite-cities/ids',
      );

      return (response.data as List<dynamic>)
          .map((id) => id as String)
          .toList();
    } catch (e) {
      print('❌ 获取收藏列表失败: $e');
      return [];
    }
  }

  /// 获取用户收藏的城市详情列表（带分页）
  Future<List<UserFavoriteCity>> getUserFavoriteCities({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        '${ApiConfig.apiBaseUrl}/user-favorite-cities',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );

      return (response.data['items'] as List<dynamic>)
          .map((json) => UserFavoriteCity.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ 获取收藏城市列表失败: $e');
      return [];
    }
  }
}
