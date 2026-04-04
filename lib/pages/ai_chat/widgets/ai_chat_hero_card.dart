import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

class AiChatHeroCard extends StatelessWidget {
  const AiChatHeroCard({super.key, required this.isMobile});

  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.fromLTRB(isMobile ? 16 : 24, 10, isMobile ? 16 : 24, 12),
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        gradient: AiChatTheme.heroGradient,
        borderRadius: BorderRadius.circular(26.r),
        boxShadow: [
          BoxShadow(
            color: AiChatTheme.shadow,
            blurRadius: 30.r,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -24.h,
            right: -10.w,
            child: Container(
              width: 110.r,
              height: 110.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -34.h,
            left: -16.w,
            child: Container(
              width: 86.r,
              height: 86.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildIcon(),
                  SizedBox(width: 14.w),
                  Expanded(child: _buildContent(theme)),
                ],
              ),
              SizedBox(height: 18.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: const [
                  _HeroChip(label: '旅行规划'),
                  _HeroChip(label: 'OpenClaw 自动化'),
                  _HeroChip(label: '远程办公流'),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: const [
                  Expanded(child: _HeroMetric(title: '快一点', subtitle: '从问题到动作')),
                  SizedBox(width: 10),
                  Expanded(child: _HeroMetric(title: '稳一点', subtitle: '把行程拆成步骤')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      height: isMobile ? 54 : 60,
      width: isMobile ? 54 : 60,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Center(
        child: FaIcon(FontAwesomeIcons.wandMagicSparkles, color: Colors.white, size: 24.r),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            '行途 × OpenClaw',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          '把旅行安排、签证提醒和自动化命令放进同一条对话。',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '差旅值机、远程办公、记账报销、签证提醒和万能自动化，现在统一在一个旅途指挥台里处理。',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.86),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}
