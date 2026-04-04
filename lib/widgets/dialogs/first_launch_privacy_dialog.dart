import 'dart:developer';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/legal_document.dart';
import 'package:go_nomads_app/pages/legal/privacy_policy_page.dart';
import 'package:go_nomads_app/pages/legal/sdk_list_page.dart';
import 'package:go_nomads_app/pages/legal/terms_of_service_page.dart';
import 'package:go_nomads_app/services/legal_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 首次启动隐私政策弹窗 key
const String _kPrivacyConsentKey = 'first_launch_privacy_consented';
const String _kTermsConsentKey = 'first_launch_terms_consented';
const String _kPrivacyConsentVersionKey = 'first_launch_privacy_consented_version';
const String _kTermsConsentVersionKey = 'first_launch_terms_consented_version';
const String _kCurrentPrivacyPolicyVersion = '1.0.0';
const String _kCurrentTermsOfServiceVersion = '1.0.0';

/// 首次启动隐私政策同意对话框
///
/// 工信部合规要求：APP首次启动时，必须在任何数据收集或SDK初始化之前，
/// 向用户展示隐私政策弹窗，提供明确的"同意"和"不同意"按钮。
/// - 用户点击"同意" → 记录本地同意状态，继续初始化
/// - 用户点击"不同意" → 可合理挽留（再次询问），若仍不同意则退出应用
/// - 不可出现死循环弹窗
class FirstLaunchPrivacyDialog {
  /// 检查用户是否已在本地同意过首次启动法律文档
  static Future<bool> hasConsented() async {
    final prefs = await SharedPreferences.getInstance();
    final privacyConsented = prefs.getBool(_kPrivacyConsentKey) ?? false;
    final termsConsented = prefs.getBool(_kTermsConsentKey) ?? false;
    final privacyVersion = prefs.getString(_kPrivacyConsentVersionKey) ?? '';
    final termsVersion = prefs.getString(_kTermsConsentVersionKey) ?? '';
    return privacyConsented && termsConsented && privacyVersion.isNotEmpty && termsVersion.isNotEmpty;
  }

  /// 记录用户已同意隐私政策和用户协议
  static Future<void> _saveConsent({
    String privacyVersion = _kCurrentPrivacyPolicyVersion,
    String termsVersion = _kCurrentTermsOfServiceVersion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrivacyConsentKey, true);
    await prefs.setBool(_kTermsConsentKey, true);
    await prefs.setString(_kPrivacyConsentVersionKey, privacyVersion);
    await prefs.setString(_kTermsConsentVersionKey, termsVersion);
  }

  /// 外部调用：标记本地已同意法律文档（用于后端已同意但本地未记录的场景）
  static Future<void> markConsented({
    String privacyVersion = _kCurrentPrivacyPolicyVersion,
    String termsVersion = _kCurrentTermsOfServiceVersion,
  }) async {
    await _saveConsent(privacyVersion: privacyVersion, termsVersion: termsVersion);
  }

  /// 清除本地同意状态（用于后端重置/文档版本更新时强制重新确认）
  static Future<void> clearConsent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrivacyConsentKey);
    await prefs.remove(_kTermsConsentKey);
    await prefs.remove(_kPrivacyConsentVersionKey);
    await prefs.remove(_kTermsConsentVersionKey);
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
      log('✅ 用户同意首次启动法律文档');
      return true;
    }

    log('❌ 用户拒绝首次启动法律文档');
    return false;
  }
}

class _FirstLaunchPrivacyDialogWidget extends StatefulWidget {
  const _FirstLaunchPrivacyDialogWidget();

  @override
  State<_FirstLaunchPrivacyDialogWidget> createState() => _FirstLaunchPrivacyDialogWidgetState();
}

class _FirstLaunchPrivacyDialogWidgetState extends State<_FirstLaunchPrivacyDialogWidget> {
  List<LegalSummary>? _summaryItems;
  bool _isLoading = true;
  bool _privacyChecked = false;
  bool _termsChecked = false;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final doc = await LegalService().getPrivacyPolicy();
    if (mounted) {
      setState(() {
        _summaryItems = doc?.summary;
        _isLoading = false;
      });
    }
  }

  /// 将后端返回的 icon 名称字符串映射为 Material IconData
  static final Map<String, IconData> _iconMap = {
    'analytics_outlined': Icons.analytics_outlined,
    'location_on_outlined': Icons.location_on_outlined,
    'person_outline': Icons.person_outline,
    'security_outlined': Icons.security_outlined,
    'extension_outlined': Icons.extension_outlined,
    'verified_user_outlined': Icons.verified_user_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 640.h),
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
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.cityPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.privacy_tip_outlined,
              color: AppColors.cityPrimary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '服务协议与隐私政策',
              style: TextStyle(
                fontSize: 18.sp,
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
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '欢迎使用行途（Go-Nomads）！为了继续使用应用，请您阅读并同意《隐私政策》和《用户协议》。',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
          SizedBox(height: 16.h),

          // 动态渲染摘要项（从 API 加载）或显示加载状态
          if (_isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2.w)),
            )
          else if (_summaryItems != null && _summaryItems!.isNotEmpty)
            ..._summaryItems!.map((item) => _buildSection(
                  icon: _iconMap[item.icon] ?? Icons.info_outline,
                  title: item.title,
                  content: item.content,
                ))
          else
            // API 加载失败时的兜底文案
            _buildSection(
              icon: Icons.info_outline,
              title: '法律文档说明',
              content: '我们重视您的隐私与使用权益。请查看完整隐私政策、用户协议和第三方 SDK 清单。',
            ),

          SizedBox(height: 12.h),

          _buildConsentCheckbox(
            checked: _privacyChecked,
            onChanged: (value) {
              setState(() {
                _privacyChecked = value ?? false;
              });
            },
            leadingText: '我已阅读并同意',
            linkText: '《隐私政策》',
            onTapLink: () => _openPrivacyPolicyUrl(context),
          ),
          SizedBox(height: 8.h),
          _buildConsentCheckbox(
            checked: _termsChecked,
            onChanged: (value) {
              setState(() {
                _termsChecked = value ?? false;
              });
            },
            leadingText: '我已阅读并同意',
            linkText: '《用户协议》',
            onTapLink: () => _openTermsOfServiceUrl(context),
          ),

          SizedBox(height: 12.h),

          // 底部提示
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 18.r),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.amber[800],
                        height: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: '如果您不同意上述法律文档，将无法继续使用本应用。您可以随时在设置中查看完整的',
                        ),
                        TextSpan(
                          text: l10n?.privacyPolicy ?? '隐私政策',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber[900],
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openPrivacyPolicyUrl(context);
                            },
                        ),
                        const TextSpan(text: '、'),
                        TextSpan(
                          text: '用户协议',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber[900],
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openTermsOfServiceUrl(context);
                            },
                        ),
                        const TextSpan(text: '和'),
                        TextSpan(
                          text: '第三方SDK清单',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber[900],
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              _openSdkListPage(context);
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

  Widget _buildConsentCheckbox({
    required bool checked,
    required ValueChanged<bool?> onChanged,
    required String leadingText,
    required String linkText,
    required VoidCallback onTapLink,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: checked,
          onChanged: onChanged,
          activeColor: AppColors.cityPrimary,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 11.h),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                children: [
                  TextSpan(text: leadingText),
                  TextSpan(
                    text: linkText,
                    style: TextStyle(
                      color: AppColors.cityPrimary,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTapLink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
              color: AppColors.containerLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 16.r, color: AppColors.textSecondary),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 13.sp,
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
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 20.h),
      child: Column(
        children: [
          // 同意按钮
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: ElevatedButton(
              onPressed: () {
                if (_privacyChecked && _termsChecked) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                elevation: 0,
              ),
              child: Text(
                l10n?.agreeAndContinue ?? '同意',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // 不同意按钮
          SizedBox(
            width: double.infinity,
            height: 44.h,
            child: OutlinedButton(
              onPressed: () {
                _onDecline(context, l10n);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
              child: Text(
                l10n?.disagreeAndExit ?? '不同意',
                style: TextStyle(fontSize: 14.sp),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          l10n?.privacyDeclineTitle ?? '温馨提示',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          l10n?.privacyDeclineMessage ??
              '如果您不同意隐私政策和用户协议，将无法使用本应用的相关功能。'
                  '\n\n我们非常重视您的隐私安全，收集的信息仅用于为您提供更好的服务。'
                  '\n\n您确定不同意吗？',
          style: TextStyle(fontSize: 14.sp, height: 1.5),
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

  /// 打开用户协议页面
  void _openTermsOfServiceUrl(BuildContext context) {
    log('🔗 用户点击查看用户协议');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const TermsOfServicePage(),
      ),
    );
  }

  /// 打开第三方SDK信息收集清单页面
  void _openSdkListPage(BuildContext context) {
    log('🔗 用户点击查看第三方SDK清单');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const SdkListPage(),
      ),
    );
  }
}
