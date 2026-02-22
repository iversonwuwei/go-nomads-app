import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 忘记密码控制器
/// 步骤：0=输入账号 → 1=输入验证码 → 2=设置新密码
class ForgotPasswordController extends GetxController {
  final HttpService _httpService = HttpService();

  // 表单控制器
  final accountController = TextEditingController();
  final codeController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // 步骤状态 (0=输入账号, 1=输入验证码, 2=设置新密码)
  final currentStep = 0.obs;

  // 加载状态
  final isLoading = false.obs;
  final isSendingCode = false.obs;

  // 验证码倒计时
  final countdown = 0.obs;
  Timer? _countdownTimer;

  // 找回方式信息
  final recoveryMethod = ''.obs; // email / sms
  final maskedTarget = ''.obs; // 脱敏后的目标

  // 密码可见性
  final newPasswordVisible = false.obs;
  final confirmPasswordVisible = false.obs;

  @override
  void onClose() {
    accountController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// 发送验证码
  Future<void> sendCode() async {
    final account = accountController.text.trim();
    if (account.isEmpty) {
      AppToast.warning('请输入邮箱或手机号');
      return;
    }

    try {
      isSendingCode.value = true;
      final response = await _httpService.post(
        ApiConfig.forgotPasswordSendCodeEndpoint,
        data: {'emailOrPhone': account},
      );

      final data = response.data;
      if (data != null && data is Map) {
        final success = data['success'] as bool? ?? false;
        if (success) {
          recoveryMethod.value = (data['recoveryMethod'] as String?) ?? '';
          maskedTarget.value = (data['maskedTarget'] as String?) ?? '';
          final expiresInSeconds = (data['expiresInSeconds'] as int?) ?? 300;

          // 开始倒计时
          _startCountdown(expiresInSeconds > 60 ? 60 : expiresInSeconds);

          // 跳到验证码输入步骤
          currentStep.value = 1;
          AppToast.success(
            recoveryMethod.value == 'email' ? '验证码已发送到邮箱' : '验证码已发送到手机',
          );
        } else {
          AppToast.error((data['message'] as String?) ?? '发送失败');
        }
      }
    } catch (e) {
      log('发送验证码失败: $e');
      // HttpService 已自动处理错误提示
    } finally {
      isSendingCode.value = false;
    }
  }

  /// 重新发送验证码
  Future<void> resendCode() async {
    if (countdown.value > 0) return;
    await sendCode();
  }

  /// 验证验证码并跳到设置密码步骤
  void goToResetStep() {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      AppToast.warning('请输入验证码');
      return;
    }
    if (code.length < 6) {
      AppToast.warning('请输入完整的验证码');
      return;
    }
    currentStep.value = 2;
  }

  /// 重置密码
  Future<void> resetPassword() async {
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

    try {
      isLoading.value = true;
      await _httpService.post(
        ApiConfig.forgotPasswordResetEndpoint,
        data: {
          'emailOrPhone': accountController.text.trim(),
          'code': codeController.text.trim(),
          'newPassword': newPwd,
        },
      );
      AppToast.success('密码重置成功，请使用新密码登录');
      Get.back();
    } catch (e) {
      log('重置密码失败: $e');
      // HttpService 已自动处理错误提示
    } finally {
      isLoading.value = false;
    }
  }

  /// 返回上一步
  void goBack() {
    if (currentStep.value > 0) {
      currentStep.value--;
    } else {
      Get.back();
    }
  }

  /// 开始倒计时
  void _startCountdown(int seconds) {
    countdown.value = seconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value <= 0) {
        timer.cancel();
      } else {
        countdown.value--;
      }
    });
  }
}
