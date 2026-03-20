import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';

/// OpenClaw 场景分类面板
/// 按 5 大模块展示自动化场景，点击分类展开具体操作
class OpenClawQuickActions extends StatefulWidget {
  const OpenClawQuickActions({
    super.key,
    required this.onScenarioSelected,
    required this.onCommandSubmit,
  });

  final void Function(AutomationScenario scenario, Map<String, String> params) onScenarioSelected;
  final void Function(String command) onCommandSubmit;

  @override
  State<OpenClawQuickActions> createState() => _OpenClawQuickActionsState();
}

class _OpenClawQuickActionsState extends State<OpenClawQuickActions> {
  ScenarioCategory? _expandedCategory;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0x08000000),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildCategoryGrid(),
          if (_expandedCategory != null) _buildExpandedScenarios(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 0),
      child: Row(
        children: [
          Text('🤖', style: TextStyle(fontSize: 15.sp)),
          SizedBox(width: 6.w),
          Text(
            'OpenClaw 智能助理',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          if (_expandedCategory != null)
            GestureDetector(
              onTap: () => setState(() => _expandedCategory = null),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '收起',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = ScenarioCategory.values;
    return Padding(
      padding: EdgeInsets.fromLTRB(10.w, 10.h, 10.w, 6.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: categories.map((cat) => _CategoryChip(
          category: cat,
          isSelected: _expandedCategory == cat,
          onTap: () {
            setState(() {
              _expandedCategory = _expandedCategory == cat ? null : cat;
            });
          },
        )).toList(),
      ),
    );
  }

  Widget _buildExpandedScenarios() {
    final category = _expandedCategory!;
    final scenarios = category.scenarios;
    return Container(
      margin: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: category.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8.h),
          ...scenarios.map((scenario) => _ScenarioTile(
            scenario: scenario,
            categoryColor: category.color,
            onTap: () => _handleScenarioTap(context, scenario),
          )),
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
      case AutomationScenario.invoiceOrganize:
        _showInvoiceOrganizeDialog(context);
      case AutomationScenario.customScript:
        _showCustomScriptDialog(context);
      default:
        // 使用示例指令直接发送
        widget.onCommandSubmit(scenario.exampleCommand);
    }
  }

  void _showVisaReminderDialog(BuildContext context) {
    final countryController = TextEditingController();
    final daysController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('续签提醒'),
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
              widget.onScenarioSelected(AutomationScenario.visaReminder, {
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
        title: const Text('支付即记账'),
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
              widget.onScenarioSelected(AutomationScenario.expenseRecord, {
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
              widget.onScenarioSelected(AutomationScenario.flightCheckin, {
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
              widget.onScenarioSelected(AutomationScenario.calendarSync, {
                'source': sourceController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showInvoiceOrganizeDialog(BuildContext context) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发票整理'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: '财务邮箱',
                hintText: '如：finance@company.com',
              ),
              keyboardType: TextInputType.emailAddress,
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
              widget.onScenarioSelected(AutomationScenario.invoiceOrganize, {
                'email': emailController.text,
              });
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showCustomScriptDialog(BuildContext context) {
    final commandController = TextEditingController();
    final scheduleController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('自定义脚本'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: commandController,
                decoration: const InputDecoration(
                  labelText: '要执行的操作',
                  hintText: '如：打开得到 App 听书',
                ),
                maxLines: 2,
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: scheduleController,
                decoration: const InputDecoration(
                  labelText: '执行时间（可选）',
                  hintText: '如：每天早上 9 点',
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
              final schedule = scheduleController.text.trim();
              final command = commandController.text.trim();
              if (command.isEmpty) return;
              final fullCommand = schedule.isNotEmpty
                  ? '$schedule$command'
                  : command;
              widget.onCommandSubmit(fullCommand);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

/// 分类标签
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final ScenarioCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? category.color.withValues(alpha: 0.12) : Colors.grey[50],
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? category.color.withValues(alpha: 0.4) : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(category.icon, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 5.w),
            Text(
              category.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? category.color : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 场景操作行
class _ScenarioTile extends StatelessWidget {
  const _ScenarioTile({
    required this.scenario,
    required this.categoryColor,
    required this.onTap,
  });

  final AutomationScenario scenario;
  final Color categoryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Row(
              children: [
                Text(scenario.icon, style: TextStyle(fontSize: 18.sp)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scenario.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        scenario.description,
                        style: TextStyle(fontSize: 10.5.sp, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 18.r, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
