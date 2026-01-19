import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'package:go_nomads_app/controllers/register_page_controller.dart';

/// 注册页面
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const Color nomadsRed = Color(0xFFFF4458);

  static const String _tag = 'RegisterPage';

  RegisterPageController _useController() {
    if (Get.isRegistered<RegisterPageController>(tag: _tag)) {
      return Get.find<RegisterPageController>(tag: _tag);
    }
    return Get.put(RegisterPageController(), tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
                  const SizedBox(height: 40),

                  // Logo 和标题
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: nomadsRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            FontAwesomeIcons.earthAmericas,
                            size: 40,
                            color: nomadsRed,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '🌍 ${l10n.goNomad}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.joinGlobalCommunity,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // 用户名输入
                  TextFormField(
                    controller: controller.usernameController,
                    decoration: InputDecoration(
                      labelText: l10n.username,
                      hintText: l10n.chooseUsername,
                      prefixIcon: const Icon(FontAwesomeIcons.user),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: nomadsRed, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.usernameRequired;
                      }
                      if (value.length < 3) {
                        return l10n.usernameMinLength;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 邮箱输入
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      hintText: l10n.email,
                      prefixIcon: const Icon(FontAwesomeIcons.envelope),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: nomadsRed, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.email;
                      }
                      if (!GetUtils.isEmail(value)) {
                        return l10n.email;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // 密码输入
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        decoration: InputDecoration(
                          labelText: l10n.password,
                          hintText: l10n.createPassword,
                          prefixIcon: const Icon(FontAwesomeIcons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscurePassword.value ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                            ),
                            onPressed: controller.toggleObscurePassword,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: nomadsRed, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.password;
                          }
                          if (value.length < 6) {
                            return l10n.password;
                          }
                          return null;
                        },
                      )),

                  const SizedBox(height: 20),

                  // 确认密码输入
                  Obx(() => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          hintText: l10n.reenterPassword,
                          prefixIcon: const Icon(FontAwesomeIcons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureConfirmPassword.value ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash,
                            ),
                            onPressed: controller.toggleObscureConfirmPassword,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: nomadsRed, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return l10n.confirmPasswordRequired;
                          }
                          if (value != controller.passwordController.text) {
                            return l10n.passwordsNotMatch;
                          }
                          return null;
                        },
                      )),

                  const SizedBox(height: 24),

                  // 服务条款复选框
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Checkbox(
                            value: controller.agreeToTerms.value,
                            onChanged: (value) => controller.toggleAgreeToTerms(value),
                            activeColor: nomadsRed,
                          )),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: GestureDetector(
                            onTap: () => controller.toggleAgreeToTerms(),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(fontSize: 14, color: Colors.black87),
                                children: [
                                  TextSpan(text: '${l10n.agreeToTerms} '),
                                  TextSpan(
                                    text: l10n.termsOfService,
                                    style: const TextStyle(
                                      color: nomadsRed,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  TextSpan(text: ' ${l10n.and} '),
                                  TextSpan(
                                    text: l10n.communityGuidelines,
                                    style: const TextStyle(
                                      color: nomadsRed,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // 注册按钮
                  Obx(() => ElevatedButton(
                        onPressed: controller.isRegistering.value
                            ? null
                            : () => controller.register(
                                  termsRequiredTitle: l10n.termsRequired,
                                  pleaseAgreeToTerms: l10n.pleaseAgreeToTerms,
                                  welcomeToCommunity: l10n.welcomeToCommunity,
                                  successTitle: l10n.success,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: nomadsRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey.shade400,
                        ),
                        child: controller.isRegistering.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                l10n.joinNomads,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                      )),

                  const SizedBox(height: 32),

                  // 已有账号提示
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.alreadyHaveAccount} ',
                          style: const TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(AppRoutes.login),
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              color: nomadsRed,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 社区亮点
                  _buildFeatureHighlights(context, l10n),

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.joinMembers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('🍹', l10n.attendMeetups, l10n.inCitiesWorldwide),
          const SizedBox(height: 12),
          _buildFeatureItem('❤️', l10n.meetNewPeople, l10n.forDatingAndFriends),
          const SizedBox(height: 12),
          _buildFeatureItem('🧪', l10n.researchDestinations, l10n.findBestPlace),
          const SizedBox(height: 12),
          _buildFeatureItem('💬', l10n.joinExclusiveChat, l10n.messagesSentThisMonth),
          const SizedBox(height: 12),
          _buildFeatureItem('🗺️', l10n.trackTravels, l10n.shareJourney),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
