import 'package:get/get.dart';

import '../models/city_option.dart';
import '../models/country_option.dart';
import '../services/location_api_service.dart';

/// Add Coworking Controller
/// 管理添加共享办公空间页面的状态和逻辑
class AddCoworkingController extends GetxController {
  final LocationApiService _locationApiService = LocationApiService();

  // 国家列表
  final RxList<CountryOption> countries = <CountryOption>[].obs;
  final RxBool isLoadingCountries = false.obs;

  // 城市列表（按国家ID分组缓存）
  final RxMap<String, List<CityOption>> citiesByCountry =
      <String, List<CityOption>>{}.obs;
  final RxBool isLoadingCities = false.obs;

  // 选中的国家和城市
  final Rx<CountryOption?> selectedCountry = Rx<CountryOption?>(null);
  final Rx<CityOption?> selectedCity = Rx<CityOption?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCountries();
  }

  /// 加载国家列表
  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (isLoadingCountries.value) {
      return;
    }

    if (countries.isNotEmpty && !forceRefresh) {
      return;
    }

    try {
      isLoadingCountries.value = true;
      print('📡 加载国家列表...');

      final countryList = await _locationApiService.fetchCountries();

      countries.clear();
      countries.addAll(countryList);

      print('✅ 国家列表加载成功: ${countries.length} 个国家');
    } catch (e) {
      print('❌ 加载国家列表失败: $e');
      countries.clear();
    } finally {
      isLoadingCountries.value = false;
    }
  }

  /// 根据国家ID加载城市列表
  Future<List<CityOption>> loadCitiesByCountry(String countryId,
      {bool forceRefresh = false}) async {
    // 检查缓存
    if (citiesByCountry.containsKey(countryId) && !forceRefresh) {
      print('📦 从缓存加载城市列表 (国家ID: $countryId)');
      return citiesByCountry[countryId]!;
    }

    try {
      isLoadingCities.value = true;
      print('📡 加载城市列表 (国家ID: $countryId)...');

      final cityList = await _locationApiService.fetchCitiesByCountry(countryId);

      // 缓存结果
      citiesByCountry[countryId] = cityList;

      print('✅ 城市列表加载成功: ${cityList.length} 个城市');
      return cityList;
    } catch (e) {
      print('❌ 加载城市列表失败: $e');
      return [];
    } finally {
      isLoadingCities.value = false;
    }
  }

  /// 设置选中的国家
  void setSelectedCountry(CountryOption? country) {
    selectedCountry.value = country;
    // 清除之前选中的城市
    selectedCity.value = null;

    // 加载该国家的城市列表
    if (country != null) {
      loadCitiesByCountry(country.id);
    }
  }

  /// 设置选中的城市
  void setSelectedCity(CityOption? city) {
    selectedCity.value = city;
  }

  /// 获取当前选中国家的城市列表
  List<CityOption> get currentCities {
    if (selectedCountry.value == null) {
      return [];
    }
    return citiesByCountry[selectedCountry.value!.id] ?? [];
  }
}
