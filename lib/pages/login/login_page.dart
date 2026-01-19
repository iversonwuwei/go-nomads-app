import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/login/login_constants.dart';
import 'package:go_nomads_app/pages/login/login_controller.dart';
import 'package:go_nomads_app/pages/login/widgets/login_community_highlight.dart';
import 'package:go_nomads_app/pages/login/widgets/login_email_form.dart';
import 'package:go_nomads_app/pages/login/widgets/login_header.dart';
import 'package:go_nomads_app/pages/login/widgets/login_phone_form.dart';
import 'package:go_nomads_app/pages/login/widgets/login_register_link.dart';
import 'package:go_nomads_app/pages/login/widgets/login_social_buttons.dart';

/// 登录页面 - 使用响应式验证，无需 GlobalKey
class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: LoginConstants.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo 和标题
                const LoginHeader(),

                const SizedBox(height: 48),

                // 根据登录模式显示不同表单
                Obx(() =>
                    controller.loginMode.value == LoginMode.phone ? const LoginPhoneForm() : const LoginEmailForm()),

                const SizedBox(height: 24),

                // 社交登录按钮
                Obx(() => controller.loginMode.value == LoginMode.email
                    ? const LoginSocialButtons()
                    : const SizedBox.shrink()),

                const SizedBox(height: 32),

                // 注册提示
                const LoginRegisterLink(),

                const SizedBox(height: 32),

                // 社区亮点
                const LoginCommunityHighlight(),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
