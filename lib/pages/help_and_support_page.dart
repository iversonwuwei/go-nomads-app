import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 帮助与客服页面
/// 华为审核要求：应用内含付费项目需提供客服联系方式
class HelpAndSupportPage extends StatelessWidget {
  const HelpAndSupportPage({super.key});

  static const String supportEmail = 'hi@gonomads.app';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(l10n.helpAndSupport),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        scrolledUnderElevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 客服联系卡片
            _buildContactCard(context, l10n),
            SizedBox(height: 20.h),

            // 服务时间
            _buildServiceHoursCard(context, l10n),
            SizedBox(height: 20.h),

            // 常见问题
            _buildFaqSection(context, l10n),
          ],
        ),
      ),
    );
  }

  /// 客服联系方式卡片
  Widget _buildContactCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  FontAwesomeIcons.headset,
                  color: Colors.white,
                  size: 24.r,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.customerServiceEmail,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10n.customerServiceEmailDesc,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          // 邮箱地址
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.envelope, color: Colors.white, size: 18.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    supportEmail,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5.sp,
                    ),
                  ),
                ),
                // 复制按钮
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: supportEmail));
                    AppToast.success(l10n.emailCopied);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(FontAwesomeIcons.copy, color: Colors.white, size: 14.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          // 发送邮件按钮
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchEmail(),
              icon: Icon(FontAwesomeIcons.paperPlane, size: 16.r),
              label: Text(l10n.sendEmail, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF4458),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 服务时间卡片
  Widget _buildServiceHoursCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(FontAwesomeIcons.clock, color: Color(0xFF3B82F6), size: 20.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.serviceHours,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.serviceHoursDesc,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 常见问题区域
  Widget _buildFaqSection(BuildContext context, AppLocalizations l10n) {
    final faqs = [
      _FaqItem(
        icon: FontAwesomeIcons.creditCard,
        iconColor: const Color(0xFF10B981),
        bgColor: const Color(0xFFF0FDF9),
        question: l10n.faqPayment,
        answer: l10n.faqPaymentAnswer,
      ),
      _FaqItem(
        icon: FontAwesomeIcons.userShield,
        iconColor: const Color(0xFF6366F1),
        bgColor: const Color(0xFFF0F0FF),
        question: l10n.faqAccount,
        answer: l10n.faqAccountAnswer,
      ),
      _FaqItem(
        icon: FontAwesomeIcons.lightbulb,
        iconColor: const Color(0xFFF59E0B),
        bgColor: const Color(0xFFFFFBEB),
        question: l10n.faqFeedback,
        answer: l10n.faqFeedbackAnswer,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
          child: Text(
            l10n.commonQuestions,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Color(0xFF333333),
            ),
          ),
        ),
        ...faqs.map((faq) => _buildFaqCard(faq)),
      ],
    );
  }

  Widget _buildFaqCard(_FaqItem faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: faq.bgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(faq.icon, color: faq.iconColor, size: 18.r),
          ),
          title: Text(
            faq.question,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          children: [
            Text(
              faq.answer,
              style: TextStyle(
                fontSize: 14.sp,
                color: Color(0xFF666666),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 打开邮件客户端
  Future<void> _launchEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'Go Nomads - Help & Support',
      },
    );
    try {
      await launchUrl(uri);
    } catch (e) {
      Clipboard.setData(const ClipboardData(text: supportEmail));
      AppToast.success(supportEmail);
    }
  }
}

class _FaqItem {
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String question;
  final String answer;

  const _FaqItem({
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.question,
    required this.answer,
  });
}
