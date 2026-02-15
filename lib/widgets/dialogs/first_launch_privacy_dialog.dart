import 'dart:developer';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/legal/privacy_policy_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动隐私政策弹窗 key
const String _kPrivacyConsentKey = 'first_launch_privacy_consented';

/// 首次启动隐私政策同意对话框
///
/// 工信部合规要求：APP首次启动时，必须在任何数据收集或SDK初始化之前，
/// 向用户展示隐私政策弹窗，提供明确的"同意"和"不同意"按钮。
/// - 用户点击"同意" → 记录本地同意状态，继续初始化
/// - 用户点击"不同意" → 可合理挽留（再次询问），若仍不同意则退出应用
/// - 不可出现死循环弹窗
class FirstLaunchPrivacyDialog {
  /// 检查用户是否已在本地同意过首次启动隐私政策
  static Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kPrivacyConsentKey) ?? false;
  }

  /// 记录用户已同意
  static Future<void> _saveConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyConsentKey, true);
  }

  /// 外部调用：标记本地已同意隐私政策（用于后端已同意但本地未记录的场景）
  static Future<void> markConsented() async {
    await _saveConsent();
  }

  /// 显示首次启动隐私政策弹窗
  ///
  /// 返回 true 表示用户同意，false 表示用户拒绝
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _FirstLaunchPrivacyDialogWidget(),
    );

    if (result == true) {
      await _saveConsent();
      log('✅ 用户同意首次启动隐私政策');
      return true;
    }
    
    log('❌ 用户拒绝首次启动隐私政策');
    return false;
  }
}

class _FirstLaunchPrivacyDialogWidget extends StatelessWidget {
  const _FirstLaunchPrivacyDialogWidget();

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
              _buildHeader(l10n),
              Flexible(child: _buildContent(context, l10n)),
              _buildActions(context, l10n),
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

  Widget _buildContent(BuildContext context, AppLocalizations? l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.privacyPolicyIntro ??
                '欢迎使用行途（Go-Nomads）！为了为您提供更好的服务，我们需要您了解并同意以下隐私政策：',
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
            content: l10n?.privacyDataCollectionDesc ??
                '我们会收集您的行为数据（如浏览记录、搜索偏好、功能使用频率等），以便优化产品体验和个性化推荐。',
          ),

          _buildSection(
            icon: Icons.location_on_outlined,
            title: l10n?.privacyLocationData ?? '位置信息',
            content: l10n?.privacyLocationDataDesc ??
                '我们会收集您的位置数据，用于提供城市推荐、附近的共享办公空间和活动信息、以及旅行足迹记录等功能。',
          ),

          _buildSection(
            icon: Icons.person_outline,
            title: l10n?.privacyPersonalData ?? '个人信息',
            content: l10n?.privacyPersonalDataDesc ??
                '我们会收集您的基本个人信息（如昵称、头像、联系方式等），用于账号管理和社交功能。',
          ),

          _buildSection(
            icon: Icons.security_outlined,
            title: l10n?.privacyDataProtection ?? '数据保护',
            content: l10n?.privacyDataProtectionDesc ??
                '我们承诺采用行业标准的安全措施保护您的个人数据，不会将您的数据出售给第三方。您可以随时在"设置"中管理您的隐私偏好。',
          ),

          // 第三方SDK说明
          _buildSection(
            icon: Icons.extension_outlined,
            title: l10n?.thirdPartyServices ?? '第三方服务',
            content: l10n?.thirdPartyServicesDesc ??
                '为实现相关功能，本应用集成了以下第三方服务SDK：\n'
                    '• 高德地图/定位SDK（高德软件）— 地图显示和定位服务，可能收集位置信息\n'
                    '• 微信OpenSDK（腾讯）— 微信登录和分享\n'
                    '• 抖音开放平台SDK（字节跳动）— 抖音登录\n'
                    '• 腾讯云IM SDK（腾讯）— 即时通信服务\n'
                    '• Google Location/Login（Google）— 海外定位和登录服务\n'
                    '上述SDK可能按照各自隐私政策收集必要信息，详见隐私政策全文。',
          ),

          // 权限使用说明
          _buildSection(
            icon: Icons.verified_user_outlined,
            title: l10n?.permissionUsage ?? '权限使用说明',
            content: l10n?.permissionUsageDesc ??
                '本应用使用以下权限：\n'
                    '• 位置权限 — 城市推荐、附近活动、旅行足迹\n'
                    '• 相机权限 — 拍摄头像和社区内容图片\n'
                    '• 相册权限 — 选择头像和社区图片\n'
                    '• 麦克风权限 — 聊天语音消息录制\n'
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
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: l10n?.privacyPolicyNote ??
                              '如果您不同意以上隐私政策，将无法继续使用本应用。您可以随时在设置中查看完整的',
                        ),
                        TextSpan(
                          text: l10n?.privacyPolicy ?? '隐私政策',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openPrivacyPolicyUrl(context);
                            },
                        ),
                        const TextSpan(text: '。'),
                      ],
                    ),
                  ),
                ),
              ],
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

  Widget _buildActions(BuildContext context, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        children: [
          // 同意按钮
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Text(
                l10n?.agreeAndContinue ?? '同意',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 不同意按钮
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                _onDecline(context, l10n);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n?.disagreeAndExit ?? '不同意',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 用户点击"不同意"时，合理挽留一次，不循环弹窗
  void _onDecline(BuildContext context, AppLocalizations? l10n) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          l10n?.privacyDeclineTitle ?? '温馨提示',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n?.privacyDeclineMessage ??
              '如果您不同意隐私政策，将无法使用本应用的相关功能。'
                  '\n\n我们非常重视您的隐私安全，收集的信息仅用于为您提供更好的服务。'
                  '\n\n您确定不同意吗？',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 用户选择"查看隐私政策"（回到主弹窗）
              Navigator.of(ctx).pop(false);
            },
            child: Text(
              l10n?.reconsider ?? '再想想',
              style: const TextStyle(color: AppColors.cityPrimary),
            ),
          ),
          TextButton(
            onPressed: () {
              // 用户确认不同意 → 退出应用
              Navigator.of(ctx).pop(true);
            },
            child: Text(
              l10n?.confirmExit ?? '确认退出',
              style: const TextStyle(color: AppColors.textTertiary),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        // 用户确认不同意，退出应用
        Navigator.of(context).pop(false);
        _exitApp();
      }
      // 否则用户选择"再想想"，回到隐私政策弹窗，不循环不重复
    });
  }

  /// 退出应用
  void _exitApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  /// 打开隐私政策页面
  void _openPrivacyPolicyUrl(BuildContext context) {
    log('🔗 用户点击查看隐私政策');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PrivacyPolicyPage(),
      ),
    );
  }
}
