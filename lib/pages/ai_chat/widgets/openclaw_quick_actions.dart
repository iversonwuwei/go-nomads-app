import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/models/automation_scenario.dart';
import 'package:go_nomads_app/pages/ai_chat/ai_chat_theme.dart';

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
        color: AiChatTheme.panel,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AiChatTheme.line),
        boxShadow: [
          BoxShadow(
            color: AiChatTheme.shadow,
            blurRadius: 22.r,
            offset: const Offset(0, 10),
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
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: AiChatTheme.tealSoft.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 18.r, color: AiChatTheme.teal),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OpenClaw 智能工作流',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AiChatTheme.ink,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '挑一个场景，把动作串进当前对话',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AiChatTheme.inkSoft,
                  ),
                ),
              ],
            ),
          ),
          if (_expandedCategory != null)
            GestureDetector(
              onTap: () => setState(() => _expandedCategory = null),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AiChatTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '收起',
                  style: TextStyle(fontSize: 11.sp, color: AiChatTheme.inkSoft),
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
      padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: categories
            .map((cat) => _CategoryChip(
                  category: cat,
                  isSelected: _expandedCategory == cat,
                  onTap: () {
                    setState(() {
                      _expandedCategory = _expandedCategory == cat ? null : cat;
                    });
                  },
                ))
            .toList(),
      ),
    );
  }

  Widget _buildExpandedScenarios() {
    final category = _expandedCategory!;
    final scenarios = category.scenarios;
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: category.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.subtitle,
            style: TextStyle(
              fontSize: 11.sp,
              color: AiChatTheme.inkSoft,
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

    _showScenarioDialog(
      context,
      title: '续签提醒',
      description: '填写国家和剩余天数后，系统会生成可执行的签证提醒动作，避免错过续签节点。',
      accentColor: ScenarioCategory.visa.color,
      content: [
        _DialogField(
          controller: countryController,
          label: '国家 / 地区',
          hintText: '例如：泰国',
        ),
        SizedBox(height: 12.h),
        _DialogField(
          controller: daysController,
          label: '距离到期剩余天数',
          hintText: '例如：30',
          keyboardType: TextInputType.number,
        ),
      ],
      onConfirm: () {
        widget.onScenarioSelected(AutomationScenario.visaReminder, {
          'country': countryController.text,
          'days': daysController.text,
        });
      },
    );
  }

  void _showExpenseRecordDialog(BuildContext context) {
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final noteController = TextEditingController();

    _showScenarioDialog(
      context,
      title: '支付即记账',
      description: '补全本次支出的金额、分类和备注后，系统会直接整理成可执行记账指令。',
      accentColor: ScenarioCategory.finance.color,
      content: [
        _DialogField(
          controller: amountController,
          label: '金额',
          hintText: '输入数字金额',
          prefixText: '¥ ',
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 12.h),
        _DialogField(
          controller: categoryController,
          label: '分类',
          hintText: '例如：餐饮、交通',
        ),
        SizedBox(height: 12.h),
        _DialogField(
          controller: noteController,
          label: '备注',
          hintText: '可选，例如：客户午餐',
        ),
      ],
      onConfirm: () {
        widget.onScenarioSelected(AutomationScenario.expenseRecord, {
          'amount': amountController.text,
          'category': categoryController.text,
          'note': noteController.text,
        });
      },
    );
  }

  void _showFlightCheckinDialog(BuildContext context) {
    final flightController = TextEditingController();

    _showScenarioDialog(
      context,
      title: '一键值机',
      description: '输入航班号后，系统会按当前流程准备值机动作，并把结果继续写回对话。',
      accentColor: ScenarioCategory.travel.color,
      content: [
        _DialogField(
          controller: flightController,
          label: '航班号',
          hintText: '例如：MU1234',
        ),
      ],
      onConfirm: () {
        widget.onScenarioSelected(AutomationScenario.flightCheckin, {
          'flight': flightController.text,
        });
      },
    );
  }

  void _showCalendarSyncDialog(BuildContext context) {
    final sourceController = TextEditingController();

    _showScenarioDialog(
      context,
      title: '行程同步',
      description: '告诉系统订单来源后，会生成同步到系统日历的操作步骤，便于后续跟进。',
      accentColor: ScenarioCategory.travel.color,
      content: [
        _DialogField(
          controller: sourceController,
          label: '订单来源',
          hintText: '例如：携程、飞猪',
        ),
      ],
      onConfirm: () {
        widget.onScenarioSelected(AutomationScenario.calendarSync, {
          'source': sourceController.text,
        });
      },
    );
  }

  void _showInvoiceOrganizeDialog(BuildContext context) {
    final emailController = TextEditingController();

    _showScenarioDialog(
      context,
      title: '发票整理',
      description: '输入财务邮箱后，系统会按当前规则整理并准备发送发票资料。',
      accentColor: ScenarioCategory.finance.color,
      content: [
        _DialogField(
          controller: emailController,
          label: '财务邮箱',
          hintText: '例如：finance@company.com',
          keyboardType: TextInputType.emailAddress,
        ),
      ],
      onConfirm: () {
        widget.onScenarioSelected(AutomationScenario.invoiceOrganize, {
          'email': emailController.text,
        });
      },
    );
  }

  void _showCustomScriptDialog(BuildContext context) {
    final commandController = TextEditingController();
    final scheduleController = TextEditingController();

    _showScenarioDialog(
      context,
      title: '自定义脚本',
      description: '把你想执行的动作和时间说清楚，系统会拼成一条可直接执行的自动化指令。',
      accentColor: ScenarioCategory.universal.color,
      content: [
        _DialogField(
          controller: commandController,
          label: '要执行的动作',
          hintText: '例如：打开得到 App 听书',
          maxLines: 2,
        ),
        SizedBox(height: 12.h),
        _DialogField(
          controller: scheduleController,
          label: '执行时间',
          hintText: '可选，例如：每天早上 9 点',
        ),
      ],
      onConfirm: () {
        final schedule = scheduleController.text.trim();
        final command = commandController.text.trim();
        if (command.isEmpty) return;
        final fullCommand = schedule.isNotEmpty ? '$schedule$command' : command;
        widget.onCommandSubmit(fullCommand);
      },
    );
  }

  Future<void> _showScenarioDialog(
    BuildContext context, {
    required String title,
    required String description,
    required Color accentColor,
    required List<Widget> content,
    required VoidCallback onConfirm,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            color: AiChatTheme.shell,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: AiChatTheme.line),
            boxShadow: [
              BoxShadow(
                color: AiChatTheme.shadow.withValues(alpha: 0.9),
                blurRadius: 28.r,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.tune_rounded,
                        color: accentColor, size: 20.r),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AiChatTheme.ink,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.45,
                            color: AiChatTheme.inkSoft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              ...content,
              SizedBox(height: 18.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AiChatTheme.line),
                        foregroundColor: AiChatTheme.inkSoft,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: const Text('开始执行'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  const _DialogField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixText,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? prefixText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: AiChatTheme.ink,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13.sp,
            color: AiChatTheme.ink,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            hintStyle: TextStyle(
              fontSize: 12.sp,
              color: AiChatTheme.inkSoft.withValues(alpha: 0.8),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.78),
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AiChatTheme.line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AiChatTheme.teal.withValues(alpha: 0.55), width: 1.4),
            ),
          ),
        ),
      ],
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
          color: isSelected ? category.color.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected ? category.color.withValues(alpha: 0.4) : AiChatTheme.line,
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
                color: isSelected ? category.color : AiChatTheme.ink,
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
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Ink(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: categoryColor.withValues(alpha: 0.14)),
              ),
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
                            fontWeight: FontWeight.w700,
                            color: AiChatTheme.ink,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          scenario.description,
                          style: TextStyle(fontSize: 10.5.sp, color: AiChatTheme.inkSoft),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 18.r, color: categoryColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
