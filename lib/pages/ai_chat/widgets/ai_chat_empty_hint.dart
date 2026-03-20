import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';

/// AI Chat 空状态提示
/// 展示场景分类快捷入口，引导用户使用 OpenClaw 功能
class AiChatEmptyHint extends StatelessWidget {
  const AiChatEmptyHint({
    super.key,
    required this.onStart,
    this.onQuickCommand,
  });

  final VoidCallback onStart;
  final void Function(String command)? onQuickCommand;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          _buildIcon(),
          SizedBox(height: 14.h),
          Text(
            '你的数字游民 AI 助理',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '输入任何指令，或选择以下场景快速开始',
            style: TextStyle(
              fontSize: 12.5.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20.h),
          _buildQuickScenarios(),
          SizedBox(height: 20.h),
          _buildStartButton(l10n),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0x11000000),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FaIcon(
        FontAwesomeIcons.wandMagicSparkles,
        color: AppColors.cityPrimary,
        size: 28.r,
      ),
    );
  }

  /// 场景快捷入口 - 每个分类展示一个代表性指令
  Widget _buildQuickScenarios() {
    final quickEntries = [
      (ScenarioCategory.travel, AutomationScenario.flightCheckin),
      (ScenarioCategory.remoteWork, AutomationScenario.workMode),
      (ScenarioCategory.finance, AutomationScenario.expenseRecord),
      (ScenarioCategory.visa, AutomationScenario.visaReminder),
      (ScenarioCategory.universal, AutomationScenario.customScript),
    ];

    return Column(
      children: quickEntries.map((entry) {
        final (category, scenario) = entry;
        return _QuickEntryCard(
          category: category,
          scenario: scenario,
          onTap: () {
            onQuickCommand?.call(scenario.exampleCommand);
          },
        );
      }).toList(),
    );
  }

  Widget _buildStartButton(AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: onStart,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cityPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
      ),
      child: Text(l10n.aiChatStartConversation),
    );
  }
}

class _QuickEntryCard extends StatelessWidget {
  const _QuickEntryCard({
    required this.category,
    required this.scenario,
    required this.onTap,
  });

  final ScenarioCategory category;
  final AutomationScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: category.color.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(category.icon, style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '"${scenario.exampleCommand}"',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.r, color: Colors.grey[300]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
