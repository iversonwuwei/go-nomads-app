import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../widgets/app_toast.dart';
import '../../application/use_cases/get_city_weather_use_case.dart';
import '../../domain/entities/weather.dart';

/// Weather State Controller (Presentation Layer)
///
/// 负责管理天气数据的 UI 状态
class WeatherStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCityWeatherUseCase _getCityWeatherUseCase;

  WeatherStateController({
    required GetCityWeatherUseCase getCityWeatherUseCase,
  }) : _getCityWeatherUseCase = getCityWeatherUseCase;

  // ==================== State ====================

  // 天气数据
  final Rx<Weather?> weather = Rx<Weather?>(null);

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 用于跟踪上一次加载的城市ID,防止重复加载
  String _lastLoadedCityId = '';

  // ==================== Public Methods ====================

  /// 加载城市天气数据
  Future<void> loadCityWeather(
    String cityId, {
    bool includeForecast = true,
    int days = 7,
    bool forceRefresh = false,
  }) async {
    // 如果城市ID相同且数据存在,且不需要强制刷新,跳过加载
    if (!forceRefresh &&
        cityId == _lastLoadedCityId &&
        weather.value != null &&
        !(weather.value!.needsUpdate())) {
      return;
    }

    _lastLoadedCityId = cityId;
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;

    final result = await _getCityWeatherUseCase.execute(
      GetCityWeatherParams(
        cityId: cityId,
        includeForecast: includeForecast,
        days: days,
      ),
    );

    result.fold(
      onSuccess: (weatherData) {
        weather.value = weatherData;
        isLoading.value = false;
      },
      onFailure: (exception) {
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '加载天气失败');
      },
    );
  }

  /// 刷新天气数据
  Future<void> refreshWeather({
    bool includeForecast = true,
    int days = 7,
  }) async {
    if (_lastLoadedCityId.isEmpty) {
      return;
    }

    await loadCityWeather(
      _lastLoadedCityId,
      includeForecast: includeForecast,
      days: days,
      forceRefresh: true,
    );
  }

  /// 清空天气数据
  void clearWeather() {
    weather.value = null;
    _lastLoadedCityId = '';
    hasError.value = false;
    errorMessage.value = null;
  }
}
