import 'package:go_nomads_app/core/domain/result.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/features/interest/application/use_cases/interest_use_cases.dart';
import 'package:go_nomads_app/features/interest/domain/entities/interest.dart';

/// InterestStateController - 兴趣状态控制器
class InterestStateController extends GetxController {
  // Use Cases
  final GetInterestsUseCase _getInterestsUseCase;
  final GetInterestsByCategoryUseCase _getInterestsByCategoryUseCase;
  final GetUserInterestsUseCase _getUserInterestsUseCase;
  final AddUserInterestUseCase _addUserInterestUseCase;
  final UpdateUserInterestIntensityUseCase _updateUserInterestIntensityUseCase;
  final RemoveUserInterestUseCase _removeUserInterestUseCase;
  final SearchInterestsUseCase _searchInterestsUseCase;

  InterestStateController({
    required GetInterestsUseCase getInterestsUseCase,
    required GetInterestsByCategoryUseCase getInterestsByCategoryUseCase,
    required GetUserInterestsUseCase getUserInterestsUseCase,
    required AddUserInterestUseCase addUserInterestUseCase,
    required UpdateUserInterestIntensityUseCase
        updateUserInterestIntensityUseCase,
    required RemoveUserInterestUseCase removeUserInterestUseCase,
    required SearchInterestsUseCase searchInterestsUseCase,
  })  : _getInterestsUseCase = getInterestsUseCase,
        _getInterestsByCategoryUseCase = getInterestsByCategoryUseCase,
        _getUserInterestsUseCase = getUserInterestsUseCase,
        _addUserInterestUseCase = addUserInterestUseCase,
        _updateUserInterestIntensityUseCase =
            updateUserInterestIntensityUseCase,
        _removeUserInterestUseCase = removeUserInterestUseCase,
        _searchInterestsUseCase = searchInterestsUseCase;

  // Reactive State
  final interests = <Interest>[].obs;
  final userInterests = <UserInterest>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  /// 获取所有兴趣
  Future<void> getInterests() async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getInterestsUseCase();
    result.fold(
      onSuccess: (data) {
        interests.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 按类别获取兴趣
  Future<void> getInterestsByCategory(String category) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getInterestsByCategoryUseCase(
      GetInterestsByCategoryParams(category: category),
    );
    result.fold(
      onSuccess: (data) {
        interests.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 获取用户兴趣列表
  Future<void> getUserInterests(String userId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _getUserInterestsUseCase(
      GetUserInterestsParams(userId: userId),
    );
    result.fold(
      onSuccess: (data) {
        userInterests.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  /// 添加用户兴趣
  Future<bool> addUserInterest(
      String userId, AddUserInterestRequest request) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _addUserInterestUseCase(
      AddUserInterestParams(userId: userId, request: request),
    );

    return result.fold<bool>(
      onSuccess: (data) {
        userInterests.add(data);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 更新用户兴趣强度
  Future<bool> updateUserInterestIntensity(
    String userId,
    String interestId,
    String intensityLevel,
  ) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _updateUserInterestIntensityUseCase(
      UpdateUserInterestIntensityParams(
        userId: userId,
        interestId: interestId,
        intensityLevel: intensityLevel,
      ),
    );

    return result.fold<bool>(
      onSuccess: (data) {
        final index =
            userInterests.indexWhere((e) => e.interestId == interestId);
        if (index != -1) {
          userInterests[index] = data;
        }
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 删除用户兴趣
  Future<bool> removeUserInterest(String userId, String interestId) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _removeUserInterestUseCase(
      RemoveUserInterestParams(userId: userId, interestId: interestId),
    );

    return result.fold(
      onSuccess: (_) {
        userInterests.removeWhere((e) => e.interestId == interestId);
        isLoading.value = false;
        return true;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
        return false;
      },
    );
  }

  /// 搜索兴趣
  Future<void> searchInterests(String query) async {
    isLoading.value = true;
    errorMessage.value = null;

    final result = await _searchInterestsUseCase(
      SearchInterestsParams(query: query),
    );
    result.fold(
      onSuccess: (data) {
        interests.value = data;
        isLoading.value = false;
      },
      onFailure: (exception) {
        errorMessage.value = exception.message;
        isLoading.value = false;
      },
    );
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    interests.clear();
    userInterests.clear();
    isLoading.value = false;
    errorMessage.value = null;
    
    super.onClose();
  }
}
