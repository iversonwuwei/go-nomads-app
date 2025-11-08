import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/auth/presentation/controllers/auth_state_controller.dart';
import '../../widgets/app_toast.dart';

enum LoginType {
  phonePassword,
  phoneCode,
  wechat,
  alipay,
}

enum AuthMode {
  login,
  register,
  forgotPassword,
}

/// 登录表单UI控制器
/// 负责管理表单状态、验证码倒计时等UI逻辑
/// 认证业务逻辑委托给 AuthStateController
class LoginFormController extends GetxController {
  // 注入认证状态控制器
  late final AuthStateController _authStateController;

  // 当前认证模式
  var authMode = AuthMode.login.obs;

  // 当前登录方式
  var loginType = LoginType.phonePassword.obs;

  // 表单控制器
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final codeController = TextEditingController();
  final nameController = TextEditingController();

  // UI状态管理
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreeToTerms = false.obs;

  // 验证码相关
  var codeCountdown = 0.obs;
  var canSendCode = true.obs;

  // 表单验证
  final formKey = GlobalKey<FormState>();

  // 从 AuthStateController 获取加载状态
  bool get isLoading => _authStateController.isLoading.value;

  @override
  void onInit() {
    super.onInit();
    _authStateController = Get.find<AuthStateController>();
  }

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // ==================== UI 逻辑 ====================

  /// 切换认证模式
  void switchAuthMode(AuthMode mode) {
    authMode.value = mode;
    clearForm();
  }

  /// 切换登录方式
  void switchLoginType(LoginType type) {
    loginType.value = type;
    clearForm();
  }

  /// 清空表单
  void clearForm() {
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    codeController.clear();
    nameController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  /// 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  /// 切换同意条款
  void toggleAgreement() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  /// 发送验证码
  Future<void> sendVerificationCode() async {
    if (!_validatePhone()) return;

    canSendCode.value = false;
    codeCountdown.value = 60;

    // TODO: 调用发送验证码的 Use Case
    AppToast.success('验证码已发送');

    // 倒计时
    _startCountdown();
  }

  /// 开始倒计时
  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (codeCountdown.value > 0) {
        codeCountdown.value--;
        _startCountdown();
      } else {
        canSendCode.value = true;
      }
    });
  }

  // ==================== 验证逻辑 ====================

  /// 表单验证器 - 手机号
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入用户名/邮箱/手机号';
    }
    // 接受任何格式：用户名、邮箱或手机号
    return null;
  }

  /// 表单验证器 - 密码
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    return null;
  }

  /// 表单验证器 - 确认密码
  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  /// 表单验证器 - 验证码
  String? codeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6) {
      return '请输入6位验证码';
    }
    return null;
  }

  /// 表单验证器 - 姓名
  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length < 2) {
      return '姓名长度不能少于2位';
    }
    return null;
  }

  /// 验证手机号
  bool _validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.error('请输入手机号');
      return false;
    }
    if (!GetUtils.isPhoneNumber(phone)) {
      AppToast.error('请输入正确的手机号');
      return false;
    }
    return true;
  }

  /// 验证密码
  bool _validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      AppToast.error('请输入密码');
      return false;
    }
    if (password.length < 6) {
      AppToast.error('密码长度不能少于6位');
      return false;
    }
    return true;
  }

  /// 验证注册表单
  bool _validateRegisterForm() {
    if (nameController.text.trim().isEmpty) {
      AppToast.error('请输入用户名');
      return false;
    }
    if (!_validatePhone()) return false;
    if (!_validatePassword()) return false;

    final confirmPassword = confirmPasswordController.text;
    if (confirmPassword.isEmpty) {
      AppToast.error('请确认密码');
      return false;
    }
    if (passwordController.text != confirmPassword) {
      AppToast.error('两次输入的密码不一致');
      return false;
    }
    if (!agreeToTerms.value) {
      AppToast.error('请同意用户协议和隐私政策');
      return false;
    }
    return true;
  }

  // ==================== 认证业务逻辑(委托) ====================

  /// 登录
  Future<void> login() async {
    if (loginType.value == LoginType.phonePassword) {
      await _loginWithPassword();
    } else if (loginType.value == LoginType.phoneCode) {
      await _loginWithCode();
    }
  }

  /// 密码登录
  Future<void> _loginWithPassword() async {
    if (!_validatePhone()) return;
    if (!_validatePassword()) return;

    final email = phoneController.text.trim();
    final password = passwordController.text;

    // 委托给 AuthStateController
    final success = await _authStateController.login(
      email: email,
      password: password,
    );

    if (success) {
      AppToast.success('登录成功');
      // 页面跳转由路由守卫或上层处理
      Get.offAllNamed('/main');
    }
  }

  /// 验证码登录
  Future<void> _loginWithCode() async {
    if (!_validatePhone()) return;

    final code = codeController.text.trim();
    if (code.isEmpty) {
      AppToast.error('请输入验证码');
      return;
    }

    // TODO: 实现验证码登录 Use Case
    AppToast.info('验证码登录功能开发中');
  }

  /// 注册
  Future<void> register() async {
    if (!_validateRegisterForm()) return;

    final name = nameController.text.trim();
    final email = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // 委托给 AuthStateController
    final success = await _authStateController.register(
      name: name,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (success) {
      AppToast.success('注册成功');
      Get.offAllNamed('/main');
    }
  }

  /// 忘记密码
  Future<void> resetPassword() async {
    if (!_validatePhone()) return;

    final code = codeController.text.trim();
    if (code.isEmpty) {
      AppToast.error('请输入验证码');
      return;
    }

    // TODO: 实现重置密码 Use Case
    AppToast.info('重置密码功能开发中');
  }

  /// 第三方登录
  Future<void> loginWithThirdParty(LoginType type) async {
    // TODO: 实现第三方登录
    AppToast.info('第三方登录功能开发中');
  }
}
