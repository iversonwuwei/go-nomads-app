import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/change_password_page_controller.dart';
import 'package:go_nomads_app/pages/change_password/widgets/change_password_email_section.dart';
import 'package:go_nomads_app/pages/change_password/widgets/change_password_form.dart';
import 'package:go_nomads_app/pages/change_password/widgets/change_password_submit_button.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

/// 修改/设置密码页面 / Change or set password page
class ChangePasswordPage extends GetView<ChangePasswordController> {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const AppBackButton(),
        title: Obx(() => Text(
              controller.hasPassword.value ? '修改密码' : '设置密码',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isCheckingPassword.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return const SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              ChangePasswordEmailSection(),
              SizedBox(height: 24),
              ChangePasswordForm(),
              SizedBox(height: 32),
              ChangePasswordSubmitButton(),
            ],
          ),
        );
      }),
    );
  }
}
