import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/legal_document.dart';
import 'package:go_nomads_app/pages/legal/sdk_list_page.dart';
import 'package:go_nomads_app/services/legal_service.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 隐私政策页面 - 从后端 API 加载并动态渲染
///
/// 工信部合规要求：用户应能随时查阅完整的隐私政策文本。
class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  final LegalService _legalService = LegalService();
  LegalDocument? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrivacyPolicy();
  }

  Future<void> _loadPrivacyPolicy() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final doc = await _legalService.getPrivacyPolicy();
    if (mounted) {
      setState(() {
        _document = doc;
        _isLoading = false;
        _error = doc == null ? '加载失败，请稍后重试' : null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.privacyPolicy),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _document == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48.r, color: AppColors.textTertiary),
            SizedBox(height: 12.h),
            Text(_error ?? '加载失败', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: _loadPrivacyPolicy, child: const Text('重试')),
          ],
        ),
      );
    }

    final doc = _document!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 生效日期
          Text(
            '生效日期：${_formatDate(doc.effectiveDate)}',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary, height: 1.5),
          ),
          SizedBox(height: 16.h),

          // 动态渲染章节
          ...doc.sections.map((section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(section.title),
                  _SectionBody(section.content),
                ],
              )),

          // 第三方SDK清单入口
          if (doc.sdkList.isNotEmpty) ...[
            SizedBox(height: 16.h),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SdkListPage()),
                );
              },
              icon: Icon(Icons.extension_outlined, size: 18.r),
              label: const Text('查看第三方SDK信息收集清单'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cityPrimary,
                side: const BorderSide(color: AppColors.cityPrimary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ],

          SizedBox(height: 24.h),
          const CopyrightWidget(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year} 年 ${date.month} 月 ${date.day} 日';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SectionBody extends StatelessWidget {
  final String text;

  const _SectionBody(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
