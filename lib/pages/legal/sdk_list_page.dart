import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/legal_document.dart';
import 'package:go_nomads_app/services/legal_service.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 第三方SDK信息收集清单页面
///
/// 工信部合规要求：明确列出每个第三方SDK的名称、公司、用途、收集数据项和隐私政策链接
class SdkListPage extends StatefulWidget {
  const SdkListPage({super.key});

  @override
  State<SdkListPage> createState() => _SdkListPageState();
}

class _SdkListPageState extends State<SdkListPage> {
  List<SdkInfo>? _sdkList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSdkList();
  }

  Future<void> _loadSdkList() async {
    final doc = await LegalService().getPrivacyPolicy();
    if (mounted) {
      setState(() {
        _sdkList = doc?.sdkList;
        _isLoading = false;
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
        title: Text(l10n.thirdPartyServices),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sdkList == null || _sdkList!.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 48.r, color: AppColors.textTertiary),
            SizedBox(height: 12.h),
            Text(l10n.noData, style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _sdkList!.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader();
        }
        return _SdkCard(sdk: _sdkList![index - 1]);
      },
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        '为实现应用相关功能，本应用集成了以下第三方SDK。'
        '下表列出了各SDK的名称、所属公司、用途及可能收集的个人信息：',
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.textSecondary,
          height: 1.6,
        ),
      ),
    );
  }
}

/// SDK 卡片组件
class _SdkCard extends StatelessWidget {
  final SdkInfo sdk;

  const _SdkCard({required this.sdk});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SDK 名称 + 公司
            Row(
              children: [
                Icon(Icons.extension_outlined, size: 18.r, color: AppColors.cityPrimary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    sdk.name,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            _buildInfoRow('所属公司', sdk.company),
            _buildInfoRow('用途', sdk.purpose),
            SizedBox(height: 8.h),

            // 收集数据项
            Text(
              '收集信息：',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 4.w,
              children: sdk.dataCollected.map((item) => Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4.r),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
                ),
                child: Text(
                  item,
                  style: TextStyle(fontSize: 11.sp, color: Colors.orange[800]),
                ),
              )).toList(),
            ),

            // 隐私政策链接
            if (sdk.privacyUrl.isNotEmpty) ...[
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => _openUrl(sdk.privacyUrl),
                child: Row(
                  children: [
                    Icon(Icons.open_in_new, size: 14.r, color: AppColors.cityPrimary),
                    SizedBox(width: 4.w),
                    Text(
                      '查看隐私政策',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.cityPrimary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label：',
            style: TextStyle(fontSize: 13.sp, color: AppColors.textTertiary),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
