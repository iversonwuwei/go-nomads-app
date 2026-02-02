import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/locale_controller.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 登录模式
enum LoginMode { email, phone }

/// 登录页面控制器 - 使用响应式验证，无需 GlobalKey
class LoginController extends GetxController {
  // Controllers
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController phoneController;
  late final TextEditingController smsCodeController;

  final _tokenStorageService = TokenStorageService();

  // 响应式状态
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final Rx<LoginMode> loginMode = LoginMode.email.obs;
  final RxInt countdown = 0.obs;
  final RxBool isLoading = false.obs;

  // 响应式错误信息 - 替代 GlobalKey + FormState
  final RxnString emailError = RxnString(null);
  final RxnString passwordError = RxnString(null);
  final RxnString phoneError = RxnString(null);
  final RxnString smsCodeError = RxnString(null);

  // 是否显示验证错误
  final RxBool showValidationErrors = false.obs;

  Timer? _countdownTimer;

  /// 判断是否为中国区用户
  bool get isChineseUser {
    try {
      final localeController = Get.find<LocaleController>();
      final locale = localeController.locale.value;
      return locale.languageCode == 'zh' ||
          locale.countryCode == 'CN' ||
          locale.countryCode == 'HK' ||
          locale.countryCode == 'MO' ||
          locale.countryCode == 'TW';
    } catch (_) {
      final systemLocale = Get.deviceLocale;
      return systemLocale?.languageCode == 'zh';
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 初始化 TextEditingController
    emailController = TextEditingController();
    passwordController = TextEditingController();
    phoneController = TextEditingController();
    smsCodeController = TextEditingController();
    
    _loadRememberMe();
    // 监听输入变化，实时验证
    ever(showValidationErrors, (_) {
      if (showValidationErrors.value) {
        _setupValidationListeners();
      }
    });
  }

  void _setupValidationListeners() {
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
    phoneController.addListener(_validatePhone);
    smsCodeController.addListener(_validateSmsCode);
  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    passwordController.removeListener(_validatePassword);
    phoneController.removeListener(_validatePhone);
    smsCodeController.removeListener(_validateSmsCode);
    _countdownTimer?.cancel();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    smsCodeController.dispose();
    super.onClose();
  }

  // ==================== 验证方法 ====================

  void _validateEmail() {
    final value = emailController.text.trim();
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
    } else {
      passwordError.value = null;
    }
  }

  void _validatePhone() {
    final value = phoneController.text.trim();
    if (value.isEmpty) {
      phoneError.value = 'phoneRequired';
    } else if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      phoneError.value = 'phoneInvalid';
    } else {
      phoneError.value = null;
    }
  }

  void _validateSmsCode() {
    final value = smsCodeController.text.trim();
    if (value.isEmpty) {
      smsCodeError.value = 'smsCodeRequired';
    } else {
      smsCodeError.value = null;
    }
  }

  bool _validateEmailForm() {
    _validateEmail();
    _validatePassword();
    return emailError.value == null && passwordError.value == null;
  }

  bool _validatePhoneForm() {
    _validatePhone();
    _validateSmsCode();
    return phoneError.value == null && smsCodeError.value == null;
  }

  void clearErrors() {
    emailError.value = null;
    passwordError.value = null;
    phoneError.value = null;
    smsCodeError.value = null;
    showValidationErrors.value = false;
  }

  // ==================== 状态切换 ====================

  void togglePasswordVisibility() => obscurePassword.toggle();

  void setRememberMe(bool value) => rememberMe.value = value;

  void setLoginMode(LoginMode mode) {
    loginMode.value = mode;
    clearErrors();
  }

  // ==================== 加载记住我 ====================

  Future<void> _loadRememberMe() async {
    final savedRememberMe = await _tokenStorageService.getRememberMe();
    final savedEmail = await _tokenStorageService.getSavedEmail();

    rememberMe.value = savedRememberMe;
    if (savedRememberMe && savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      log('📥 已恢复保存的邮箱: $savedEmail');
    }
  }

  // ==================== 发送验证码 ====================

  Future<void> sendSmsCode() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.warning('请输入手机号', title: '提示');
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      AppToast.warning('请输入正确的手机号', title: '提示');
      return;
    }

    try {
      final httpService = Get.find<HttpService>();
      final response = await httpService.post(
        '/auth/sms/send-code',
        data: {'phoneNumber': '+86$phone', 'purpose': 'login'},
      );

      if (response.data['success'] == true) {
        AppToast.success('验证码已发送', title: '成功');
        _startCountdown();
      } else {
        AppToast.error(response.data['message'] ?? '发送失败', title: '错误');
      }
    } catch (e) {
      log('❌ 发送验证码失败: $e');
      AppToast.error('发送验证码失败', title: '错误');
    }
  }

  void _startCountdown() {
    countdown.value = 60;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown.value--;
      if (countdown.value <= 0) {
        timer.cancel();
      }
    });
  }

  // ==================== 登录方法 ====================

  /// 邮箱登录
  Future<void> loginWithEmail(BuildContext context) async {
    showValidationErrors.value = true;

    if (!_validateEmailForm()) {
      return;
    }

    _showLoadingDialog(context);

    try {
      log('🔐 开始邮箱登录...');

      final authController = Get.find<AuthStateController>();
      final success = await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (context.mounted) Navigator.pop(context);

      if (success) {
        log('🎉 邮箱登录成功');

        await _tokenStorageService.saveRememberMe(
          rememberMe: rememberMe.value,
          email: emailController.text.trim(),
        );

        AppToast.success('Welcome back!', title: 'Login Successful');
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppToast.error('Invalid email or password', title: 'Login Failed');
      }
    } on HttpException catch (e) {
      if (context.mounted) Navigator.pop(context);
      AppToast.error(e.message, title: 'Network Error');
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      log('❌ 登录错误: $e');
      AppToast.error('An error occurred. Please try again.', title: 'Error');
    }
  }

  /// 手机号登录
  Future<void> loginWithPhone(BuildContext context) async {
    showValidationErrors.value = true;

    if (!_validatePhoneForm()) {
      return;
    }

    _showLoadingDialog(context);

    try {
      log('🔐 开始手机号登录...');

      final authController = Get.find<AuthStateController>();
      final success = await authController.loginWithPhone(
        phone: '+86${phoneController.text.trim()}',
        code: smsCodeController.text.trim(),
      );

      if (context.mounted) Navigator.pop(context);

      if (success) {
        log('✅ 手机号登录成功');
        AppToast.success('欢迎回来！', title: '登录成功');
        Get.offAllNamed(AppRoutes.home);
      } else {
        AppToast.error('登录失败，请重试', title: '错误');
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      log('❌ 手机号登录失败: $e');

      String errorMessage = '登录失败，请重试';
      if (e is DioException && e.error is HttpException) {
        final httpError = e.error as HttpException;
        errorMessage = httpError.message.contains('验证码') ? '验证码无效或已过期' : httpError.message;
      } else if (e.toString().contains('验证码')) {
        errorMessage = '验证码无效或已过期';
      }
      AppToast.error(errorMessage, title: '错误');
    }
  }

  /// 社交登录
  Future<void> handleSocialLogin(SocialLoginType type, String platformName) async {
    log('📱 开始 $platformName 登录...');

    try {
      final authController = Get.find<AuthStateController>();
      final success = await authController.socialLogin(type);

      if (success) {
        log('✅ $platformName 登录成功');
        AppToast.success('欢迎回来！', title: '登录成功');
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      log('❌ $platformName 登录异常: $e');
      AppToast.error('$platformName 登录失败，请稍后重试', title: '登录失败');
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: LoginConstants.primaryColor),
      ),
    );
  }
}
