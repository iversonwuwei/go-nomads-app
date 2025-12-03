import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/coworking/application/use_cases/coworking_use_cases.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/verification_eligibility.dart';
import 'package:get/get.dart';

/// Coworking State Controller
/// 管理 Coworking 相关的 UI 状态
class CoworkingStateController extends GetxController {
  final GetCoworkingSpacesByCityUseCase _getCoworkingSpacesByCityUseCase;
  final GetCoworkingByIdUseCase _getCoworkingByIdUseCase;
  final GetCityCoworkingCountUseCase _getCityCoworkingCountUseCase;
  final SubmitCoworkingVerificationUseCase _submitCoworkingVerificationUseCase;
  final CheckVerificationEligibilityUseCase _checkVerificationEligibilityUseCase;

  CoworkingStateController({
    required GetCoworkingSpacesByCityUseCase getCoworkingSpacesByCityUseCase,
    required GetCoworkingByIdUseCase getCoworkingByIdUseCase,
    required GetCityCoworkingCountUseCase getCityCoworkingCountUseCase,
    required SubmitCoworkingVerificationUseCase
        submitCoworkingVerificationUseCase,
    required CheckVerificationEligibilityUseCase checkVerificationEligibilityUseCase,
  })  : _getCoworkingSpacesByCityUseCase = getCoworkingSpacesByCityUseCase,
        _getCoworkingByIdUseCase = getCoworkingByIdUseCase,
        _getCityCoworkingCountUseCase = getCityCoworkingCountUseCase,
        _submitCoworkingVerificationUseCase =
            submitCoworkingVerificationUseCase,
        _checkVerificationEligibilityUseCase = checkVerificationEligibilityUseCase;

  // === 状态管理 ===

  /// Coworking 空间列表
  final RxList<CoworkingSpace> coworkingSpaces = <CoworkingSpace>[].obs;

  /// 筛选后的空间列表
  final RxList<CoworkingSpace> filteredSpaces = <CoworkingSpace>[].obs;

  /// 选中的筛选条件
  final RxList<String> selectedFilters = <String>[].obs;

  /// 当前选中的 Coworking 空间
  final Rx<CoworkingSpace?> currentCoworking = Rx<CoworkingSpace?>(null);

  /// 加载状态
  final RxBool isLoadingSpaces = false.obs;
  final RxBool isLoadingDetail = false.obs;
  final RxBool isLoadingCount = false.obs;
  final RxBool isLoadingMore = false.obs; // 加载更多状态

  /// 加载状态简写 (用于兼容旧页面)
  RxBool get isLoading => isLoadingSpaces;

  /// 错误信息
  final RxString errorMessage = ''.obs;

  /// Coworking 数量
  final RxInt coworkingCount = 0.obs;

  // === 分页状态 ===
  final RxInt currentPage = 1.obs;
  final RxBool hasMore = true.obs;
  final int pageSize = 20;
  final RxString currentCityId = ''.obs;
  final RxSet<String> verifyingCoworkingIds = <String>{}.obs;

  // === 业务方法 ===

  /// 加载城市的 Coworking 空间列表
  Future<void> loadCoworkingSpacesByCity(
    String cityId, {
    bool refresh = false, // 是否刷新（重新加载第一页）
  }) async {
    // 防止重复加载
    if (isLoadingSpaces.value) {
      log('⏸️ Coworking加载中,跳过重复请求');
      return;
    }

    // 如果不是刷新模式,且已有该城市的数据,直接返回缓存
    if (!refresh &&
        currentCityId.value == cityId &&
        coworkingSpaces.isNotEmpty) {
      log('✅ 使用Coworking缓存数据,跳过请求');
      return;
    }

    // 立即设置加载中状态，防止并发请求
    isLoadingSpaces.value = true;

    // 如果是刷新，重置分页状态
    if (refresh) {
      currentPage.value = 1;
      hasMore.value = true;
      coworkingSpaces.clear();
      filteredSpaces.clear();
    }

    currentCityId.value = cityId;

    log('🏢 开始加载 Coworking 列表:');
    log('   城市ID: $cityId');
    log('   页码: ${currentPage.value}');
    log('   页大小: $pageSize');

    errorMessage.value = '';

    try {
      final result = await _getCoworkingSpacesByCityUseCase.execute(
        GetCoworkingSpacesByCityParams(
          cityId: cityId,
          page: currentPage.value,
          pageSize: pageSize,
        ),
      );

      result.fold(
        onSuccess: (spaces) {
          log('✅ 成功加载 ${spaces.length} 个 Coworking 空间');
          // 调试：检查 creatorName 字段
          for (var space in spaces) {
            log(
                '   空间: ${space.name}, CreatorName: ${space.creatorName ?? "NULL"}');
          }

          // 判断是否还有更多数据
          if (spaces.length < pageSize) {
            hasMore.value = false;
          }

          // 如果是第一页，替换数据；否则追加数据
          if (currentPage.value == 1) {
            coworkingSpaces.assignAll(spaces);
          } else {
            coworkingSpaces.addAll(spaces);
          }

          _applyFilters(); // 应用筛选
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
        },
      );
    } catch (e) {
      errorMessage.value = '加载失败: $e';
    } finally {
      isLoadingSpaces.value = false;
    }
  }

  /// 加载更多 Coworking 空间
  Future<void> loadMoreCoworkingSpaces() async {
    // 检查是否可以加载更多
    if (isLoadingMore.value || !hasMore.value || currentCityId.value.isEmpty) {
      return;
    }

    log('📄 加载更多 Coworking:');
    log('   当前页: ${currentPage.value}');
    log('   下一页: ${currentPage.value + 1}');

    isLoadingMore.value = true;

    try {
      currentPage.value++;

      final result = await _getCoworkingSpacesByCityUseCase.execute(
        GetCoworkingSpacesByCityParams(
          cityId: currentCityId.value,
          page: currentPage.value,
          pageSize: pageSize,
        ),
      );

      result.fold(
        onSuccess: (spaces) {
          log('✅ 加载更多成功: ${spaces.length} 个空间');

          // 判断是否还有更多数据
          if (spaces.length < pageSize) {
            hasMore.value = false;
            log('📭 没有更多数据了');
          }

          // 追加新数据
          coworkingSpaces.addAll(spaces);
          _applyFilters();
        },
        onFailure: (exception) {
          // 加载失败，页码回退
          currentPage.value--;
          errorMessage.value = exception.message;
          log('❌ 加载更多失败: ${exception.message}');
        },
      );
    } catch (e) {
      // 异常，页码回退
      currentPage.value--;
      errorMessage.value = '加载更多失败: $e';
      log('❌ 加载更多异常: $e');
    } finally {
      isLoadingMore.value = false;
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
          // log('✅ 成功加载 Coworking 详情: ${space.name}');
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
          // log('❌ 加载 Coworking 详情失败: ${exception.message}');
        },
      );
    } catch (e) {
      errorMessage.value = '加载详情失败: $e';
      // log('❌ 加载 Coworking 详情异常: $e');
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
          // log('✅ 城市 Coworking 数量: $count');
        },
        onFailure: (exception) {
          coworkingCount.value = 0;
          // log('❌ 获取 Coworking 数量失败: ${exception.message}');
        },
      );
    } catch (e) {
      coworkingCount.value = 0;
      // log('❌ 获取 Coworking 数量异常: $e');
    } finally {
      isLoadingCount.value = false;
    }
  }

  /// 刷新 Coworking 列表
  Future<void> refreshCoworkingSpaces(String cityId) async {
    coworkingSpaces.clear();
    await loadCoworkingSpacesByCity(cityId);
  }

  // === 筛选和排序功能 ===

  /// 兼容旧页面的方法名
  Future<void> loadCoworkingsByCity(
    String cityId, {
    String? cityName,
    bool refresh = false,
  }) async {
    await loadCoworkingSpacesByCity(cityId, refresh: refresh);
  }

  /// 切换筛选条件
  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
    _applyFilters();
  }

  /// 清空筛选条件
  void clearFilters() {
    selectedFilters.clear();
    _applyFilters();
  }

  /// 应用筛选条件
  void _applyFilters() {
    if (selectedFilters.isEmpty) {
      filteredSpaces.assignAll(coworkingSpaces);
    } else {
      filteredSpaces.assignAll(
        coworkingSpaces.where((space) {
          for (final filter in selectedFilters) {
            switch (filter) {
              case 'WiFi':
                if (!space.amenities.hasWifi) {
                  return false;
                }
                break;
              case '24/7':
                if (!space.amenities.has24HourAccess) {
                  return false;
                }
                break;
              case 'Meeting Rooms':
              case '会议室':
                if (!space.amenities.hasMeetingRoom) {
                  return false;
                }
                break;
              case 'Coffee':
                if (!space.amenities.hasCoffee) {
                  return false;
                }
                break;
              default:
                final amenities = space.amenities.getAvailableAmenities();
                if (!amenities.any(
                  (amenity) => amenity.toLowerCase() == filter.toLowerCase(),
                )) {
                  return false;
                }
            }
          }
          return true;
        }),
      );
    }
  }

  /// 按评分排序
  void sortByRating() {
    final list = List<CoworkingSpace>.from(filteredSpaces);
    list.sort((a, b) => b.spaceInfo.rating.compareTo(a.spaceInfo.rating));
    filteredSpaces.assignAll(list);
  }

  /// 按价格排序
  void sortByPrice() {
    final list = List<CoworkingSpace>.from(filteredSpaces);
    list.sort((a, b) {
      final aPrice = a.lowestPrice == 0 ? double.infinity : a.lowestPrice;
      final bPrice = b.lowestPrice == 0 ? double.infinity : b.lowestPrice;
      return aPrice.compareTo(bPrice);
    });
    filteredSpaces.assignAll(list);
  }

  /// 按距离排序 (暂时不实现,需要用户位置)
  void sortByDistance() {
    // TODO: 实现距离排序,需要获取用户当前位置
    // 暂时保持原顺序
  }

  /// 检查用户是否有资格验证指定的 Coworking 空间
  Future<Result<VerificationEligibility>> checkVerificationEligibility(String coworkingId) async {
    if (coworkingId.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    return _checkVerificationEligibilityUseCase.execute(
      CheckVerificationEligibilityParams(coworkingId: coworkingId),
    );
  }

  /// 提交 Coworking 认证
  Future<Result<CoworkingSpace>> submitVerification(String coworkingId) async {
    if (coworkingId.isEmpty) {
      return Result.failure(
        ValidationException('Coworking 空间ID不能为空', code: 'INVALID_ID'),
      );
    }

    if (verifyingCoworkingIds.contains(coworkingId)) {
      return Result.failure(
        ValidationException('正在提交认证，请稍候', code: 'VERIFYING'),
      );
    }

    verifyingCoworkingIds.add(coworkingId);
    errorMessage.value = '';

    try {
      final result = await _submitCoworkingVerificationUseCase.execute(
        SubmitCoworkingVerificationParams(coworkingId: coworkingId),
      );

      result.fold(
        onSuccess: (space) {
          _replaceCoworking(space);
        },
        onFailure: (exception) {
          errorMessage.value = exception.message;
        },
      );

      return result;
    } finally {
      verifyingCoworkingIds.remove(coworkingId);
    }
  }

  void _replaceCoworking(CoworkingSpace updated) {
    final listIndex = coworkingSpaces.indexWhere((s) => s.id == updated.id);
    if (listIndex != -1) {
      coworkingSpaces[listIndex] = updated;
    }

    final filteredIndex = filteredSpaces.indexWhere((s) => s.id == updated.id);
    if (filteredIndex != -1) {
      filteredSpaces[filteredIndex] = updated;
    }

    if (currentCoworking.value?.id == updated.id) {
      currentCoworking.value = updated;
    }

    _applyFilters();
  }

  /// 清空数据
  void clearCoworkingData() {
    coworkingSpaces.clear();
    filteredSpaces.clear();
    selectedFilters.clear();
    currentCoworking.value = null;
    coworkingCount.value = 0;
    errorMessage.value = '';
    verifyingCoworkingIds.clear();
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    coworkingSpaces.clear();
    filteredSpaces.clear();
    selectedFilters.clear();
    currentCoworking.value = null;
    coworkingCount.value = 0;
    errorMessage.value = '';

    // 重置加载状态
    isLoadingSpaces.value = false;
    isLoadingDetail.value = false;
    isLoadingCount.value = false;
    isLoadingMore.value = false;

    // 重置分页状态
    currentPage.value = 1;
    hasMore.value = true;
    currentCityId.value = '';
    verifyingCoworkingIds.clear();

    super.onClose();
  }
}
