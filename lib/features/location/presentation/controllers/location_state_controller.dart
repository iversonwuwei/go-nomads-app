import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart';
import 'package:df_admin_mobile/features/country/domain/entities/country_option.dart';
import 'package:get/get.dart';

import 'package:df_admin_mobile/features/location/application/use_cases/get_cities_by_country_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_city_by_id_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_countries_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/search_cities_use_case.dart';

/// Location State Controller
/// 管理国家和城市数据的状态
/// 替代原来的 DataServiceController 和 AddCoworkingController 的国家/城市功能
class LocationStateController extends GetxController {
  final GetCountriesUseCase _getCountriesUseCase;
  final GetCitiesByCountryUseCase _getCitiesByCountryUseCase;
  final GetCityByIdUseCase _getCityByIdUseCase;
  final SearchCitiesUseCase _searchCitiesUseCase;

  LocationStateController({
    required GetCountriesUseCase getCountriesUseCase,
    required GetCitiesByCountryUseCase getCitiesByCountryUseCase,
    required GetCityByIdUseCase getCityByIdUseCase,
    required SearchCitiesUseCase searchCitiesUseCase,
  })  : _getCountriesUseCase = getCountriesUseCase,
        _getCitiesByCountryUseCase = getCitiesByCountryUseCase,
        _getCityByIdUseCase = getCityByIdUseCase,
        _searchCitiesUseCase = searchCitiesUseCase;

  // === 状态管理 ===

  /// 国家列表
  final RxList<CountryOption> countries = <CountryOption>[].obs;

  /// 城市列表（按国家ID分组）
  final RxMap<String, List<CityOption>> citiesByCountry =
      <String, List<CityOption>>{}.obs;

  /// 搜索结果
  final RxList<CityOption> searchResults = <CityOption>[].obs;

  /// 加载状态
  final RxBool isLoadingCountries = false.obs;
  final RxBool isLoadingCities = false.obs;
  final RxBool isSearching = false.obs;

  /// 错误信息
  final RxString errorMessage = ''.obs;

  // === 业务方法 ===

  /// 加载国家列表
  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (isLoadingCountries.value) return;

    isLoadingCountries.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCountriesUseCase.execute(
        forceRefresh: forceRefresh,
      );

      result.fold(
        onSuccess: (loadedCountries) {
          countries.assignAll(loadedCountries);
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
        },
      );
    } catch (e) {
      errorMessage.value = '加载国家列表失败: $e';
    } finally {
      isLoadingCountries.value = false;
    }
  }

  /// 根据国家ID加载城市列表
  Future<List<CityOption>> loadCitiesByCountry(
    String countryId, {
    bool forceRefresh = false,
  }) async {
    // 防止重复加载
    if (!forceRefresh && citiesByCountry.containsKey(countryId)) {
      return citiesByCountry[countryId]!;
    }

    isLoadingCities.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCitiesByCountryUseCase.execute(
        GetCitiesByCountryParams(
          countryId: countryId,
          forceRefresh: forceRefresh,
        ),
      );

      return result.fold(
        onSuccess: (cities) {
          citiesByCountry[countryId] = cities;
          return cities;
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          return <CityOption>[];
        },
      );
    } catch (e) {
      errorMessage.value = '加载城市列表失败: $e';
      return <CityOption>[];
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// 搜索城市
  Future<void> searchCities({
    required String query,
    String? countryId,
  }) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    errorMessage.value = '';

    try {
      final result = await _searchCitiesUseCase.execute(
        SearchCitiesParams(
          query: query,
          countryId: countryId,
        ),
      );

      result.fold(
        onSuccess: (cities) {
          searchResults.assignAll(cities);
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          searchResults.clear();
        },
      );
    } catch (e) {
      errorMessage.value = '搜索城市失败: $e';
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// 清空搜索结果
  void clearSearch() {
    searchResults.clear();
  }

  /// 根据 ID 获取城市信息（包含 countryId）
  Future<Result<CityOption>> getCityById(String cityId) async {
    errorMessage.value = '';

    try {
      final result = await _getCityByIdUseCase.execute(
        GetCityByIdParams(cityId: cityId),
      );

      result.fold(
        onSuccess: (_) {},
        onFailure: (exception) {
          errorMessage.value = exception.message;
        },
      );

      return result;
    } catch (e) {
      errorMessage.value = '获取城市信息失败: $e';
      return Result.failure(
        Exception('获取城市信息失败: $e') as dynamic,
      );
    }
  }

  /// 根据国家ID获取国家名称
  String? getCountryName(String countryId) {
    final country = countries.firstWhereOrNull((c) => c.id == countryId);
    return country?.name;
  }

  /// 清空所有数据
  void clearAll() {
    countries.clear();
    citiesByCountry.clear();
    searchResults.clear();
    errorMessage.value = '';
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    countries.clear();
    citiesByCountry.clear();
    searchResults.clear();
    
    // 重置加载状态
    isLoadingCountries.value = false;
    isLoadingCities.value = false;
    isSearching.value = false;
    
    // 清空错误信息
    errorMessage.value = '';
    
    super.onClose();
  }
}
