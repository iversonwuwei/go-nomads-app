import 'package:get/get.dart';

import 'package:df_admin_mobile/core/core.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/features/city/application/use_cases/city_use_cases.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city.dart';

/// ?????????? (Presentation Layer)
///
/// ?????????? UI ??,?? Use Cases ??
///
/// ??: ??????? City ????????
/// Weather, UserCityContent, Coworking ?????????????/?????
class CityDetailStateController extends GetxController {
  // ==================== Dependencies ====================
  final GetCityByIdUseCase _getCityByIdUseCase;
  final ToggleCityFavoriteUseCase _toggleCityFavoriteUseCase;

  CityDetailStateController({
    required GetCityByIdUseCase getCityByIdUseCase,
    required ToggleCityFavoriteUseCase toggleCityFavoriteUseCase,
  })  : _getCityByIdUseCase = getCityByIdUseCase,
        _toggleCityFavoriteUseCase = toggleCityFavoriteUseCase;

  // ==================== State ====================

  // ????
  final Rx<City?> currentCity = Rx<City?>(null);

  // ????
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // ????
  final RxBool isFavorited = false.obs;
  final RxBool isTogglingFavorite = false.obs;

  // Tab ??
  final RxInt currentTabIndex = 0.obs;

  // ????????????ID,??????
  String _lastLoadedCityId = '';

  // ==================== Public Methods ====================

  /// ??????? (? cityId ?????)
  Future<void> initCity(String cityId, String cityName) async {
    // ????ID??,?????
    if (cityId == _lastLoadedCityId && currentCity.value != null) {
      // print('?? ??ID???,??????: $cityId');
      return;
    }

    // print('??? ?????: $cityName ($cityId)');
    _lastLoadedCityId = cityId;

    // ??????
    await loadCityDetail(cityId);
  }

  /// ??????
  Future<void> loadCityDetail(String cityId) async {
    if (cityId.isEmpty) {
      // print('?? ??ID??');
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;

    // print('?? ??????: $cityId');

    final result = await _getCityByIdUseCase.execute(
      GetCityByIdParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (city) {
        // print('? ????????: ${city.nameEn}');
        currentCity.value = city;
        isFavorited.value = city.isFavorite;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('? ????????: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '????');
      },
    );
  }

  /// ??????
  Future<void> toggleFavorite() async {
    if (currentCity.value == null) {
      // print('?? ??????,????????');
      return;
    }

    final cityId = currentCity.value!.id;

    if (isTogglingFavorite.value) {
      // print('?? ?????????,???');
      return;
    }

    isTogglingFavorite.value = true;
    final previousState = isFavorited.value;

    // ???? UI
    isFavorited.value = !previousState;

    // print('?? ??????: $cityId, ????: ${isFavorited.value}');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (newState) {
        // print('? ???????: $newState');
        isFavorited.value = newState;

        // ?? currentCity ?????
        if (currentCity.value != null) {
          currentCity.value = currentCity.value!.copyWith(isFavorite: newState);
        }

        AppToast.success(
          newState ? '??????' : '?????',
          title: '??',
        );
        isTogglingFavorite.value = false;
      },
      onFailure: (exception) {
        // print('? ??????: ${exception.message}');

        // ????,???????
        isFavorited.value = previousState;

        AppToast.error(exception.message, title: '????');
        isTogglingFavorite.value = false;
      },
    );
  }

  /// ?? Tab
  void changeTab(int index) {
    currentTabIndex.value = index;
    // print('?? ??? Tab: $index');
  }

  /// ????????
  Future<void> reload() async {
    if (currentCity.value != null) {
      await loadCityDetail(currentCity.value!.id);
    }
  }

  // ==================== Computed Properties ====================

  /// ????ID
  String get currentCityId => currentCity.value?.id ?? '';

  /// ??????
  String get currentCityName => currentCity.value?.nameEn ?? '';

  /// ???????
  bool get hasCity => currentCity.value != null;

  /// ??????
  bool get loading => isLoading.value;

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // print('??? CityDetailStateController ??? - ??????');
    
    // ?????????
    currentCity.value = null;
    isLoading.value = false;
    hasError.value = false;
    errorMessage.value = null;
    isFavorited.value = false;
    isTogglingFavorite.value = false;
    currentTabIndex.value = 0;
    
    // ??????
    _lastLoadedCityId = '';
    
    super.onClose();
  }
}
