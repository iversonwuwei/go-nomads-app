import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/legal_document.dart';
import 'package:go_nomads_app/services/legal_service.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 服务条款页面 - 从后端 API 加载并动态渲染
class TermsOfServicePage extends StatefulWidget {
  const TermsOfServicePage({super.key});

  @override
  State<TermsOfServicePage> createState() => _TermsOfServicePageState();
}

class _TermsOfServicePageState extends State<TermsOfServicePage> {
  final LegalService _legalService = LegalService();
  LegalDocument? _document;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTermsOfService();
  }

  Future<void> _loadTermsOfService() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final doc = await _legalService.getTermsOfService();
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
        title: Text(l10n.termsAndConditions),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
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
            ElevatedButton(onPressed: _loadTermsOfService, child: Text(l10n.retry)),
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
          Text(
            '生效日期：${_formatDate(doc.effectiveDate)}',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary, height: 1.5),
          ),
          SizedBox(height: 16.h),
          ...doc.sections.map((section) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle(section.title),
                  _SectionBody(section.content),
                ],
              )),
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
