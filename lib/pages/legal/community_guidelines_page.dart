import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 社区准则页面
class CommunityGuidelineSection {
  final String title;
  final String content;

  const CommunityGuidelineSection({
    required this.title,
    required this.content,
  });
}

const List<CommunityGuidelineSection> _fallbackSections = [
  CommunityGuidelineSection(title: '1. 尊重与友善', content: '请尊重他人观点与文化差异，避免人身攻击、歧视、骚扰或仇恨言论。'),
  CommunityGuidelineSection(title: '2. 真实与可信', content: '请发布真实信息与经历，避免虚假宣传、刷评、诱导或误导性内容。'),
  CommunityGuidelineSection(title: '3. 合法与安全', content: '禁止发布违法、诈骗、侵权、色情、暴力或其他有害内容。'),
  CommunityGuidelineSection(title: '4. 隐私保护', content: '未经允许不得发布他人隐私信息或私人联系方式。'),
  CommunityGuidelineSection(title: '5. 友好互动与建设性反馈', content: '鼓励分享有价值的经验、建议与改进意见，避免灌水或恶意攻击。'),
  CommunityGuidelineSection(title: '6. 线下活动礼仪', content: '参加线下活动请守时、守约并注意安全，如遇问题及时联系组织者或平台。'),
  CommunityGuidelineSection(title: '7. 举报与处理', content: '如发现违规内容，请使用举报功能。平台将依据准则进行处理。'),
  CommunityGuidelineSection(title: '8. 准则更新', content: '我们可能不定期更新社区准则，更新后继续使用视为同意。'),
];

class CommunityGuidelinesPage extends StatefulWidget {
  const CommunityGuidelinesPage({super.key});

  @override
  State<CommunityGuidelinesPage> createState() => _CommunityGuidelinesPageState();
}

class _CommunityGuidelinesPageState extends State<CommunityGuidelinesPage> {
  List<CommunityGuidelineSection> _sections = _fallbackSections;

  @override
  void initState() {
    super.initState();
    _loadRemoteSections();
  }

  Future<void> _loadRemoteSections() async {
    final remoteSections = await AppConfigService().getCommunityGuidelineSections(forceRefresh: true);
    if (!mounted || remoteSections == null || remoteSections.isEmpty) {
      return;
    }

    setState(() {
      _sections = remoteSections
          .map((section) => CommunityGuidelineSection(title: section.title, content: section.content))
          .toList(growable: false);
    });
  }

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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final section in _sections) ...[
              _SectionTitle(section.title),
              _SectionBody(section.content),
            ],
            SizedBox(height: 24.h),
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
