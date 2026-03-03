import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 修改/设置密码控制器
class ChangePasswordController extends GetxController {
  final HttpService _httpService = HttpService();

  // 表单控制器
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 状态
  final isLoading = false.obs;
  final hasPassword = true.obs; // 默认假设已有密码，初始化时查询
  final isCheckingPassword = true.obs; // 正在查询密码状态
  final userEmail = ''.obs;

  // 密码可见性
  final oldPasswordVisible = false.obs;
  final newPasswordVisible = false.obs;
  final confirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserInfo();
    _checkHasPassword();
  }

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  /// 加载用户信息（邮箱）
  void _loadUserInfo() {
    try {
      final authController = Get.find<AuthStateController>();
      final user = authController.currentUser.value;
      if (user != null) {
        userEmail.value = user.email;
      }
    } catch (e) {
      log('加载用户信息失败: $e');
    }
  }

  /// 检查用户是否已设置密码
  Future<void> _checkHasPassword() async {
    try {
      isCheckingPassword.value = true;
      final response = await _httpService.get(ApiConfig.hasPasswordEndpoint);
      final data = response.data;
      if (data != null && data is Map && data['hasPassword'] != null) {
        hasPassword.value = data['hasPassword'] as bool;
      }
    } catch (e) {
      log('检查密码状态失败: $e');
      // 默认保持 hasPassword = true，更安全
    } finally {
      isCheckingPassword.value = false;
    }
  }

  /// 提交密码修改/设置
  Future<void> submitPassword() async {
    // 验证
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (newPwd.isEmpty) {
      AppToast.warning('请输入新密码');
      return;
    }

    if (newPwd.length < 6) {
      AppToast.warning('密码至少需要6个字符');
      return;
    }

    if (confirmPwd.isEmpty) {
      AppToast.warning('请确认新密码');
      return;
    }

    if (newPwd != confirmPwd) {
      AppToast.warning('两次输入的密码不一致');
      return;
    }

    if (hasPassword.value) {
      // 修改密码：需要验证旧密码
      final oldPwd = oldPasswordController.text.trim();
      if (oldPwd.isEmpty) {
        AppToast.warning('请输入原密码');
        return;
      }
      await _changePassword(oldPwd, newPwd);
    } else {
      // 设置密码：直接设置
      await _setPassword(newPwd);
    }
  }

  /// 修改密码（已有密码的用户）
  Future<void> _changePassword(String oldPassword, String newPassword) async {
    try {
      isLoading.value = true;
      await _httpService.post(
        ApiConfig.changePasswordEndpoint,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      AppToast.success('密码修改成功');
      Get.back();
    } catch (e) {
      log('修改密码失败: $e');
      // HttpService 已自动处理错误提示
    } finally {
      isLoading.value = false;
    }
  }

  /// 设置密码（未设置密码的用户）
  Future<void> _setPassword(String newPassword) async {
    try {
      isLoading.value = true;
      await _httpService.post(
        ApiConfig.setPasswordEndpoint,
        data: {
          'newPassword': newPassword,
        },
      );
      AppToast.success('密码设置成功');
      Get.back();
    } catch (e) {
      log('设置密码失败: $e');
      // HttpService 已自动处理错误提示
    } finally {
      isLoading.value = false;
    }
  }

  /// 切换密码可见性
  void toggleOldPasswordVisible() =>
      oldPasswordVisible.value = !oldPasswordVisible.value;

  void toggleNewPasswordVisible() =>
      newPasswordVisible.value = !newPasswordVisible.value;

  void toggleConfirmPasswordVisible() =>
      confirmPasswordVisible.value = !confirmPasswordVisible.value;
}
