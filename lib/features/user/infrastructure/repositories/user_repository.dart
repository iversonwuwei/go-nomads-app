import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/core/core.dart';
import 'package:go_nomads_app/features/user/domain/entities/nomad_stats.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/features/user/domain/repositories/iuser_repository.dart';
import 'package:go_nomads_app/features/user/infrastructure/models/user_dto.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';

/// 用户仓储实现
class UserRepository extends BaseRepository implements IUserRepository {
  final Dio _dio;
  final TokenStorageService _tokenService;

  UserRepository({
    required Dio dio,
    required TokenStorageService tokenService,
  })  : _dio = dio,
        _tokenService = tokenService;

  @override
  String get repositoryName => 'UserRepository';

  @override
  Future<Result<List<User>>> batchGetUsers(List<String> userIds) async {
    if (userIds.isEmpty) {
      return const Success([]);
    }

    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.post(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.userBatchEndpoint}',
        data: {'userIds': userIds},
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> usersData = response.data['data'];
        final users = usersData
            .map((json) => UserDto.fromJson(json as Map<String, dynamic>))
            .map((dto) => dto.toDomain())
            .toList();
        return users;
      }

      throw ServerException('批量获取用户失败', code: 'BATCH_GET_USERS_FAILED');
    });
  }

  @override
  Future<Result<User>> getUser(String userId) async {
    return execute(() async {
      final endpoint = ApiConfig.userDetailEndpoint.replaceAll('{id}', userId);
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final userDto = UserDto.fromJson(response.data['data'] as Map<String, dynamic>);
        return userDto.toDomain();
      }

      throw NotFoundException('用户未找到', code: 'USER_NOT_FOUND');
    });
  }

  @override
  Future<Result<User>> getCurrentUser() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.userMeEndpoint}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        // 调试日志：检查后端返回的 latestTravelHistory
        final data = response.data['data'] as Map<String, dynamic>;
        log('🔍 getCurrentUser - latestTravelHistory: ${data['latestTravelHistory']}');

        final userDto = UserDto.fromJson(data);
        final user = userDto.toDomain();
        log('🔍 getCurrentUser - User.latestTravelHistory: ${user.latestTravelHistory?.city ?? "null"}');
        return user;
      }

      throw ServerException('获取当前用户失败', code: 'GET_CURRENT_USER_FAILED');
    });
  }

  @override
  Future<Result<User>> updateUser(String userId, Map<String, dynamic> updates) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final endpoint = ApiConfig.userUpdateEndpoint.replaceAll('{id}', userId);
      final response = await _dio.put(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        data: updates,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final userDto = UserDto.fromJson(response.data['data'] as Map<String, dynamic>);
        return userDto.toDomain();
      }

      throw ServerException('更新用户失败', code: 'UPDATE_USER_FAILED');
    });
  }

  @override
  Future<Result<List<User>>> searchUsers({
    required String query,
    int page = 1,
    int pageSize = 20,
  }) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.usersEndpoint}',
        queryParameters: {
          'q': query,
          'page': page,
          'pageSize': pageSize,
        },
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final List<dynamic> usersData = response.data['data'];
        final users = usersData
            .map((json) => UserDto.fromJson(json as Map<String, dynamic>))
            .map((dto) => dto.toDomain())
            .toList();
        return users;
      }

      throw ServerException('搜索用户失败', code: 'SEARCH_USERS_FAILED');
    });
  }

  // ==================== 收藏城市相关方法 ====================

  @override
  Future<Result<bool>> isCityFavorited(String cityId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}/user-favorite-cities/check/$cityId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data['isFavorited'] as bool? ?? false;
    });
  }

  @override
  Future<Result<bool>> addFavoriteCity(String cityId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      try {
        await _dio.post(
          '${ApiConfig.currentApiBaseUrl}/user-favorite-cities',
          data: {'cityId': cityId},
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ),
        );
        return true;
      } on DioException catch (e) {
        if (e.response?.statusCode == 409) {
          // 城市已在收藏列表中
          return true;
        }
        rethrow;
      }
    });
  }

  @override
  Future<Result<bool>> removeFavoriteCity(String cityId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      // 使用 POST 方法代替 DELETE，兼容某些不支持 DELETE 方法的网络环境
      await _dio.post(
        '${ApiConfig.currentApiBaseUrl}/user-favorite-cities/$cityId/remove',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return true;
    });
  }

  @override
  Future<Result<bool>> toggleFavoriteCity(String cityId) async {
    // 先检查状态,再切换
    final isFavoritedResult = await isCityFavorited(cityId);

    return isFavoritedResult.fold(
      onSuccess: (isFavorited) async {
        if (isFavorited) {
          return await removeFavoriteCity(cityId);
        } else {
          return await addFavoriteCity(cityId);
        }
      },
      onFailure: (exception) {
        return Failure(exception);
      },
    );
  }

  @override
  Future<Result<List<String>>> getUserFavoriteCityIds() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}/user-favorite-cities/ids',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return (response.data as List<dynamic>).map((id) => id as String).toList();
    });
  }

  // ==================== 用户统计数据相关方法 ====================

  @override
  Future<Result<NomadStats>> getCurrentUserStats() async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.userMeStatsEndpoint}',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      log('📊 用户统计数据响应: ${response.data}');

      if (response.data['success'] == true && response.data['data'] != null) {
        final data = response.data['data'] as Map<String, dynamic>;
        log('📊 解析统计数据: meetupsCreated=${data['meetupsCreated']}, favoriteCitiesCount=${data['favoriteCitiesCount']}');
        return NomadStats.fromJson(data);
      }

      throw ServerException('获取用户统计数据失败', code: 'GET_USER_STATS_FAILED');
    });
  }

  @override
  Future<Result<NomadStats>> getUserStats(String userId) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      final endpoint = '${ApiConfig.usersEndpoint}/$userId/stats';
      final response = await _dio.get(
        '${ApiConfig.currentApiBaseUrl}$endpoint',
        options: Options(
          headers: {
            if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return NomadStats.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('获取用户统计数据失败', code: 'GET_USER_STATS_FAILED');
    });
  }

  @override
  Future<Result<NomadStats>> updateCurrentUserStats(NomadStats stats) async {
    return execute(() async {
      final token = await _tokenService.getAccessToken();

      if (token == null || token.isEmpty) {
        throw UnauthorizedException('未登录', code: 'NOT_AUTHENTICATED');
      }

      final response = await _dio.put(
        '${ApiConfig.currentApiBaseUrl}${ApiConfig.userMeStatsEndpoint}',
        data: {
          'countriesVisited': stats.countriesVisited,
          'citiesLived': stats.citiesLived,
          'daysNomading': stats.daysNomading,
          'tripsCompleted': stats.tripsCompleted,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return NomadStats.fromJson(response.data['data'] as Map<String, dynamic>);
      }

      throw ServerException('更新用户统计数据失败', code: 'UPDATE_USER_STATS_FAILED');
    });
  }
}
