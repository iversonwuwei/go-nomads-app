import '../../../../core/domain/result.dart';
import '../entities/city.dart';
import '../entities/country.dart';

/// Location Repository 接口
/// 管理国家和城市数据的仓储接口
abstract class ILocationRepository {
  /// 获取所有国家列表
  ///
  /// [forceRefresh] 是否强制刷新缓存
  Future<Result<List<CountryOption>>> getCountries({
    bool forceRefresh = false,
  });

  /// 根据国家ID获取城市列表
  ///
  /// [countryId] 国家ID
  /// [forceRefresh] 是否强制刷新缓存
  Future<Result<List<CityOption>>> getCitiesByCountry({
    required String countryId,
    bool forceRefresh = false,
  });

  /// 搜索城市
  ///
  /// [query] 搜索关键词
  /// [countryId] 可选的国家ID过滤
  Future<Result<List<CityOption>>> searchCities({
    required String query,
    String? countryId,
  });

  /// 根据ID获取国家详情
  Future<Result<CountryOption>> getCountryById(String id);

  /// 根据ID获取城市详情
  Future<Result<CityOption>> getCityById(String id);
}
