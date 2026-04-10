import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/locale_controller.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/social_login_service.dart';
import 'package:go_nomads_app/services/token_storage_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/dialogs/app_loading_dialog.dart';
import 'package:go_nomads_app/widgets/dialogs/first_launch_privacy_dialog.dart';

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

  // 用户协议勾选状态（工信部合规要求）
  final RxBool agreeToTerms = false.obs;

  Timer? _countdownTimer;
  LoginFeedbackCopy? _feedbackCopy;

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  void applyFeedbackCopy(LoginFeedbackCopy? copy) {
    _feedbackCopy = copy;
  }

  String _copyOrFallback(String? remote, String fallback) {
    if (remote == null) {
      return fallback;
    }

    final trimmed = remote.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  String _formatCopyTemplate(
    String? template,
    Map<String, String> values,
    String fallback,
  ) {
    var resolved = _copyOrFallback(template, fallback);
    values.forEach((key, value) {
      resolved = resolved.replaceAll('{$key}', value);
    });
    return resolved;
  }

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

  // ==================== 协议勾选 ====================

  /// 切换用户协议勾选状态
  void toggleAgreeToTerms([bool? value]) {
    agreeToTerms.value = value ?? !agreeToTerms.value;
  }

  /// 检查用户是否已同意协议，未同意则提示
  bool _checkTermsAgreed() {
    if (!agreeToTerms.value) {
      AppToast.warning(
        _copyOrFallback(_feedbackCopy?.termsRequiredMessage, _l10n.pleaseAgreeToTerms),
        title: _copyOrFallback(_feedbackCopy?.termsRequiredTitle, _l10n.termsRequired),
      );
      return false;
    }
    return true;
  }

  // ==================== 发送验证码 ====================

  Future<void> sendSmsCode() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.warning(
        _copyOrFallback(_feedbackCopy?.phoneRequiredMessage, _l10n.loginPhoneRequired),
        title: _l10n.loginTipsTitle,
      );
      return;
    }

    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      AppToast.warning(
        _copyOrFallback(_feedbackCopy?.phoneInvalidMessage, _l10n.loginPhoneInvalid),
        title: _l10n.loginTipsTitle,
      );
      return;
    }

    try {
      final httpService = Get.find<HttpService>();
      final response = await httpService.post(
        '/auth/sms/send-code',
        data: {'phoneNumber': '+86$phone', 'purpose': 'login'},
      );

      if (response.data['success'] == true) {
        AppToast.success(
          _copyOrFallback(_feedbackCopy?.smsCodeSentMessage, _l10n.loginSmsCodeSent),
          title: _copyOrFallback(_feedbackCopy?.loginSuccessTitle, _l10n.success),
        );
        _startCountdown();
      } else {
        AppToast.error(
          response.data['message']?.toString() ??
              _copyOrFallback(_feedbackCopy?.sendFailedMessage, _l10n.loginSendFailed),
          title: _l10n.error,
        );
      }
    } catch (e) {
      log('❌ 发送验证码失败: $e');
      AppToast.error(
        _copyOrFallback(_feedbackCopy?.sendSmsFailedMessage, _l10n.loginSendSmsFailed),
        title: _l10n.error,
      );
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

    if (!_checkTermsAgreed()) return;

    _showLoadingDialog(context);

    try {
      log('🔐 开始邮箱登录...');

      final authController = Get.find<AuthStateController>();
      final success = await authController.login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      _closeLoadingDialog();

      if (success) {
        log('🎉 邮箱登录成功');

        await _tokenStorageService.saveRememberMe(
          rememberMe: rememberMe.value,
          email: emailController.text.trim(),
        );

        AppToast.success(
          _copyOrFallback(_feedbackCopy?.welcomeBackMessage, _l10n.loginWelcomeBack),
          title: _copyOrFallback(_feedbackCopy?.loginSuccessTitle, _l10n.loginSuccessfulTitle),
        );

        // 先导航到首页（正确卸载登录页，避免 TextEditingController disposed 错误）
        Get.offAllNamed(AppRoutes.home);
        // 在独立上下文中延迟检查隐私政策（不依赖已 dispose 的 LoginController）
        _schedulePrivacyPolicyCheck(markLocalConsent: true);
      } else {
        AppToast.error(
          _copyOrFallback(_feedbackCopy?.invalidEmailOrPasswordMessage, _l10n.loginInvalidEmailOrPassword),
          title: _copyOrFallback(_feedbackCopy?.loginFailedTitle, _l10n.loginFailedTitle),
        );
      }
    } on HttpException catch (e) {
      _closeLoadingDialog();
      AppToast.error(e.message, title: _l10n.networkError);
    } catch (e) {
      _closeLoadingDialog();
      log('❌ 登录错误: $e');
      AppToast.error(
        _copyOrFallback(_feedbackCopy?.unknownErrorRetryMessage, _l10n.loginUnknownErrorRetry),
        title: _l10n.error,
      );
    }
  }

  /// 手机号登录
  Future<void> loginWithPhone(BuildContext context) async {
    showValidationErrors.value = true;

    if (!_validatePhoneForm()) {
      return;
    }

    if (!_checkTermsAgreed()) return;

    _showLoadingDialog(context);

    try {
      log('🔐 开始手机号登录...');

      final authController = Get.find<AuthStateController>();
      final success = await authController.loginWithPhone(
        phone: '+86${phoneController.text.trim()}',
        code: smsCodeController.text.trim(),
      );

      _closeLoadingDialog();

      if (success) {
        log('✅ 手机号登录成功');
        AppToast.success(
          _copyOrFallback(_feedbackCopy?.welcomeBackMessage, _l10n.loginWelcomeBack),
          title: _copyOrFallback(_feedbackCopy?.loginSuccessTitle, _l10n.loginSuccessfulTitle),
        );

        // 先导航到首页（正确卸载登录页）
        Get.offAllNamed(AppRoutes.home);
        // 在独立上下文中延迟检查隐私政策
        _schedulePrivacyPolicyCheck(markLocalConsent: true);
      } else {
        AppToast.error(
          _copyOrFallback(_feedbackCopy?.loginFailedRetryMessage, _l10n.loginFailedRetry),
          title: _l10n.error,
        );
      }
    } catch (e) {
      _closeLoadingDialog();
      log('❌ 手机号登录失败: $e');

      String errorMessage = _copyOrFallback(_feedbackCopy?.loginFailedRetryMessage, _l10n.loginFailedRetry);
      if (e is DioException && e.error is HttpException) {
        final httpError = e.error as HttpException;
        errorMessage = httpError.message.contains('验证码')
            ? _copyOrFallback(_feedbackCopy?.smsCodeInvalidOrExpiredMessage, _l10n.loginSmsCodeInvalidOrExpired)
            : httpError.message;
      } else if (e.toString().contains('验证码')) {
        errorMessage =
            _copyOrFallback(_feedbackCopy?.smsCodeInvalidOrExpiredMessage, _l10n.loginSmsCodeInvalidOrExpired);
      }
      AppToast.error(errorMessage, title: _l10n.error);
    }
  }

  /// 社交登录
  Future<void> handleSocialLogin(SocialLoginType type, String platformName) async {
    if (!_checkTermsAgreed()) return;

    log('📱 开始 $platformName 登录...');

    try {
      final authController = Get.find<AuthStateController>();

      // 调用社交登录，传入回调：授权成功后才显示加载状态
      final success = await authController.socialLogin(
        type,
        onAuthSuccess: () {
          log('✅ $platformName 授权成功，开始登录...');
          isLoading.value = true;
          _showSocialLoginLoadingDialog(platformName);
        },
      );

      // 关闭加载对话框
      AppLoadingDialog.hide();
      isLoading.value = false;

      if (success) {
        log('✅ $platformName 登录成功');
        AppToast.success(_l10n.loginWelcomeBack, title: _l10n.loginSuccessfulTitle);

        // 先导航到首页（正确卸载登录页）
        Get.offAllNamed(AppRoutes.home);
        // 在独立上下文中延迟检查隐私政策
        _schedulePrivacyPolicyCheck(markLocalConsent: true);
      }
    } catch (e) {
      // 关闭加载对话框
      AppLoadingDialog.hide();
      isLoading.value = false;

      log('❌ $platformName 登录异常: $e');
      AppToast.error(
        _formatCopyTemplate(
          _feedbackCopy?.socialFailedTemplate,
          {'platform': platformName},
          _l10n.loginSocialFailed(platformName),
        ),
        title: _copyOrFallback(_feedbackCopy?.loginFailedTitle, _l10n.loginFailedTitle),
      );
    }
  }

  /// 显示社交登录加载对话框
  void _showSocialLoginLoadingDialog(String platformName) {
    AppLoadingDialog.show(
      title: _formatCopyTemplate(
        _feedbackCopy?.socialLoadingTitleTemplate,
        {'platform': platformName},
        _l10n.loginSocialLoading(platformName),
      ),
      subtitle: _copyOrFallback(_feedbackCopy?.pleaseWaitMessage, _l10n.loginPleaseWait),
      indicatorColor: LoginConstants.primaryColor,
    );
  }

  void _showLoadingDialog(BuildContext context) {
    AppLoadingDialog.show(
      title: _copyOrFallback(_feedbackCopy?.pleaseWaitMessage, _l10n.loginPleaseWait),
      indicatorColor: LoginConstants.primaryColor,
    );
  }

  void _closeLoadingDialog() {
    AppLoadingDialog.hide();
  }

  /// 登录成功后，静默同步隐私政策同意状态到后端
  ///
  /// 用户在首次启动时已通过 FirstLaunchPrivacyDialog 同意过法律文档，
  /// 这里只需要静默将同意状态同步到后端，不再弹窗。
  static void _schedulePrivacyPolicyCheck({bool markLocalConsent = false}) {
    Future.delayed(const Duration(milliseconds: 800), () async {
      try {
        final prefsRepo = Get.find<IUserPreferencesRepository>();
        if (markLocalConsent) {
          await FirstLaunchPrivacyDialog.markConsented();
        }
        final localConsented = await FirstLaunchPrivacyDialog.hasConsented();
        if (!localConsented) {
          log('⚠️ 本地未找到法律文档同意记录，跳过登录后静默同步');
          return;
        }

        if (markLocalConsent) {
          log('🔄 登录后按用户勾选显式同步法律文档状态到后端...');
          await prefsRepo.acceptPrivacyPolicy();
          await prefsRepo.acceptTermsOfService();
          log('✅ 登录后法律文档同意状态已显式同步到后端');
          return;
        }

        final preferences = await prefsRepo.getCurrentUserPreferences();

        if (!preferences.privacyPolicyAccepted) {
          log('🔄 登录后静默同步隐私政策同意状态到后端...');
          await prefsRepo.acceptPrivacyPolicy();
          log('✅ 隐私政策同意状态已同步到后端');
        }

        if (!preferences.termsOfServiceAccepted) {
          log('🔄 登录后静默同步用户协议同意状态到后端...');
          await prefsRepo.acceptTermsOfService();
          log('✅ 用户协议同意状态已同步到后端');
        }
      } catch (e) {
        log('⚠️ 登录后同步法律文档状态失败（不影响使用）: $e');
      }
    });
  }
}
