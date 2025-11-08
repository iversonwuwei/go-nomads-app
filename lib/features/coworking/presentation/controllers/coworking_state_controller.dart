import 'package:get/get.dart';

import '../../../../core/domain/result.dart';
import '../../application/use_cases/coworking_use_cases.dart';
import '../../domain/entities/coworking_space.dart';

/// Coworking State Controller
/// 管理 Coworking 相关的 UI 状态
class CoworkingStateController extends GetxController {
  final GetCoworkingSpacesByCityUseCase _getCoworkingSpacesByCityUseCase;
  final GetCoworkingByIdUseCase _getCoworkingByIdUseCase;
  final GetCityCoworkingCountUseCase _getCityCoworkingCountUseCase;

  CoworkingStateController({
    required GetCoworkingSpacesByCityUseCase getCoworkingSpacesByCityUseCase,
    required GetCoworkingByIdUseCase getCoworkingByIdUseCase,
    required GetCityCoworkingCountUseCase getCityCoworkingCountUseCase,
  })  : _getCoworkingSpacesByCityUseCase = getCoworkingSpacesByCityUseCase,
        _getCoworkingByIdUseCase = getCoworkingByIdUseCase,
        _getCityCoworkingCountUseCase = getCityCoworkingCountUseCase;

  // === 状态管理 ===

  /// Coworking 空间列表
  final RxList<CoworkingSpace> coworkingSpaces = <CoworkingSpace>[].obs;

  /// 当前选中的 Coworking 空间
  final Rx<CoworkingSpace?> currentCoworking = Rx<CoworkingSpace?>(null);

  /// 加载状态
  final RxBool isLoadingSpaces = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isLoadingCount = false.obs;

  /// 错误信息
  final RxString errorMessage = ''.obs;

  /// Coworking 数量
  final RxInt coworkingCount = 0.obs;

  // === 业务方法 ===

  /// 加载城市的 Coworking 空间列表
  Future<void> loadCoworkingSpacesByCity(
    String cityId, {
    int page = 1,
    int pageSize = 100,
  }) async {
    // 防止重复加载
    if (isLoadingSpaces.value) {
      return;
    }

    isLoadingSpaces.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCoworkingSpacesByCityUseCase.execute(
        GetCoworkingSpacesByCityParams(
          cityId: cityId,
          page: page,
          pageSize: pageSize,
        ),
      );

      result.fold(
        onSuccess: (spaces) {
          coworkingSpaces.value = spaces;
          // print('✅ 成功加载 ${spaces.length} 个 Coworking 空间');
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          // print('❌ 加载 Coworking 列表失败: ${exception.message}');
        },
      );
    } catch (e) {
      errorMessage.value = '加载失败: $e';
      // print('❌ 加载 Coworking 列表异常: $e');
    } finally {
      isLoadingSpaces.value = false;
    }
  }

  /// 加载 Coworking 空间详情
  Future<void> loadCoworkingDetail(String id) async {
    if (isLoadingDetail.value) {
      return;
    }

    isLoadingDetail.value = true;
    errorMessage.value = '';

    try {
      final result = await _getCoworkingByIdUseCase.execute(
        GetCoworkingByIdParams(id: id),
      );

      result.fold(
        onSuccess: (space) {
          currentCoworking.value = space;
          // print('✅ 成功加载 Coworking 详情: ${space.name}');
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          // print('❌ 加载 Coworking 详情失败: ${exception.message}');
        },
      );
    } catch (e) {
      errorMessage.value = '加载详情失败: $e';
      // print('❌ 加载 Coworking 详情异常: $e');
    } finally {
      isLoadingDetail.value = false;
    }
  }

  /// 加载城市的 Coworking 数量
  Future<void> loadCityCoworkingCount(String cityId) async {
    if (isLoadingCount.value) {
      return;
    }

    isLoadingCount.value = true;

    try {
      final result = await _getCityCoworkingCountUseCase.execute(
        GetCityCoworkingCountParams(cityId: cityId),
      );

      result.fold(
        onSuccess: (count) {
          coworkingCount.value = count;
          // print('✅ 城市 Coworking 数量: $count');
        },
        onFailure: (exception) {
          coworkingCount.value = 0;
          // print('❌ 获取 Coworking 数量失败: ${exception.message}');
        },
      );
    } catch (e) {
      coworkingCount.value = 0;
      // print('❌ 获取 Coworking 数量异常: $e');
    } finally {
      isLoadingCount.value = false;
    }
  }

  /// 刷新 Coworking 列表
  Future<void> refreshCoworkingSpaces(String cityId) async {
    coworkingSpaces.clear();
    await loadCoworkingSpacesByCity(cityId);
  }

  /// 清空数据
  void clearCoworkingData() {
    coworkingSpaces.clear();
    currentCoworking.value = null;
    coworkingCount.value = 0;
    errorMessage.value = '';
  }

  @override
  void onClose() {
    clearCoworkingData();
    super.onClose();
  }
}
