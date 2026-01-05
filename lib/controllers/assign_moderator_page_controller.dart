import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/user_management/domain/repositories/iuser_management_repository.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignModeratorPageController extends GetxController {
  AssignModeratorPageController({required this.cityId, required this.cityName});

  final String cityId;
  final String cityName;

  late final IUserManagementRepository _userManagementRepository = Get.find<IUserManagementRepository>();
  late final ICityRepository _cityRepository = Get.find<ICityRepository>();

  final TextEditingController searchController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final RxList<Map<String, dynamic>> allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> filteredUsers = <Map<String, dynamic>>[].obs;
  final RxSet<String> selectedUserIds = <String>{}.obs;

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;

  final RxBool canEditCity = true.obs;
  final RxBool canManageCoworks = true.obs;
  final RxBool canManageCosts = true.obs;
  final RxBool canManageVisas = true.obs;
  final RxBool canModerateChats = true.obs;

  @override
  void onInit() {
    super.onInit();
    log('🎬 [AssignModerator] init - cityId: $cityId, cityName: $cityName');
    loadUsers();
    searchController.addListener(() => filterUsers(searchController.text));
  }

  @override
  void onClose() {
    searchController.dispose();
    notesController.dispose();
    super.onClose();
  }

  Future<void> loadUsers() async {
    log('📡 [AssignModerator] 加载版主候选人列表');
    isLoading.value = true;
    try {
      final result = await _userManagementRepository.getModeratorCandidates(page: 1, pageSize: 100);
      if (result.isSuccess) {
        final users = result.dataOrNull ?? [];
        allUsers.value = users
            .map((user) => {
                  'id': user.id,
                  'name': user.name,
                  'email': user.email,
                  'role': user.role,
                  'membershipLevel': user.membershipLevel,
                  'membershipLevelName': user.membershipLevelName,
                  'displayBadge': user.displayBadge,
                  'isAdmin': user.isAdmin,
                })
            .toList();
        filteredUsers.value = allUsers;
        log('📋 [AssignModerator] 加载成功，数量: ${allUsers.length}');
      } else {
        final errorMsg = result.exceptionOrNull?.message ?? '未知错误';
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.error('加载版主候选人失败: $errorMsg');
        });
      }
    } catch (e, stackTrace) {
      log('❌ [AssignModerator] 加载异常: $e');
      log('❌ [AssignModerator] Stack: $stackTrace');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppToast.error('加载版主候选人失败: $e');
      });
    } finally {
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    if (query.trim().isEmpty) {
      filteredUsers.value = allUsers;
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    filteredUsers.value = allUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();
  }

  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
  }

  void toggleSelectAll() {
    if (selectedUserIds.length == filteredUsers.length) {
      selectedUserIds.clear();
    } else {
      selectedUserIds
        ..clear()
        ..addAll(filteredUsers.map((u) => u['id'] as String));
    }
  }

  Future<void> submitAssignModerator() async {
    if (selectedUserIds.isEmpty) {
      AppToast.error('请至少选择一个用户');
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认指定版主'),
        content: Text(
          '确定要将 ${selectedUserIds.length} 个用户指定为版主吗？\n\n这些用户将自动获得版主角色和相应权限。',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cityPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isSubmitting.value = true;
    int successCount = 0;
    int failCount = 0;
    final List<String> errorMessages = [];

    try {
      for (final userId in selectedUserIds) {
        try {
          final result = await _cityRepository.assignModerator(cityId, userId);
          if (result.isSuccess) {
            successCount++;
          } else {
            final errorMsg = result.exceptionOrNull?.message ?? '未知错误';
            failCount++;
            errorMessages.add('用户 $userId: $errorMsg');
          }
        } catch (e) {
          failCount++;
          errorMessages.add('用户 $userId: $e');
        }
      }

      if (successCount > 0) {
        AppToast.success('成功指定 $successCount 个版主！');
        if (failCount > 0) {
          AppToast.warning('$failCount 个用户指定失败，请查看日志');
        }
        // 成功时延迟导航，避免 widget 生命周期问题
        Future.delayed(const Duration(milliseconds: 100), () {
          Get.back(result: true);
        });
      } else {
        AppToast.error('所有用户指定失败: ${errorMessages.isNotEmpty ? errorMessages.first : "请重试"}');
        isSubmitting.value = false;
      }
    } catch (e) {
      isSubmitting.value = false;
    }
  }

  Color getBadgeColor(String badge, bool isAdmin) {
    if (isAdmin) return Colors.red;
    switch (badge.toLowerCase()) {
      case 'premium':
        return Colors.purple;
      case 'pro':
        return Colors.orange;
      case 'basic':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
