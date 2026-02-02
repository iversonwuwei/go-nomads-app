import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/pages/register/register_constants.dart';
import 'package:go_nomads_app/pages/register/register_controller.dart';
import 'package:go_nomads_app/pages/register/widgets/register_feature_highlights.dart';
import 'package:go_nomads_app/pages/register/widgets/register_form.dart';
import 'package:go_nomads_app/pages/register/widgets/register_header.dart';
import 'package:go_nomads_app/pages/register/widgets/register_login_link.dart';
import 'package:go_nomads_app/pages/register/widgets/register_submit_button.dart';
import 'package:go_nomads_app/pages/register/widgets/register_terms_checkbox.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 注册页面 - 使用响应式验证，无需 GlobalKey
class RegisterPage extends GetView<RegisterController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: RegisterConstants.pagePadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo 和标题
                const RegisterHeader(),

                const SizedBox(height: 48),

                // 表单输入 (响应式验证，无需 Form widget)
                const RegisterForm(),

                const SizedBox(height: 24),

                // 服务条款复选框
                const RegisterTermsCheckbox(),

                const SizedBox(height: 32),

                // 注册按钮
                const RegisterSubmitButton(),

                const SizedBox(height: 32),

                // 已有账号提示
                const RegisterLoginLink(),

                const SizedBox(height: 24),

                // 社区亮点
                const RegisterFeatureHighlights(),

                const SizedBox(height: 24),

                // ICP 备案信息
                const CopyrightWidget(),

                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
