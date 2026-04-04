import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

class AiChatEmptyHint extends StatelessWidget {
  const AiChatEmptyHint({
    super.key,
    this.onQuickCommand,
  });

  final void Function(String command)? onQuickCommand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AiChatTheme.surface.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: AiChatTheme.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIcon(),
                SizedBox(width: 10.w),
                Text(
                  '旅途指挥台已就绪',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: AiChatTheme.ink,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            '选一个场景，直接开始。',
            style: TextStyle(
              fontSize: 18.sp,
              height: 1.25,
              fontWeight: FontWeight.w800,
              color: AiChatTheme.ink,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '把高频操作收成一组紧凑指令，少翻屏，直接触发。',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.4,
              color: AiChatTheme.inkSoft,
            ),
          ),
          SizedBox(height: 14.h),
          _buildQuickScenarios(),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 34.r,
      height: 34.r,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AiChatTheme.teal, AiChatTheme.coral],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: FaIcon(
        FontAwesomeIcons.wandMagicSparkles,
        color: Colors.white,
        size: 14.r,
      ),
    );
  }

  Widget _buildQuickScenarios() {
    final quickEntries = [
      (
        ScenarioCategory.travel,
        AutomationScenario.flightCheckin,
        '值机提醒',
        '核对航班状态并生成值机提醒',
      ),
      (
        ScenarioCategory.remoteWork,
        AutomationScenario.workMode,
        '办公模式',
        '整理今日远程办公节奏和地点',
      ),
      (
        ScenarioCategory.finance,
        AutomationScenario.expenseRecord,
        '记账报销',
        '快速记录支出并整理报销项',
      ),
      (
        ScenarioCategory.visa,
        AutomationScenario.visaReminder,
        '签证提醒',
        '跟进材料、时间点和续签节点',
      ),
      (
        ScenarioCategory.universal,
        AutomationScenario.customScript,
        '自定义脚本',
        '输入一句话，生成你的自动化流程',
      ),
    ];

    return Column(
      children: [
        for (final entry in quickEntries) ...[
          Builder(
            builder: (context) {
              final (category, scenario, title, summary) = entry;
              return _QuickEntryCard(
                category: category,
                scenario: scenario,
                title: title,
                summary: summary,
                onTap: () {
                  onQuickCommand?.call(scenario.exampleCommand);
                },
              );
            },
          ),
          if (entry != quickEntries.last) SizedBox(height: 10.h),
        ],
      ],
    );
  }
}

class _QuickEntryCard extends StatelessWidget {
  const _QuickEntryCard({
    required this.category,
    required this.scenario,
    required this.title,
    required this.summary,
    required this.onTap,
  });

  final ScenarioCategory category;
  final AutomationScenario scenario;
  final String title;
  final String summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          constraints: BoxConstraints(minHeight: 88.h),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: category.color.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: AiChatTheme.shadow.withValues(alpha: 0.36),
                blurRadius: 14.r,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(category.icon, style: TextStyle(fontSize: 18.sp)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AiChatTheme.ink,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: category.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            category.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: category.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      summary,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AiChatTheme.inkSoft,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AiChatTheme.line),
                ),
                child: Icon(
                  Icons.north_east_rounded,
                  size: 17.r,
                  color: category.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
