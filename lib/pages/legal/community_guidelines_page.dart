import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 社区准则页面
class CommunityGuidelinesPage extends StatelessWidget {
  const CommunityGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.communityGuidelines),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('1. 尊重与友善'),
            _SectionBody('请尊重他人观点与文化差异，避免人身攻击、歧视、骚扰或仇恨言论。'),
            _SectionTitle('2. 真实与可信'),
            _SectionBody('请发布真实信息与经历，避免虚假宣传、刷评、诱导或误导性内容。'),
            _SectionTitle('3. 合法与安全'),
            _SectionBody('禁止发布违法、诈骗、侵权、色情、暴力或其他有害内容。'),
            _SectionTitle('4. 隐私保护'),
            _SectionBody('未经允许不得发布他人隐私信息或私人联系方式。'),
            _SectionTitle('5. 友好互动与建设性反馈'),
            _SectionBody('鼓励分享有价值的经验、建议与改进意见，避免灌水或恶意攻击。'),
            _SectionTitle('6. 线下活动礼仪'),
            _SectionBody('参加线下活动请守时、守约并注意安全，如遇问题及时联系组织者或平台。'),
            _SectionTitle('7. 举报与处理'),
            _SectionBody('如发现违规内容，请使用举报功能。平台将依据准则进行处理。'),
            _SectionTitle('8. 准则更新'),
            _SectionBody('我们可能不定期更新社区准则，更新后继续使用视为同意。'),
            SizedBox(height: 24),
            CopyrightWidget(),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}
