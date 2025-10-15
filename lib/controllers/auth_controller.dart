import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/app_toast.dart';

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

class AuthController extends GetxController {
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

  // 状态管理
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreeToTerms = false.obs;

  // 验证码相关
  var codeCountdown = 0.obs;
  var canSendCode = true.obs;

  // 表单验证
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    codeController.dispose();
    nameController.dispose();
    super.onClose();
  }

  // 切换认证模式
  void switchAuthMode(AuthMode mode) {
    authMode.value = mode;
    clearForm();
  }

  // 切换登录方式
  void switchLoginType(LoginType type) {
    loginType.value = type;
    clearForm();
  }

  // 清空表单
  void clearForm() {
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    codeController.clear();
    nameController.clear();
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  // 切换密码可见性
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // 切换同意条款
  void toggleAgreement() {
    agreeToTerms.value = !agreeToTerms.value;
  }

  // 发送验证码
  void sendVerificationCode() async {
    if (!_validatePhone()) return;

    canSendCode.value = false;
    codeCountdown.value = 60;

    // 模拟发送验证码
    AppToast.success(
      '验证码已发送至 ${phoneController.text}',
      title: '验证码已发送',
    );

    // 倒计时
    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      codeCountdown.value = i - 1;
    }

    canSendCode.value = true;
  }

  // 手机号验证
  bool _validatePhone() {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      AppToast.error('请输入手机号', title: '错误');
      return false;
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(phone)) {
      AppToast.error('请输入正确的手机号', title: '错误');
      return false;
    }
    return true;
  }

  // 密码验证
  bool _validatePassword() {
    final password = passwordController.text;
    if (password.isEmpty) {
      AppToast.error('请输入密码', title: '错误');
      return false;
    }
    if (password.length < 6) {
      AppToast.error('密码长度不能少于6位', title: '错误');
      return false;
    }
    return true;
  }

  // 验证码验证
  bool _validateCode() {
    final code = codeController.text.trim();
    if (code.isEmpty) {
      AppToast.error('请输入验证码', title: '错误');
      return false;
    }
    if (code.length != 6) {
      AppToast.error('请输入6位验证码', title: '错误');
      return false;
    }
    return true;
  }

  // 登录
  void login() async {
    if (isLoading.value) return;

    bool isValid = false;

    switch (loginType.value) {
      case LoginType.phonePassword:
        isValid = _validatePhone() && _validatePassword();
        break;
      case LoginType.phoneCode:
        isValid = _validatePhone() && _validateCode();
        break;
      default:
        isValid = true;
    }

    if (!isValid) return;

    isLoading.value = true;

    try {
      // 模拟登录请求
      await Future.delayed(const Duration(seconds: 2));

      AppToast.success(
        '欢迎回来！',
        title: '登录成功',
      );

      // 跳转到主页
      Get.offAllNamed('/');
    } catch (e) {
      AppToast.error('请检查网络连接后重试', title: '登录失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 注册
  void register() async {
    if (isLoading.value) return;

    if (!_validatePhone() || !_validatePassword() || !_validateCode()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      AppToast.error('两次输入的密码不一致', title: '错误');
      return;
    }

    if (!agreeToTerms.value) {
      AppToast.error('请先同意用户协议和隐私政策', title: '错误');
      return;
    }

    isLoading.value = true;

    try {
      // 模拟注册请求
      await Future.delayed(const Duration(seconds: 2));

      AppToast.success(
        '账号注册成功，欢迎加入！',
        title: '注册成功',
      );

      // 跳转到主页
      Get.offAllNamed('/');
    } catch (e) {
      AppToast.error('请检查网络连接后重试', title: '注册失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 找回密码
  void resetPassword() async {
    if (isLoading.value) return;

    if (!_validatePhone() || !_validateCode() || !_validatePassword()) {
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      AppToast.error('两次输入的密码不一致', title: '错误');
      return;
    }

    isLoading.value = true;

    try {
      // 模拟重置密码请求
      await Future.delayed(const Duration(seconds: 2));

      AppToast.success(
        '密码已重置，请使用新密码登录',
        title: '密码重置成功',
      );

      // 切换到登录模式
      switchAuthMode(AuthMode.login);
    } catch (e) {
      AppToast.error('请检查网络连接后重试', title: '重置失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 第三方登录
  void thirdPartyLogin(LoginType type) async {
    if (isLoading.value) return;

    isLoading.value = true;

    String platform = '';
    switch (type) {
      case LoginType.wechat:
        platform = '微信';
        break;
      case LoginType.alipay:
        platform = '支付宝';
        break;
      default:
        break;
    }

    try {
      // 模拟第三方登录
      await Future.delayed(const Duration(seconds: 2));

      AppToast.success(
        '通过$platform登录成功！',
        title: '登录成功',
      );

      // 跳转到主页
      Get.offAllNamed('/');
    } catch (e) {
      AppToast.error('$platform登录失败，请重试', title: '登录失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 表单验证器
  String? phoneValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入手机号';
    }
    if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
      return '请输入正确的手机号';
    }
    return null;
  }

  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入密码';
    }
    if (value.length < 6) {
      return '密码长度不能少于6位';
    }
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请确认密码';
    }
    if (value != passwordController.text) {
      return '两次输入的密码不一致';
    }
    return null;
  }

  String? codeValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入验证码';
    }
    if (value.length != 6) {
      return '请输入6位验证码';
    }
    return null;
  }

  String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return '请输入姓名';
    }
    if (value.length < 2) {
      return '姓名长度不能少于2位';
    }
    return null;
  }
}
