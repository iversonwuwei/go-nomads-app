import 'dart:async';
import 'dart:developer';

import 'package:df_admin_mobile/controllers/locale_controller.dart';
import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/social_login_service.dart';
import 'package:df_admin_mobile/services/token_storage_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 登录模式
enum LoginMode { email, phone }

class NomadsLoginPageController extends GetxController {
  // Nomads.com 品牌红色
  static const Color nomadsRed = Color(0xFFFF4458);

  // Form key
  final formKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final smsCodeController = TextEditingController();

  final _tokenStorageService = TokenStorageService();

  // State
  final RxBool obscurePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final Rx<LoginMode> loginMode = LoginMode.email.obs;
  final RxInt countdown = 0.obs;

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
    _loadRememberMe();
  }

  @override
  void onClose() {
    // 不要手动 dispose TextEditingController
    // GetX 会自动管理 controller 生命周期，手动 dispose 会导致
    // "TextEditingController was used after being disposed" 错误
    // 因为 widget tree 可能还没完全卸载时 controller 已被销毁
    _countdownTimer?.cancel();
    super.onClose();
  }

  /// 加载「记住我」数据
  Future<void> _loadRememberMe() async {
    final savedRememberMe = await _tokenStorageService.getRememberMe();
    final savedEmail = await _tokenStorageService.getSavedEmail();

    rememberMe.value = savedRememberMe;
    if (savedRememberMe && savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      log('📥 已恢复保存的邮箱: $savedEmail');
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  void setRememberMe(bool value) => rememberMe.value = value;

  void setLoginMode(LoginMode mode) => loginMode.value = mode;

  /// 发送验证码
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

  /// 手机号登录
  Future<void> loginWithPhone(BuildContext context) async {
    final phone = phoneController.text.trim();
    final code = smsCodeController.text.trim();

    if (phone.isEmpty || code.isEmpty) {
      AppToast.warning('请输入手机号和验证码', title: '提示');
      return;
    }

    _showLoadingDialog(context);

    try {
      log('🔐 开始手机号登录..');

      final authController = Get.find<AuthStateController>();
      final success = await authController.loginWithPhone(phone: '+86$phone', code: code);

      if (context.mounted) Navigator.pop(context);

      if (success) {
        final user = authController.currentUser.value;
        log('✅ 手机号登录成功: ${user?.name}');
        AppToast.success('欢迎回来！', title: '登录成功');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/');
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

  /// 邮箱登录
  Future<void> loginWithEmail(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    _showLoadingDialog(context);

    try {
      log('🔐 开始登录验证..');

      final authController = Get.find<AuthStateController>();
      final success = await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (context.mounted) Navigator.pop(context);

      if (success) {
        final user = authController.currentUser.value;
        if (user == null) {
          AppToast.error('Failed to load user data', title: 'Login Failed');
          return;
        }

        log('🎉 登录成功: ${user.name}');

        await _tokenStorageService.saveRememberMe(
          rememberMe: rememberMe.value,
          email: emailController.text.trim(),
        );

        AppToast.success('Welcome back, ${user.name}!', title: 'Login Successful');
        await Future.delayed(const Duration(milliseconds: 300));
        Get.offAllNamed('/');
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

  /// 社交登录
  Future<void> handleSocialLogin(SocialLoginType type, String platformName) async {
    log('📱 开始 $platformName 登录...');

    try {
      final authController = Get.find<AuthStateController>();
      final success = await authController.socialLogin(type);

      if (success) {
        final user = authController.currentUser.value;
        log('✅ $platformName 登录成功: ${user?.name}');
        AppToast.success('欢迎回来！', title: '登录成功');
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/');
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
        child: CircularProgressIndicator(color: nomadsRed),
      ),
    );
  }
}
