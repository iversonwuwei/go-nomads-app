import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/nomads_login_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'login_form_section.dart';
import 'social_login_section.dart';

/// 登录页面 - 使用 GetX + 组件化架构重构
class NomadsLoginPage extends StatelessWidget {
  const NomadsLoginPage({super.key});

  // Nomads.com 品牌红色 (用于外部引用)
  static const Color nomadsRed = NomadsLoginPageController.nomadsRed;
  static const String _controllerTag = 'nomads_login_controller';

  @override
  Widget build(BuildContext context) {
    // 注册 controller（固定 tag，避免键盘弹出导致 MediaQuery 变化触发重建时创建新 controller 而丢失焦点）
    final controller = Get.put(NomadsLoginPageController(), tag: _controllerTag);

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          Get.delete<NomadsLoginPageController>(tag: _controllerTag);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 返回按钮
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(FontAwesomeIcons.arrowLeft, color: nomadsRed),
                        onPressed: () => Get.offAllNamed('/'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Logo 和标题
                    _buildHeader(context),

                    const SizedBox(height: 48),

                    // 登录表单 (根据模式切换)
                    Obx(() {
                      if (controller.loginMode.value == LoginMode.phone) {
                        return PhoneLoginForm(controllerTag: _controllerTag);
                      } else {
                        return EmailLoginForm(controllerTag: _controllerTag);
                      }
                    }),

                    const SizedBox(height: 24),

                    // 社交登录
                    SocialLoginSection(controllerTag: _controllerTag),

                    const SizedBox(height: 32),

                    // 注册提示
                    _buildRegisterPrompt(),

                    const SizedBox(height: 32),

                    // 社区亮点
                    const CommunityHighlightSection(),

                    SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        children: [
          // Logo 图标
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: nomadsRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(FontAwesomeIcons.earthAmericas, size: 40, color: nomadsRed),
          ),
          const SizedBox(height: 24),

          // 标题
          Text(
            l10n.welcome,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),

          // 副标题
          Text(
            l10n.login,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterPrompt() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Let's Go", style: TextStyle(color: Colors.black87, fontSize: 15)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.register),
            child: const Text(
              "Register",
              style: TextStyle(color: nomadsRed, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
