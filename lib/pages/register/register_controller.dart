import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/api_config.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 注册页面控制器 - 使用响应式验证，无需 GlobalKey
class RegisterController extends GetxController {
  final HttpService _httpService = HttpService();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final verificationCodeController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isRegistering = false.obs;

  // 验证码相关状态
  final RxBool isSendingCode = false.obs;
  final RxInt countdown = 0.obs;
  final RxBool codeSent = false.obs;
  Timer? _countdownTimer;

  // 响应式错误信息 - 替代 GlobalKey + FormState
  final RxnString usernameError = RxnString(null);
  final RxnString emailError = RxnString(null);
  final RxnString passwordError = RxnString(null);
  final RxnString confirmPasswordError = RxnString(null);
  final RxnString verificationCodeError = RxnString(null);

  // 是否显示验证错误（首次提交后才显示）
  final RxBool showValidationErrors = false.obs;

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  @override
  void onInit() {
    super.onInit();
    // 监听输入变化，实时验证（仅在首次提交后）
    ever(showValidationErrors, (_) {
      if (showValidationErrors.value) {
        _setupValidationListeners();
      }
    });
  }

  void _setupValidationListeners() {
    // 当显示验证错误后，实时验证输入
    usernameController.addListener(_validateUsername);
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    confirmPasswordController.addListener(_validateConfirmPassword);
    verificationCodeController.addListener(_validateVerificationCode);
  }

  @override
  void onClose() {
    usernameController.removeListener(_validateUsername);
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    confirmPasswordController.removeListener(_validateConfirmPassword);
    verificationCodeController.removeListener(_validateVerificationCode);
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    verificationCodeController.dispose();
    _countdownTimer?.cancel();
    super.onClose();
  }

  // 验证方法
  void _validateUsername() {
    final value = usernameController.text;
    if (value.isEmpty) {
      usernameError.value = 'usernameRequired';
    } else if (value.length < 3) {
      usernameError.value = 'usernameMinLength';
    } else {
      usernameError.value = null;
    }
  }

  void _validateEmail() {
    final value = emailController.text;
    if (value.isEmpty) {
      emailError.value = 'emailRequired';
    } else if (!GetUtils.isEmail(value)) {
      emailError.value = 'emailInvalid';
    } else {
      emailError.value = null;
    }
  }

  void _validatePassword() {
    final value = passwordController.text;
    if (value.isEmpty) {
      passwordError.value = 'passwordRequired';
    } else if (value.length < 6) {
      passwordError.value = 'passwordMinLength';
    } else {
      passwordError.value = null;
    }
    // 密码变化时也要验证确认密码
    if (confirmPasswordController.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    final value = confirmPasswordController.text;
    if (value.isEmpty) {
      confirmPasswordError.value = 'confirmPasswordRequired';
    } else if (value != passwordController.text) {
      confirmPasswordError.value = 'passwordsNotMatch';
    } else {
      confirmPasswordError.value = null;
    }
  }

  void _validateVerificationCode() {
    final value = verificationCodeController.text;
    if (value.isEmpty) {
      verificationCodeError.value = 'verificationCodeRequired';
    } else if (value.length < 6) {
      verificationCodeError.value = 'verificationCodeLength';
    } else {
      verificationCodeError.value = null;
    }
  }

  /// 验证所有字段
  bool _validateAll() {
    _validateUsername();
    _validateEmail();
    _validatePassword();
    _validateConfirmPassword();
    _validateVerificationCode();

    return usernameError.value == null &&
        emailError.value == null &&
        passwordError.value == null &&
        confirmPasswordError.value == null &&
        verificationCodeError.value == null;
  }

  /// 清除所有错误
  void clearErrors() {
    usernameError.value = null;
    emailError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;
    verificationCodeError.value = null;
    showValidationErrors.value = false;
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleObscureConfirmPassword() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void toggleAgreeToTerms([bool? value]) {
    agreeToTerms.value = value ?? !agreeToTerms.value;
  }

  /// 发送邮箱验证码
  Future<void> sendVerificationCode() async {
    // 先验证邮箱格式
    _validateEmail();
    if (emailError.value != null) {
      showValidationErrors.value = true;
      return;
    }

    if (countdown.value > 0) return;

    final email = emailController.text.trim();
    try {
      isSendingCode.value = true;
      final response = await _httpService.post(
        ApiConfig.registerSendCodeEndpoint,
        data: {'email': email},
      );

      final data = response.data;
      if (data != null && data is Map) {
        final success = data['success'] as bool? ?? false;
        if (success) {
          codeSent.value = true;
          _startCountdown(60);
          AppToast.success(_l10n.registerCodeSentToEmail);
        } else {
          AppToast.error((data['message'] as String?) ?? '发送失败');
        }
      }
    } on HttpException catch (e) {
      log('发送注册验证码失败 (HttpException): ${e.message}');
      AppToast.error(e.message);
    } catch (e) {
      log('发送注册验证码失败: $e');
      AppToast.error(_l10n.registerSendCodeFailedRetry);
    } finally {
      isSendingCode.value = false;
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

  /// 注册
  Future<void> register({
    required String termsRequiredTitle,
    required String pleaseAgreeToTerms,
    required String welcomeToCommunity,
    required String successTitle,
  }) async {
    // 标记开始验证，后续输入会实时验证
    showValidationErrors.value = true;

    if (!_validateAll()) {
      return;
    }

    if (!agreeToTerms.value) {
      AppToast.warning(
        pleaseAgreeToTerms,
        title: termsRequiredTitle,
      );
      return;
    }

    isRegistering.value = true;

    try {
      final authController = Get.find<AuthStateController>();
      final success = await authController.register(
        name: usernameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        confirmPassword: confirmPasswordController.text,
        verificationCode: verificationCodeController.text.trim(),
      );

      if (success) {
        final user = authController.currentUser.value;
        log('✅ 注册成功: ${user?.name}');

        AppToast.success(
          welcomeToCommunity,
          title: successTitle,
        );

        // 直接跳转到首页（与登录流程一致），不经过 AppWrapper
        Get.offAllNamed(AppRoutes.home);
      } else {
        log('❌ 注册失败');
        AppToast.error(
          _l10n.registerFailedCheckInput,
          title: _l10n.registerFailedTitle,
        );
      }
    } on HttpException catch (e) {
      log('❌ 注册失败 (HttpException): ${e.message}');
      AppToast.error(
        e.message,
        title: _l10n.registerFailedTitle,
      );
    } catch (e) {
      log('❌ 注册错误: $e');
      AppToast.error(
        _l10n.registerFailedProcessError,
        title: _l10n.registerFailedTitle,
      );
    } finally {
      isRegistering.value = false;
    }
  }
}
