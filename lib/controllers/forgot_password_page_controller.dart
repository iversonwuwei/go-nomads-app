import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 忘记密码控制器
/// 步骤：0=输入账号 → 1=输入验证码 → 2=设置新密码
class ForgotPasswordController extends GetxController {
  final HttpService _httpService = HttpService();
  final AppConfigService _appConfigService = AppConfigService();

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
  final forgotPasswordCopy = Rxn<ForgotPasswordCopy>();

  @override
  void onInit() {
    super.onInit();
    unawaited(_loadRemoteCopyAsync());
  }

  @override
  void onClose() {
    accountController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> _loadRemoteCopyAsync() async {
    forgotPasswordCopy.value = await _appConfigService.getForgotPasswordCopy(forceRefresh: true);
  }

  String getStepTitle(int step) {
    switch (step) {
      case 0:
        return forgotPasswordCopy.value?.accountStepTitle ?? '找回密码';
      case 1:
        return forgotPasswordCopy.value?.verifyStepTitle ?? '验证身份';
      case 2:
        return forgotPasswordCopy.value?.resetStepTitle ?? '设置新密码';
      default:
        return forgotPasswordCopy.value?.accountStepTitle ?? '找回密码';
    }
  }

  String get accountStepDescription =>
      forgotPasswordCopy.value?.accountStepDescription ?? '请输入您的邮箱或手机号\n我们将发送验证码帮助您重置密码';

  String get accountInputLabel => forgotPasswordCopy.value?.accountInputLabel ?? '邮箱或手机号';

  String get accountSendCodeButton => forgotPasswordCopy.value?.accountSendCodeButton ?? '发送验证码';

  String get verifyCodeLabel => forgotPasswordCopy.value?.verifyCodeLabel ?? '验证码';

  String get verifyResendButton => forgotPasswordCopy.value?.verifyResendButton ?? '重新发送验证码';

  String get verifyNextButton => forgotPasswordCopy.value?.verifyNextButton ?? '下一步';

  String get resetStepDescription => forgotPasswordCopy.value?.resetStepDescription ?? '请设置您的新密码';

  String get resetNewPasswordLabel => forgotPasswordCopy.value?.resetNewPasswordLabel ?? '新密码';

  String get resetConfirmPasswordLabel => forgotPasswordCopy.value?.resetConfirmPasswordLabel ?? '确认密码';

  String get resetSubmitButton => forgotPasswordCopy.value?.resetSubmitButton ?? '重置密码';

  String getVerifyDescription(String target) {
    final template = forgotPasswordCopy.value?.verifyStepDescriptionTemplate ?? '验证码已发送至\n{target}';
    return template.replaceAll('{target}', target);
  }

  String getResendCountdownLabel(int seconds) {
    final template = forgotPasswordCopy.value?.verifyResendCountdownTemplate ?? '{seconds}s 后重新发送';
    return template.replaceAll('{seconds}', seconds.toString());
  }

  /// 发送验证码
  Future<void> sendCode() async {
    final account = accountController.text.trim();
    if (account.isEmpty) {
      AppToast.warning(forgotPasswordCopy.value?.toastAccountRequired ?? '请输入邮箱或手机号');
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
            recoveryMethod.value == 'email'
                ? (forgotPasswordCopy.value?.toastCodeSentEmail ?? '验证码已发送到邮箱')
                : (forgotPasswordCopy.value?.toastCodeSentPhone ?? '验证码已发送到手机'),
          );
        } else {
          AppToast.error((data['message'] as String?) ?? '发送失败');
        }
      }
    } catch (e) {
      log('发送验证码失败: $e');
      // 显示后端返回的具体错误信息
      if (e is HttpException) {
        AppToast.error(e.message);
      } else {
        AppToast.error(forgotPasswordCopy.value?.toastSendFailedFallback ?? '发送验证码失败，请稍后重试');
      }
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
      AppToast.warning(forgotPasswordCopy.value?.toastCodeRequired ?? '请输入验证码');
      return;
    }
    if (code.length < 6) {
      AppToast.warning(forgotPasswordCopy.value?.toastCodeIncomplete ?? '请输入完整的验证码');
      return;
    }
    currentStep.value = 2;
  }

  /// 重置密码
  Future<void> resetPassword() async {
    final newPwd = newPasswordController.text.trim();
    final confirmPwd = confirmPasswordController.text.trim();

    if (newPwd.isEmpty) {
      AppToast.warning(forgotPasswordCopy.value?.toastNewPasswordRequired ?? '请输入新密码');
      return;
    }
    if (newPwd.length < 6) {
      AppToast.warning(forgotPasswordCopy.value?.toastPasswordMinLength ?? '密码至少需要6个字符');
      return;
    }
    if (confirmPwd.isEmpty) {
      AppToast.warning(forgotPasswordCopy.value?.toastConfirmPasswordRequired ?? '请确认新密码');
      return;
    }
    if (newPwd != confirmPwd) {
      AppToast.warning(forgotPasswordCopy.value?.toastPasswordMismatch ?? '两次输入的密码不一致');
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
      AppToast.success(forgotPasswordCopy.value?.toastResetSuccess ?? '密码重置成功，请使用新密码登录');
      Get.back();
    } catch (e) {
      log('重置密码失败: $e');
      if (e is HttpException) {
        AppToast.error(e.message);
      } else {
        AppToast.error(forgotPasswordCopy.value?.toastResetFailedFallback ?? '重置密码失败，请稍后重试');
      }
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
