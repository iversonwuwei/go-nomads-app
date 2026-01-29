import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/copyright_widget.dart';

/// 服务条款页面
class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SectionTitle('1. 接受条款'),
            _SectionBody(
              '使用行途（Go-Nomads）即表示您已阅读并同意本服务条款。'
              '如果您不同意，请停止使用本应用。',
            ),
            _SectionTitle('2. 账号与安全'),
            _SectionBody(
              '您需提供真实、准确的注册信息并妥善保管账号。'
              '如发现账号异常或未经授权使用，请及时联系我们。',
            ),
            _SectionTitle('3. 社区内容与发布规范'),
            _SectionBody(
              '您在城市、共享办公、创新项目、活动、评论等模块发布的内容需合法、真实、文明。'
              '我们有权对违规内容进行删除、限制或其他处理。',
            ),
            _SectionTitle('4. 功能与服务范围'),
            _SectionBody(
              '行途为数字游民提供城市信息、共享办公与创新项目发现、活动组织、社交聊天、旅行计划等功能。'
              '功能可能因版本或地区而不同，并可能进行调整或优化。',
            ),
            _SectionTitle('5. 付费与会员服务'),
            _SectionBody(
              '如您购买会员或付费服务，应按照页面提示完成支付。'
              '具体权益、价格与退款规则以应用内说明为准。',
            ),
            _SectionTitle('6. 安全与风险提示'),
            _SectionBody(
              '线下活动、住宿、共享办公等线下场景存在一定风险，'
              '请您自行判断并注意人身及财产安全。',
            ),
            _SectionTitle('7. 知识产权'),
            _SectionBody(
              '行途内的商标、标识、界面设计、文本与图像内容（用户内容除外）受法律保护。'
              '未经授权不得复制、传播或用于商业用途。',
            ),
            _SectionTitle('8. 账号管理与终止'),
            _SectionBody(
              '若您违反条款或社区准则，我们有权限制或终止您的账号与服务。'
              '您也可随时申请注销账号。',
            ),
            _SectionTitle('9. 条款更新'),
            _SectionBody(
              '我们可能不定期更新条款，并在应用内提示。'
              '继续使用即表示您接受更新后的条款。',
            ),
            _SectionTitle('10. 联系我们'),
            _SectionBody('如有疑问，请通过应用内“反馈/联系我们”与我们沟通。'),
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
