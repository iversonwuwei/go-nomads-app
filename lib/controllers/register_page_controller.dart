import 'dart:developer';

import 'package:df_admin_mobile/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// RegisterPage 控制器
class RegisterPageController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();

  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxBool agreeToTerms = false.obs;
  final RxBool isRegistering = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    super.onClose();
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

  /// 注册
  Future<void> register({
    required String termsRequiredTitle,
    required String pleaseAgreeToTerms,
    required String welcomeToCommunity,
    required String successTitle,
  }) async {
    if (!formKey.currentState!.validate()) {
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
      );

      if (success) {
        final user = authController.currentUser.value;
        log('✅ 注册成功: ${user?.name}');

        AppToast.success(
          welcomeToCommunity,
          title: successTitle,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/');
      } else {
        log('❌ 注册失败');
        AppToast.error(
          '注册失败,请检查输入信息',
          title: '注册失败',
        );
      }
    } on HttpException catch (e) {
      log('❌ 注册失败 (HttpException): ${e.message}');
      AppToast.error(
        e.message,
        title: '注册失败',
      );
    } catch (e) {
      log('❌ 注册错误: $e');
      AppToast.error(
        '注册过程中发生错误，请稍后重试',
        title: '错误',
      );
    } finally {
      isRegistering.value = false;
    }
  }
}
