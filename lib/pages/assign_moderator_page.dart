import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/repositories/i_city_repository.dart';
import 'package:df_admin_mobile/features/user_management/domain/repositories/iuser_management_repository.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 指定城市版主页面
class AssignModeratorPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const AssignModeratorPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<AssignModeratorPage> createState() => _AssignModeratorPageState();
}

class _AssignModeratorPageState extends State<AssignModeratorPage> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();

  final RxList<Map<String, dynamic>> _allUsers = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> _filteredUsers = <Map<String, dynamic>>[].obs;
  final RxSet<String> _selectedUserIds = <String>{}.obs;

  final RxBool _isLoading = false.obs;
  final RxBool _isSubmitting = false.obs;

  // 权限选项 - 将应用于所有选中的用户
  final RxBool _canEditCity = true.obs;
  final RxBool _canManageCoworks = true.obs;
  final RxBool _canManageCosts = true.obs;
  final RxBool _canManageVisas = true.obs;
  final RxBool _canModerateChats = true.obs;

  @override
  void initState() {
    super.initState();
    log('🎬 [AssignModerator] initState - cityId: ${widget.cityId}, cityName: ${widget.cityName}');
    _loadUsers();

    // 监听搜索框变化，实时过滤
    _searchController.addListener(() {
      _filterUsers(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// 加载版主候选人（Pro及以上会员或Admin用户）
  Future<void> _loadUsers() async {
    log('📡 [AssignModerator] 开始加载版主候选人列表...');
    _isLoading.value = true;
    try {
      final userManagementRepo = Get.find<IUserManagementRepository>();
      log('📡 [AssignModerator] 调用 userManagementRepo.getModeratorCandidates(page: 1, pageSize: 100)');

      final result = await userManagementRepo.getModeratorCandidates(
        page: 1,
        pageSize: 100, // 加载更多用户
      );

      log('📡 [AssignModerator] API 返回结果: isSuccess=${result.isSuccess}');

      if (result.isSuccess) {
        final users = result.dataOrNull ?? [];
        log('📡 [AssignModerator] 获取到 ${users.length} 个版主候选人');

        if (users.isEmpty) {
          log('⚠️ [AssignModerator] 版主候选人列表为空！');
        } else {
          log('📋 [AssignModerator] 前3个候选人:');
          for (var i = 0; i < users.length && i < 3; i++) {
            log('   [$i] id=${users[i].id}, name=${users[i].name}, email=${users[i].email}, level=${users[i].membershipLevelName}');
          }
        }

        _allUsers.value = users.map((user) {
          return {
            'id': user.id,
            'name': user.name,
            'email': user.email,
            'role': user.role,
            'membershipLevel': user.membershipLevel,
            'membershipLevelName': user.membershipLevelName,
            'displayBadge': user.displayBadge,
            'isAdmin': user.isAdmin,
          };
        }).toList();

        log('📋 [AssignModerator] _allUsers 已更新: ${_allUsers.length} 个');
        _filteredUsers.value = _allUsers;
        log('📋 [AssignModerator] _filteredUsers 已更新: ${_filteredUsers.length} 个');
      } else {
        final errorMsg = result.exceptionOrNull?.message ?? "未知错误";
        log('❌ [AssignModerator] 加载失败: $errorMsg');
        // 延迟显示错误，避免在 build 期间调用
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AppToast.error('加载版主候选人失败: $errorMsg');
        });
      }
    } catch (e, stackTrace) {
      log('❌ [AssignModerator] 加载异常: $e');
      log('❌ [AssignModerator] 堆栈: $stackTrace');
      // 延迟显示错误，避免在 build 期间调用
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppToast.error('加载版主候选人失败: $e');
      });
    } finally {
      _isLoading.value = false;
      log('📡 [AssignModerator] 加载完成，isLoading=false');
    }
  }

  /// 过滤用户列表
  void _filterUsers(String query) {
    log('🔍 [AssignModerator] 过滤用户: query="$query", _allUsers.length=${_allUsers.length}');

    if (query.trim().isEmpty) {
      _filteredUsers.value = _allUsers;
      log('🔍 [AssignModerator] 清空搜索，显示全部 ${_filteredUsers.length} 个用户');
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    _filteredUsers.value = _allUsers.where((user) {
      final name = user['name'].toString().toLowerCase();
      final email = user['email'].toString().toLowerCase();
      return name.contains(lowercaseQuery) || email.contains(lowercaseQuery);
    }).toList();

    log('🔍 [AssignModerator] 过滤后: ${_filteredUsers.length} 个用户');
  }

  /// 切换用户选中状态
  void _toggleUserSelection(String userId) {
    if (_selectedUserIds.contains(userId)) {
      _selectedUserIds.remove(userId);
      log('✅ [AssignModerator] 取消选择用户: $userId, 当前选中: ${_selectedUserIds.length}');
    } else {
      _selectedUserIds.add(userId);
      log('✅ [AssignModerator] 选择用户: $userId, 当前选中: ${_selectedUserIds.length}');
    }
  }

  /// 全选/取消全选
  void _toggleSelectAll() {
    if (_selectedUserIds.length == _filteredUsers.length) {
      _selectedUserIds.clear();
    } else {
      _selectedUserIds.clear();
      for (var user in _filteredUsers) {
        _selectedUserIds.add(user['id']);
      }
    }
  }

  /// 提交指定版主（批量）
  Future<void> _submitAssignModerator() async {
    log('🚀 [AssignModerator] 开始提交指定版主');

    if (_selectedUserIds.isEmpty) {
      log('❌ [AssignModerator] 没有选择任何用户');
      AppToast.error('请至少选择一个用户');
      return;
    }

    log('📋 [AssignModerator] 选中的用户: ${_selectedUserIds.join(", ")}');

    // 确认对话框
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认指定版主'),
        content: Text(
          '确定要将 ${_selectedUserIds.length} 个用户指定为版主吗？\n\n'
          '这些用户将自动获得版主角色和相应权限。',
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

    if (confirmed != true) {
      log('🚫 [AssignModerator] 用户取消了操作');
      return;
    }

    log('✅ [AssignModerator] 用户确认，开始指定版主');
    _isSubmitting.value = true;

    try {
      final cityRepository = Get.find<ICityRepository>();

      int successCount = 0;
      int failCount = 0;
      final List<String> errorMessages = [];

      // 逐个调用后端 API 添加版主
      for (var userId in _selectedUserIds) {
        try {
          log('🔄 [AssignModerator] 正在指定版主: userId=$userId, cityId=${widget.cityId}');

          final result = await cityRepository.assignModerator(
            widget.cityId,
            userId,
          );

          if (result.isSuccess) {
            log('✅ [AssignModerator] 指定成功: userId=$userId');
            successCount++;
          } else {
            final errorMsg = result.exceptionOrNull?.message ?? '未知错误';
            log('❌ [AssignModerator] 指定失败: userId=$userId, error=$errorMsg');
            failCount++;
            errorMessages.add('用户 $userId: $errorMsg');
          }
        } catch (e, stackTrace) {
          log('💥 [AssignModerator] 指定异常: userId=$userId, error=$e');
          log('📚 [AssignModerator] StackTrace: $stackTrace');
          failCount++;
          errorMessages.add('用户 $userId: $e');
        }
      }

      log('📊 [AssignModerator] 完成统计: 成功=$successCount, 失败=$failCount');

      if (successCount > 0) {
        AppToast.success('成功指定 $successCount 个版主！');
        if (failCount > 0) {
          log('⚠️ [AssignModerator] 部分失败详情: ${errorMessages.join("; ")}');
          AppToast.warning('$failCount 个用户指定失败，请查看日志');
        }
        Get.back(result: true); // 返回,通知调用方刷新
      } else {
        log('❌ [AssignModerator] 所有用户指定失败: ${errorMessages.join("; ")}');
        AppToast.error('所有用户指定失败: ${errorMessages.isNotEmpty ? errorMessages.first : "请重试"}');
      }
    } catch (e, stackTrace) {
      log('💥 [AssignModerator] 外层捕获异常: $e');
      log('📚 [AssignModerator] StackTrace: $stackTrace');
      AppToast.error('指定失败: $e');
    } finally {
      _isSubmitting.value = false;
      log('🏁 [AssignModerator] 提交流程结束');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - 指定版主'),
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 全选/取消全选按钮
          Obx(() => _filteredUsers.isNotEmpty
              ? TextButton.icon(
                  onPressed: _toggleSelectAll,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    _selectedUserIds.length == _filteredUsers.length
                        ? FontAwesomeIcons.squareCheck
                        : FontAwesomeIcons.square,
                    size: 20,
                  ),
                  label: Text(
                    _selectedUserIds.length == _filteredUsers.length ? '取消全选' : '全选',
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索用户名称或邮箱',
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(FontAwesomeIcons.xmark),
                            onPressed: () {
                              _searchController.clear();
                              _filterUsers('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.accent, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      '已选择 ${_selectedUserIds.length} 个用户',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )),
              ],
            ),
          ),

          const Divider(height: 1),

          // 用户列表
          Expanded(
            child: Obx(() {
              log(
                  '🎨 [AssignModerator] build Obx - isLoading=${_isLoading.value}, filteredUsers=${_filteredUsers.length}, selectedCount=${_selectedUserIds.length}');

              if (_isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (_filteredUsers.isEmpty) {
                log('⚠️ [AssignModerator] 显示空状态 UI');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.users,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchController.text.isEmpty ? '暂无用户' : '未找到匹配的用户',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              log('📋 [AssignModerator] 开始渲染 ListView: ${_filteredUsers.length} 个用户');
              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _filteredUsers.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  color: Colors.grey.shade200,
                ),
                itemBuilder: (context, index) {
                  final user = _filteredUsers[index];
                  final userId = user['id'];

                  if (index == 0) {
                    log('📋 [AssignModerator] 渲染第一个用户: id=$userId, name=${user['name']}, email=${user['email']}, badge=${user['displayBadge']}');
                  }

                  return Obx(() {
                    final isSelected = _selectedUserIds.contains(userId);
                    final displayBadge = user['displayBadge'] as String? ?? '';
                    final isAdmin = user['isAdmin'] as bool? ?? false;

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: isSelected ? AppColors.accent : Colors.grey[300],
                            child: Text(
                              user['name'].toString().substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.check,
                                  size: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user['name'],
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                          // 会员等级/Admin标签
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getBadgeColor(displayBadge, isAdmin).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getBadgeColor(displayBadge, isAdmin).withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              displayBadge,
                              style: TextStyle(
                                color: _getBadgeColor(displayBadge, isAdmin),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(user['email']),
                      trailing: Checkbox(
                        value: isSelected,
                        activeColor: AppColors.accent,
                        onChanged: (value) => _toggleUserSelection(userId),
                      ),
                      onTap: () => _toggleUserSelection(userId),
                      selected: isSelected,
                      selectedTileColor: AppColors.accent.withValues(alpha: 0.05),
                    );
                  });
                },
              );
            }),
          ),

          // 底部操作栏
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 权限快捷设置
                ExpansionTile(
                  title: const Text(
                    '版主权限设置（可选）',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '展开设置批量权限',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  children: [
                    _buildCompactPermissionSwitch('管理城市信息', _canEditCity),
                    _buildCompactPermissionSwitch('管理共享办公空间', _canManageCoworks),
                    _buildCompactPermissionSwitch('管理生活成本', _canManageCosts),
                    _buildCompactPermissionSwitch('管理签证信息', _canManageVisas),
                    _buildCompactPermissionSwitch('管理聊天室', _canModerateChats),
                  ],
                ),

                const SizedBox(height: 16),

                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: _selectedUserIds.isEmpty || _isSubmitting.value ? null : _submitAssignModerator,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cityPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _selectedUserIds.isEmpty ? 0 : 2,
                        ),
                        icon: _isSubmitting.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(FontAwesomeIcons.circleCheck),
                        label: Text(
                          _isSubmitting.value ? '指定中...' : '确认指定 ${_selectedUserIds.length} 个版主',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactPermissionSwitch(String title, RxBool value) {
    return Obx(() => CheckboxListTile(
          title: Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          value: value.value,
          activeColor: AppColors.accent,
          dense: true,
          onChanged: (newValue) {
            value.value = newValue ?? false;
          },
          controlAffinity: ListTileControlAffinity.leading,
        ));
  }

  /// 获取会员等级/Admin标签颜色
  Color _getBadgeColor(String badge, bool isAdmin) {
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
