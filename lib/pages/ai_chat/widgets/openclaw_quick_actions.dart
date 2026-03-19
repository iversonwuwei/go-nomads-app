import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';

/// OpenClaw 快捷操作网格
/// 在 AI Chat 页面中显示预设的自动化场景按钮
class OpenClawQuickActions extends StatelessWidget {
  const OpenClawQuickActions({
    super.key,
    required this.onScenarioSelected,
    required this.onCommandSubmit,
  });

  final void Function(AutomationScenario scenario, Map<String, String> params) onScenarioSelected;
  final void Function(String command) onCommandSubmit;

  @override
  Widget build(BuildContext context) {
    final scenarios = AutomationScenario.values;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('⚡', style: TextStyle(fontSize: 14.sp)),
              SizedBox(width: 6.w),
              Text(
                '快捷操作',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.85,
            ),
            itemCount: scenarios.length,
            itemBuilder: (context, index) {
              final scenario = scenarios[index];
              return _QuickActionItem(
                scenario: scenario,
                onTap: () => _handleScenarioTap(context, scenario),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleScenarioTap(BuildContext context, AutomationScenario scenario) {
    switch (scenario) {
      case AutomationScenario.visaReminder:
        _showVisaReminderDialog(context);
      case AutomationScenario.expenseRecord:
        _showExpenseRecordDialog(context);
      case AutomationScenario.flightCheckin:
        _showFlightCheckinDialog(context);
      case AutomationScenario.calendarSync:
        _showCalendarSyncDialog(context);
      default:
        // 无参数的场景直接以自然语言指令发送
        onCommandSubmit(scenario.description);
    }
  }

  void _showVisaReminderDialog(BuildContext context) {
    final countryController = TextEditingController();
    final daysController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('签证提醒'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: countryController,
              decoration: const InputDecoration(
                labelText: '国家',
                hintText: '如：泰国',
              ),
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: daysController,
              decoration: const InputDecoration(
                labelText: '剩余天数',
                hintText: '如：30',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onScenarioSelected(AutomationScenario.visaReminder, {
                'country': countryController.text,
                'days': daysController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showExpenseRecordDialog(BuildContext context) {
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('记账'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: '金额',
                  prefixText: '¥ ',
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类',
                  hintText: '如：餐饮、交通',
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: '备注（可选）',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onScenarioSelected(AutomationScenario.expenseRecord, {
                'amount': amountController.text,
                'category': categoryController.text,
                'note': noteController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showFlightCheckinDialog(BuildContext context) {
    final flightController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('一键值机'),
        content: TextField(
          controller: flightController,
          decoration: const InputDecoration(
            labelText: '航班号',
            hintText: '如：MU1234',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onScenarioSelected(AutomationScenario.flightCheckin, {
                'flight': flightController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCalendarSyncDialog(BuildContext context) {
    final sourceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('行程同步'),
        content: TextField(
          controller: sourceController,
          decoration: const InputDecoration(
            labelText: '来源',
            hintText: '如：携程、飞猪',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onScenarioSelected(AutomationScenario.calendarSync, {
                'source': sourceController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.scenario,
    required this.onTap,
  });

  final AutomationScenario scenario;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scenario.icon,
              style: TextStyle(fontSize: 22.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              scenario.title,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
