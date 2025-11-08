import 'package:get/get.dart';

import '../../../../core/core.dart';
import '../../../../widgets/app_toast.dart';
import '../../application/use_cases/city_use_cases.dart';
import '../../domain/entities/city.dart';

/// 城市详情页状态控制器 (Presentation Layer)
///
/// 负责管理城市详情页的 UI 状态,协调 Use Cases 执行
///
/// 注意: 此控制器专注于 City 域相关的状态管理
/// Weather, UserCityContent, Coworking 等其他域的功能由各自的服务/控制器处理
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

  // 当前城市
  final Rx<City?> currentCity = Rx<City?>(null);

  // 加载状态
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<String?> errorMessage = Rx<String?>(null);

  // 收藏状态
  final RxBool isFavorited = false.obs;
  final RxBool isTogglingFavorite = false.obs;

  // Tab 状态
  final RxInt currentTabIndex = 0.obs;

  // 用于跟踪上一次加载的城市ID,防止重复加载
  String _lastLoadedCityId = '';

  // ==================== Public Methods ====================

  /// 初始化城市数据 (当 cityId 改变时调用)
  Future<void> initCity(String cityId, String cityName) async {
    // 如果城市ID相同,不重复加载
    if (cityId == _lastLoadedCityId && currentCity.value != null) {
      // print('ℹ️ 城市ID未变化,跳过重复加载: $cityId');
      return;
    }

    // print('🏙️ 初始化城市: $cityName ($cityId)');
    _lastLoadedCityId = cityId;

    // 加载城市详情
    await loadCityDetail(cityId);
  }

  /// 加载城市详情
  Future<void> loadCityDetail(String cityId) async {
    if (cityId.isEmpty) {
      // print('⚠️ 城市ID为空');
      return;
    }

    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = null;

    // print('📡 加载城市详情: $cityId');

    final result = await _getCityByIdUseCase.execute(
      GetCityByIdParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (city) {
        // print('✅ 成功加载城市详情: ${city.nameEn}');
        currentCity.value = city;
        isFavorited.value = city.isFavorite;
        isLoading.value = false;
      },
      onFailure: (exception) {
        // print('❌ 加载城市详情失败: ${exception.message}');
        hasError.value = true;
        errorMessage.value = exception.message;
        isLoading.value = false;
        AppToast.error(exception.message, title: '加载失败');
      },
    );
  }

  /// 切换收藏状态
  Future<void> toggleFavorite() async {
    if (currentCity.value == null) {
      // print('⚠️ 当前城市为空,无法切换收藏状态');
      return;
    }

    final cityId = currentCity.value!.id;

    if (isTogglingFavorite.value) {
      // print('⚠️ 正在切换收藏状态中,请稍候');
      return;
    }

    isTogglingFavorite.value = true;
    final previousState = isFavorited.value;

    // 乐观更新 UI
    isFavorited.value = !previousState;

    // print('💖 切换收藏状态: $cityId, 当前状态: ${isFavorited.value}');

    final result = await _toggleCityFavoriteUseCase.execute(
      ToggleCityFavoriteParams(cityId: cityId),
    );

    result.fold(
      onSuccess: (newState) {
        // print('✅ 收藏状态已更新: $newState');
        isFavorited.value = newState;

        // 更新 currentCity 的收藏状态
        if (currentCity.value != null) {
          currentCity.value = currentCity.value!.copyWith(isFavorite: newState);
        }

        AppToast.success(
          newState ? '已添加到收藏' : '已取消收藏',
          title: '成功',
        );
        isTogglingFavorite.value = false;
      },
      onFailure: (exception) {
        // print('❌ 收藏操作失败: ${exception.message}');

        // 操作失败,恢复之前的状态
        isFavorited.value = previousState;

        AppToast.error(exception.message, title: '操作失败');
        isTogglingFavorite.value = false;
      },
    );
  }

  /// 切换 Tab
  void changeTab(int index) {
    currentTabIndex.value = index;
    // print('📑 切换到 Tab: $index');
  }

  /// 重新加载当前城市
  Future<void> reload() async {
    if (currentCity.value != null) {
      await loadCityDetail(currentCity.value!.id);
    }
  }

  // ==================== Computed Properties ====================

  /// 当前城市ID
  String get currentCityId => currentCity.value?.id ?? '';

  /// 当前城市名称
  String get currentCityName => currentCity.value?.nameEn ?? '';

  /// 是否有城市数据
  bool get hasCity => currentCity.value != null;

  /// 是否正在加载
  bool get loading => isLoading.value;

  // ==================== Lifecycle ====================

  @override
  void onClose() {
    // print('🗑️ CityDetailStateController 被销毁');
    super.onClose();
  }
}
