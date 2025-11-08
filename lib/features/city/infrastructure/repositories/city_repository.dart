import '../../../../core/core.dart';
import '../../../../services/http_service.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/city_detail.dart';
import '../../domain/repositories/i_city_repository.dart';
import '../models/city_detail_dto.dart' hide ProsCons;

/// 城市仓储实现 (Infrastructure Layer)
///
/// 负责与后端 CityService API 交互,实现 ICityRepository 定义的所有数据访问方法
class CityRepository implements ICityRepository {
  final HttpService _httpService;
  final String _baseUrl = '/cities';

  CityRepository(this._httpService);

  @override
  String get repositoryName => 'CityRepository';

  /// 将 HttpException 转换为 DomainException
  DomainException _convertHttpException(HttpException e) {
    if (e.statusCode == null) {
      return NetworkException(e.message);
    }

    switch (e.statusCode!) {
      case 400:
        return ValidationException(e.message, details: e.errors);
      case 401:
      case 403:
        return UnauthorizedException(e.message);
      case 404:
        return NotFoundException(e.message);
      case >= 500:
        return ServerException(e.message);
      default:
        return NetworkException(e.message, code: e.statusCode.toString());
    }
  }

  @override
  Future<Result<List<City>>> getCities({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? countryId,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }

      if (countryId != null && countryId.isNotEmpty) {
        queryParameters['countryId'] = countryId;
      }

      final response = await _httpService.get(
        _baseUrl,
        queryParameters: queryParameters,
      );

      // API 返回格式: { items: [...], totalCount: 100 }
      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      final cities = items
          .map((json) => City.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取城市列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<City>> getCityById(String cityId) async {
    try {
      final response = await _httpService.get('$_baseUrl/$cityId');
      final data = response.data as Map<String, dynamic>;
      final city = City.fromJson(data);
      return Success(city);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取城市详情失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<City>>> searchCities({
    required String name,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/search',
        queryParameters: {
          'name': name,
          'page': pageNumber,
          'pageSize': pageSize,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      final cities = items
          .map((json) => City.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('搜索城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<City>>> getPopularCities({int limit = 10}) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/popular',
        queryParameters: {'limit': limit},
      );

      final items = response.data as List<dynamic>;
      final cities = items
          .map((json) => City.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取热门城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<City>>> getRecommendedCities({
    String? countryId,
    int limit = 10,
  }) async {
    try {
      final queryParameters = <String, dynamic>{'count': limit};

      if (countryId != null && countryId.isNotEmpty) {
        queryParameters['countryId'] = countryId;
      }

      final response = await _httpService.get(
        '$_baseUrl/recommended',
        queryParameters: queryParameters,
      );

      final items = response.data as List<dynamic>;
      final cities = items
          .map((json) => City.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取推荐城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> favoriteCity(String cityId) async {
    try {
      await _httpService.post('$_baseUrl/$cityId/favorite');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('收藏城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> unfavoriteCity(String cityId) async {
    try {
      await _httpService.delete('$_baseUrl/$cityId/favorite');
      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('取消收藏失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<bool>> isCityFavorited(String cityId) async {
    try {
      final response = await _httpService.get('$_baseUrl/$cityId/is-favorited');
      final isFavorited = response.data as bool? ?? false;
      return Success(isFavorited);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('检查收藏状态失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<City>>> getFavoriteCities() async {
    try {
      final response = await _httpService.get('$_baseUrl/favorites');

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List<dynamic>? ?? [];

      final cities = items
          .map((json) => City.fromJson(json as Map<String, dynamic>))
          .toList();

      return Success(cities);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取收藏城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<String>>> getUserFavoriteCityIds() async {
    try {
      final response = await _httpService.get('$_baseUrl/favorite-ids');

      final ids = (response.data as List<dynamic>?)
              ?.map((id) => id.toString())
              .toList() ??
          [];

      return Success(ids);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取收藏城市ID列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<ProsCons>>> getCityProsCons({
    required String cityId,
    bool? isPro,
  }) async {
    try {
      final endpoint = '$_baseUrl/$cityId/user-content/pros-cons';
      final queryParams = <String, dynamic>{};

      if (isPro != null) {
        queryParams['isPro'] = isPro;
      }

      final response = await _httpService.get(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      // 处理两种可能的响应格式
      List<dynamic> items;

      if (response.data is List) {
        // 直接返回数组格式: [...]
        items = response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        // 标准包装格式: {success: true, data: [...]}
        final data = response.data as Map<String, dynamic>;
        items = data['data'] as List<dynamic>? ?? [];
      } else {
        items = [];
      }

      final prosConsList = items
          .map((item) =>
              ProsConsDto.fromJson(item as Map<String, dynamic>).toEntity())
          .toList();

      return Success(prosConsList);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取城市优缺点失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<ProsCons>> addProsCons({
    required String cityId,
    required String text,
    required bool isPro,
  }) async {
    try {
      final endpoint = '$_baseUrl/$cityId/user-content/pros-cons';
      final requestData = {
        'text': text.trim(),
        'isPro': isPro,
      };

      final response = await _httpService.post(
        endpoint,
        data: requestData,
      );

      // 处理响应
      Map<String, dynamic> itemData;

      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        // 标准包装格式: {success: true, data: {...}}
        if (data.containsKey('data')) {
          itemData = data['data'] as Map<String, dynamic>;
        } else {
          // 直接返回对象格式
          itemData = data;
        }
      } else {
        return Failure(ValidationException('添加优缺点失败: 响应格式错误'));
      }

      final prosCons = ProsConsDto.fromJson(itemData).toEntity();
      return Success(prosCons);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('添加优缺点失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void>> voteProsCons({
    required String id,
    required bool isUpvote,
  }) async {
    try {
      final endpoint = '/user-content/pros-cons/$id/vote';
      final requestData = {
        'isUpvote': isUpvote,
      };

      await _httpService.post(
        endpoint,
        data: requestData,
      );

      return const Success(null);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('投票失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getCountries() async {
    try {
      final response = await _httpService.get('$_baseUrl/countries');
      final countries = (response.data as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();
      return Success(countries);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取国家列表失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCitiesGroupedByCountry() async {
    try {
      final response = await _httpService.get('$_baseUrl/grouped-by-country');
      return Success(response.data as Map<String, dynamic>);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取分组城市失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getCitiesWithCoworkingCount({
    int page = 1,
    int pageSize = 100,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      final response = await _httpService.get(
        '/cities/with-coworking-count',
        queryParameters: queryParameters,
      );

      return Success(response.data as Map<String, dynamic>);
    } on HttpException catch (e) {
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(
          UnknownException('获取城市列表(含Coworking数量)失败: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
  }) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/$cityId/weather',
        queryParameters: {
          if (includeForecast) 'includeForecast': includeForecast,
          if (includeForecast) 'days': days,
        },
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return Success(data);
      }
      if (data is Map) {
        return Success(Map<String, dynamic>.from(data));
      }
      return const Success(null);
    } on HttpException catch (e) {
      if (e.statusCode == 404) {
        return const Success(null);
      }
      return Failure(_convertHttpException(e));
    } catch (e) {
      return Failure(UnknownException('获取城市天气失败: ${e.toString()}'));
    }
  }
}
