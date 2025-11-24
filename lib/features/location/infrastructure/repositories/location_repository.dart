import 'package:get/get.dart';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart';
import 'package:df_admin_mobile/features/country/domain/entities/country_option.dart';
import 'package:df_admin_mobile/features/location/domain/repositories/ilocation_repository.dart';
import 'package:df_admin_mobile/features/location/infrastructure/models/city_dto.dart';
import 'package:df_admin_mobile/features/location/infrastructure/models/country_dto.dart';

/// Location Repository 实现
/// 使用 HttpService 直接访问城市数据 API
class LocationRepository implements ILocationRepository {
  final HttpService _httpService = Get.find();

  // 内存缓存
  List<CountryOption>? _countriesCache;
  final Map<String, List<CityOption>> _citiesByCountryCache = {};

  @override
  Future<Result<List<CountryOption>>> getCountries({
    bool forceRefresh = false,
  }) async {
    try {
      // 使用缓存
      if (!forceRefresh && _countriesCache != null) {
        return Result.success(_countriesCache!);
      }

      final response = await _httpService.get('/cities/countries');
      final dataList = response.data as List<dynamic>;
      final dtos = dataList
          .map((json) => CountryDto.fromJson(json as Map<String, dynamic>))
          .toList();
      
      final entities = dtos.map((dto) => dto.toDomain()).toList();
      _countriesCache = entities;

      return Result.success(entities);
    } on HttpException catch (e) {
      return Result.failure(_convertHttpException(e));
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get countries: ${e.toString()}',
          code: 'GET_COUNTRIES_ERROR',
        ),
      );
    }
  }

  @override
  Future<Result<List<CityOption>>> getCitiesByCountry({
    required String countryId,
    bool forceRefresh = false,
  }) async {
    try {
      // 使用缓存
      if (!forceRefresh && _citiesByCountryCache.containsKey(countryId)) {
        return Result.success(_citiesByCountryCache[countryId]!);
      }

      final response = await _httpService.get(
        '/cities',
        queryParameters: {
          'countryId': countryId,
          'page': 1,
          'pageSize': 1000, // 获取所有城市
        },
      );

      final items = (response.data as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
      final dtos = items
          .map((json) => CityDto.fromJson(json as Map<String, dynamic>))
          .toList();

      final entities = dtos.map((dto) => dto.toDomain()).toList();
      _citiesByCountryCache[countryId] = entities;

      return Result.success(entities);
    } on HttpException catch (e) {
      return Result.failure(_convertHttpException(e));
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get cities by country: ${e.toString()}',
          code: 'GET_CITIES_BY_COUNTRY_ERROR',
          details: {'countryId': countryId},
        ),
      );
    }
  }

  @override
  Future<Result<List<CityOption>>> searchCities({
    required String query,
    String? countryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'query': query,
        'page': 1,
        'pageSize': 50,
      };
      if (countryId != null) {
        queryParams['country'] = countryId;
      }

      final response = await _httpService.get(
        '/cities/search',
        queryParameters: queryParams,
      );

      final dataList = response.data as List<dynamic>;
      final dtos = dataList
          .map((json) => CityDto.fromJson(json as Map<String, dynamic>))
          .toList();

      final entities = dtos.map((dto) => dto.toDomain()).toList();

      return Result.success(entities);
    } on HttpException catch (e) {
      return Result.failure(_convertHttpException(e));
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to search cities: ${e.toString()}',
          code: 'SEARCH_CITIES_ERROR',
          details: {'query': query, 'countryId': countryId},
        ),
      );
    }
  }

  @override
  Future<Result<CountryOption>> getCountryById(String id) async {
    try {
      // 先尝试从缓存中查找
      if (_countriesCache != null) {
        final country = _countriesCache!.firstWhereOrNull((c) => c.id == id);
        if (country != null) {
          return Result.success(country);
        }
      }

      // 缓存中没有，重新加载
      final result = await getCountries(forceRefresh: true);
      return result.fold(
        onSuccess: (countries) {
          final country = countries.firstWhereOrNull((c) => c.id == id);
          if (country != null) {
            return Result.success(country);
          }
          return Result.failure(
            NotFoundException(
              'Country not found',
              code: 'COUNTRY_NOT_FOUND',
              details: {'id': id},
            ),
          );
        },
        onFailure: (exception) => Result.failure(exception),
      );
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get country by id: ${e.toString()}',
          code: 'GET_COUNTRY_ERROR',
          details: {'id': id},
        ),
      );
    }
  }

  @override
  Future<Result<CityOption>> getCityById(String id) async {
    try {
      final response = await _httpService.get('/cities/$id');
      final dto = CityDto.fromJson(response.data as Map<String, dynamic>);
      final entity = dto.toDomain();

      return Result.success(entity);
    } on HttpException catch (e) {
      return Result.failure(_convertHttpException(e));
    } catch (e) {
      return Result.failure(
        UnknownException(
          'Failed to get city by id: ${e.toString()}',
          code: 'GET_CITY_ERROR',
          details: {'id': id},
        ),
      );
    }
  }

  /// 清空缓存
  void clearCache() {
    _countriesCache = null;
    _citiesByCountryCache.clear();
  }

  /// 转换 HTTP 异常为领域异常
  DomainException _convertHttpException(HttpException e) {
    return switch (e.statusCode) {
      400 => ValidationException(e.message, code: 'VALIDATION_ERROR'),
      401 => UnauthorizedException(e.message),
      403 => UnauthorizedException(e.message), // 使用 UnauthorizedException 替代 ForbiddenException
      404 => NotFoundException(e.message, code: 'NOT_FOUND'),
      _ => UnknownException('HTTP错误: ${e.message}', code: 'HTTP_ERROR'),
    };
  }
}
