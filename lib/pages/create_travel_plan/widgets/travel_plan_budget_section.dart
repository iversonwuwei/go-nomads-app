import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 预算部分 - 符合 GetX 标准的 GetView 实现
class TravelPlanBudgetSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanBudgetSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // 安全检查
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.budget, icon: FontAwesomeIcons.dollarSign),
        SizedBox(height: 12.h),
        // 预算选项
        _BudgetChipsRow(controllerTag: controllerTag, l10n: l10n),
        SizedBox(height: 16.h),
        Text(
          l10n.enterBudget,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        // 货币选择和自定义预算输入
        _CustomBudgetRow(controllerTag: controllerTag),
      ],
    );
  }
}

/// 预算选项行
class _BudgetChipsRow extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;
  final AppLocalizations l10n;

  const _BudgetChipsRow({required this.controllerTag, required this.l10n});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(child: _BudgetChip(label: l10n.low, value: 'low', controllerTag: controllerTag)),
        SizedBox(width: 12.w),
        Expanded(child: _BudgetChip(label: l10n.medium, value: 'medium', controllerTag: controllerTag)),
        SizedBox(width: 12.w),
        Expanded(child: _BudgetChip(label: l10n.high, value: 'high', controllerTag: controllerTag)),
      ],
    );
  }
}

/// 单个预算选项
class _BudgetChip extends GetView<CreateTravelPlanPageController> {
  final String label;
  final String value;
  final String controllerTag;

  const _BudgetChip({
    required this.label,
    required this.value,
    required this.controllerTag,
  });

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final isSelected = controller.budget.value == value;

      return GestureDetector(
        onTap: () => controller.setBudget(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[100],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                      blurRadius: 8.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }
}

/// 自定义预算输入行
class _CustomBudgetRow extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _CustomBudgetRow({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        _CurrencyDropdown(controllerTag: controllerTag),
        SizedBox(width: 12.w),
        Expanded(child: _CustomBudgetField(controllerTag: controllerTag)),
      ],
    );
  }
}

/// 货币下拉选择
class _CurrencyDropdown extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _CurrencyDropdown({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Obx(() => Container(
          width: 100.w,
          height: 56.h,
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedCurrency.value,
              isExpanded: true,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              borderRadius: BorderRadius.circular(12.r),
              icon: const Icon(FontAwesomeIcons.chevronDown, color: Color(0xFFFF4458)),
              items: const [
                DropdownMenuItem(value: 'USD', child: _CurrencyItem(symbol: '\$', code: 'USD')),
                DropdownMenuItem(value: 'CNY', child: _CurrencyItem(symbol: '¥', code: 'CNY')),
                DropdownMenuItem(value: 'EUR', child: _CurrencyItem(symbol: '€', code: 'EUR')),
                DropdownMenuItem(value: 'GBP', child: _CurrencyItem(symbol: '£', code: 'GBP')),
                DropdownMenuItem(value: 'JPY', child: _CurrencyItem(symbol: '¥', code: 'JPY')),
              ],
              onChanged: (value) {
                if (value != null) controller.setCurrency(value);
              },
            ),
          ),
        ));
  }
}

/// 自定义预算输入框
class _CustomBudgetField extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const _CustomBudgetField({required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return TextFormField(
      controller: controller.customBudgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: 0.toStringAsFixed(2),
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Color(0xFFFF4458), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
      onChanged: controller.onCustomBudgetChanged,
    );
  }
}

/// 货币项显示
class _CurrencyItem extends StatelessWidget {
  final String symbol;
  final String code;

  const _CurrencyItem({required this.symbol, required this.code});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$symbol ',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey[700]),
        ),
        Text(code, style: TextStyle(fontSize: 14.sp)),
      ],
    );
  }
}

/// 区块标题组件
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
