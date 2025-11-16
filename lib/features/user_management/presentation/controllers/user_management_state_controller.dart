import 'package:get/get.dart';

import '../../../../core/domain/result.dart';
import '../../domain/entities/simple_user.dart';
import '../../domain/repositories/iuser_management_repository.dart';

/// User Management State Controller
class UserManagementStateController extends GetxController {
  final IUserManagementRepository _repository;

  UserManagementStateController(this._repository);

  // State
  final RxList<SimpleUser> users = <SimpleUser>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<RoleInfo> roles = <RoleInfo>[].obs;
  
  // Pagination
  final RxInt currentPage = 1.obs;
  final RxInt pageSize = 20.obs;
  final RxBool hasMoreData = true.obs;

  // Selected users for batch operation
  final RxSet<String> selectedUserIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadRoles();
    loadUsers();
  }

  /// 加载角色列表
  Future<void> loadRoles() async {
    try {
      final result = await _repository.getAllRoles();

      if (result.isSuccess) {
        roles.value = result.dataOrNull ?? [];
      } else {
        // 静默处理角色加载失败，不影响用户列表显示
        roles.value = [];
        print('⚠️ 角色列表加载失败: ${result.exceptionOrNull?.message}');
      }
    } catch (e) {
      // 静默处理异常，不影响用户列表显示
      roles.value = [];
      print('⚠️ 角色列表加载异常: $e');
    }
  }

  /// 加载用户列表
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      currentPage.value = 1;
      users.clear();
      hasMoreData.value = true;
    }

    if (!hasMoreData.value || isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.getUsers(
        page: currentPage.value,
        pageSize: pageSize.value,
      );

      if (result.isSuccess) {
        final newUsers = result.dataOrNull ?? [];
        
        if (refresh) {
          users.value = newUsers;
        } else {
          users.addAll(newUsers);
        }

        hasMoreData.value = newUsers.length >= pageSize.value;
        if (hasMoreData.value) {
          currentPage.value++;
        }
      } else {
        errorMessage.value = result.exceptionOrNull?.message ?? '加载用户失败';
      }
    } catch (e) {
      errorMessage.value = '加载用户失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 搜索用户
  Future<void> searchUsers(String query, {String? role}) async {
    isLoading.value = true;
    errorMessage.value = '';
    users.clear();
    currentPage.value = 1;

    try {
      final result = await _repository.searchUsers(
        query: query.isEmpty ? null : query,
        role: role,
        page: 1,
        pageSize: 50, // 搜索时返回更多结果
      );

      if (result.isSuccess) {
        users.value = result.dataOrNull ?? [];
        hasMoreData.value = false; // 搜索结果不分页
      } else {
        errorMessage.value = result.exceptionOrNull?.message ?? '搜索用户失败';
      }
    } catch (e) {
      errorMessage.value = '搜索用户失败: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换用户选择状态
  void toggleUserSelection(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
  }

  /// 全选/取消全选
  void toggleSelectAll() {
    if (selectedUserIds.length == users.length) {
      selectedUserIds.clear();
    } else {
      selectedUserIds.assignAll(users.map((u) => u.id).toSet());
    }
  }

  /// 批量设置为管理员
  Future<bool> batchSetAdmin() async {
    if (selectedUserIds.isEmpty) {
      errorMessage.value = '请先选择用户';
      return false;
    }

    // 获取 admin 角色 ID
    final adminRole = roles.firstWhereOrNull((r) => r.name.toLowerCase() == 'admin');
    if (adminRole == null) {
      errorMessage.value = '角色数据未加载，请检查后端 /api/v1/roles 接口';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.batchChangeUserRole(
        userIds: selectedUserIds.toList(),
        roleId: adminRole.id,
      );

      if (result.isSuccess) {
        // 更新本地用户列表
        final updatedUsers = result.dataOrNull ?? [];
        for (final updatedUser in updatedUsers) {
          final index = users.indexWhere((u) => u.id == updatedUser.id);
          if (index != -1) {
            users[index] = updatedUser;
          }
        }

        selectedUserIds.clear();
        return true;
      } else {
        errorMessage.value = result.exceptionOrNull?.message ?? '批量设置管理员失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '批量设置管理员失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// 批量设置为普通用户
  Future<bool> batchSetUser() async {
    if (selectedUserIds.isEmpty) {
      errorMessage.value = '请先选择用户';
      return false;
    }

    // 获取 user 角色 ID
    final userRole = roles.firstWhereOrNull((r) => r.name.toLowerCase() == 'user');
    if (userRole == null) {
      errorMessage.value = '角色数据未加载，请检查后端 /api/v1/roles 接口';
      return false;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _repository.batchChangeUserRole(
        userIds: selectedUserIds.toList(),
        roleId: userRole.id,
      );

      if (result.isSuccess) {
        // 更新本地用户列表
        final updatedUsers = result.dataOrNull ?? [];
        for (final updatedUser in updatedUsers) {
          final index = users.indexWhere((u) => u.id == updatedUser.id);
          if (index != -1) {
            users[index] = updatedUser;
          }
        }

        selectedUserIds.clear();
        return true;
      } else {
        errorMessage.value = result.exceptionOrNull?.message ?? '批量设置用户失败';
        return false;
      }
    } catch (e) {
      errorMessage.value = '批量设置用户失败: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // 清空所有响应式变量
    users.clear();
    roles.clear();
    selectedUserIds.clear();
    
    // 重置加载状态
    isLoading.value = false;
    errorMessage.value = '';
    
    // 重置分页状态
    currentPage.value = 1;
    hasMoreData.value = true;
    
    super.onClose();
  }
}
