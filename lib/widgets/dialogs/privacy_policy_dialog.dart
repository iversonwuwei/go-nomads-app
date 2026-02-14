import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/user/domain/repositories/i_user_preferences_repository.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';

/// 隐私政策同意对话框
///
/// 在用户登录成功后，检测用户是否已同意隐私政策。
/// 如果未同意，弹出此对话框：
/// - 用户同意 → 调用后端 API 记录同意状态，继续使用应用
/// - 用户拒绝 → 退出登录，返回登录页面
class PrivacyPolicyDialog {
  /// 检查用户是否已同意隐私政策，未同意则弹出对话框
  ///
  /// 返回 true 表示用户已同意（或之前已同意），false 表示用户拒绝
  static Future<bool> checkAndShowIfNeeded() async {
    try {
      final prefsRepo = Get.find<IUserPreferencesRepository>();
      final preferences = await prefsRepo.getCurrentUserPreferences();

      if (preferences.privacyPolicyAccepted) {
        log('✅ 用户已同意隐私政策，跳过弹窗');
        return true;
      }

      log('📋 用户未同意隐私政策，显示同意弹窗');
      return await _showDialog();
    } catch (e) {
      log('❌ 检查隐私政策状态失败: $e');
      // 如果获取失败，仍然显示对话框
      return await _showDialog();
    }
  }

  /// 显示隐私政策同意对话框
  static Future<bool> _showDialog() async {
    final result = await Get.dialog<bool>(
      const _PrivacyPolicyDialogWidget(),
      barrierDismissible: false,
    );

    return result ?? false;
  }
}

class _PrivacyPolicyDialogWidget extends StatefulWidget {
  const _PrivacyPolicyDialogWidget();

  @override
  State<_PrivacyPolicyDialogWidget> createState() => _PrivacyPolicyDialogWidgetState();
}

class _PrivacyPolicyDialogWidgetState extends State<_PrivacyPolicyDialogWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 640),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题栏
              _buildHeader(l10n),
              // 内容区域
              Flexible(child: _buildContent(l10n)),
              // 操作按钮
              _buildActions(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cityPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.cityPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n?.privacyPolicy ?? '隐私政策',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.privacyPolicyIntro ?? '欢迎使用行途（Go-Nomads）！为了为您提供更好的服务，我们需要您了解并同意以下隐私政策：',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),

          // 数据收集说明
          _buildSection(
            icon: Icons.analytics_outlined,
            title: l10n?.privacyDataCollection ?? '数据收集',
            content: l10n?.privacyDataCollectionDesc ?? '我们会收集您的行为数据（如浏览记录、搜索偏好、功能使用频率等），以便优化产品体验和个性化推荐。',
          ),

          _buildSection(
            icon: Icons.location_on_outlined,
            title: l10n?.privacyLocationData ?? '位置信息',
            content: l10n?.privacyLocationDataDesc ?? '我们会收集您的位置数据，用于提供城市推荐、附近的共享办公空间和活动信息、以及旅行足迹记录等功能。',
          ),

          _buildSection(
            icon: Icons.person_outline,
            title: l10n?.privacyPersonalData ?? '个人信息',
            content: l10n?.privacyPersonalDataDesc ?? '我们会收集您的基本个人信息（如昵称、头像、联系方式等），用于账号管理和社交功能。',
          ),

          _buildSection(
            icon: Icons.security_outlined,
            title: l10n?.privacyDataProtection ?? '数据保护',
            content: l10n?.privacyDataProtectionDesc ?? '我们承诺采用行业标准的安全措施保护您的个人数据，不会将您的数据出售给第三方。您可以随时在"设置"中管理您的隐私偏好。',
          ),

          // 第三方SDK说明
          _buildSection(
            icon: Icons.extension_outlined,
            title: '第三方服务',
            content: '为实现相关功能，本应用集成了以下第三方服务SDK：\n'
                '• 高德地图SDK — 地图显示和定位服务\n'
                '• 微信OpenSDK — 微信登录和分享\n'
                '• QQ互联SDK — QQ登录和分享\n'
                '• 支付宝SDK — 支付功能\n'
                '• 腾讯云IM SDK — 即时通信服务\n'
                '• Google Location — 海外定位服务\n'
                '上述第三方SDK可能会按照其各自的隐私政策收集必要信息。',
          ),

          // 权限使用说明
          _buildSection(
            icon: Icons.verified_user_outlined,
            title: '权限使用说明',
            content: '本应用使用以下权限：\n'
                '• 位置权限 — 城市推荐、附近活动、旅行足迹\n'
                '• 日历权限 — 将活动添加到日历\n'
                '• 通知权限 — 消息提醒和活动通知\n'
                '所有权限均在使用对应功能时才会申请，您可随时在系统设置中管理。',
          ),

          const SizedBox(height: 12),

          // 底部提示
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.privacyPolicyNote ?? '如果您不同意以上隐私政策，将无法继续使用本应用。您可以随时在设置中查看完整的隐私政策。',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[800],
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 查看完整条款的链接
          Center(
            child: RichText(
              text: TextSpan(
                text: l10n?.viewFullTerms ?? '查看完整的',
                style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                children: [
                  TextSpan(
                    text: l10n?.termsOfService ?? '服务条款',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(AppRoutes.termsOfService);
                      },
                  ),
                  TextSpan(
                    text: l10n?.and ?? ' 和 ',
                    style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                  ),
                  TextSpan(
                    text: l10n?.communityGuidelines ?? '社区准则',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.accent,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        Get.toNamed(AppRoutes.communityGuidelinesPage);
                      },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.containerLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          // 同意按钮
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onAgree,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      l10n?.agreeAndContinue ?? '同意并继续',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 10),
          // 拒绝按钮
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _onDecline,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n?.disagreeAndExit ?? '不同意并退出',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onAgree() async {
    setState(() => _isLoading = true);

    try {
      final prefsRepo = Get.find<IUserPreferencesRepository>();
      await prefsRepo.acceptPrivacyPolicy();
      log('✅ 隐私政策同意状态已保存到服务器');

      if (mounted) {
        Get.back(result: true);
      }
    } catch (e) {
      log('❌ 保存隐私政策同意状态失败: $e');
      AppToast.error('操作失败，请重试');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onDecline() async {
    log('❌ 用户拒绝隐私政策');

    // 退出登录
    try {
      final authController = Get.find<AuthStateController>();
      await authController.logout();
    } catch (e) {
      log('⚠️ 退出登录异常: $e');
    }

    // 关闭对话框并返回 false
    Get.back(result: false);

    // 导航到登录页面
    Get.offAllNamed(AppRoutes.login);
  }
}
