import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 预算部分
class TravelPlanBudgetSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanBudgetSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController? get _c {
    try {
      return Get.find<CreateTravelPlanPageController>(tag: controllerTag);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _c;

    // 如果 controller 已被销毁，返回空容器
    if (controller == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.budget, FontAwesomeIcons.dollarSign),
        SizedBox(height: 12.h),
        Obx(() {
          // 再次检查 controller 是否存在
          if (_c == null) return const SizedBox.shrink();
          return Row(
            children: [
              Expanded(child: _buildBudgetChip(l10n.low, 'low')),
              SizedBox(width: 12.w),
              Expanded(child: _buildBudgetChip(l10n.medium, 'medium')),
              SizedBox(width: 12.w),
              Expanded(child: _buildBudgetChip(l10n.high, 'high')),
            ],
          );
        }),
        SizedBox(height: 16.h),
        Text(
          l10n.enterBudget,
          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 8.h),
        Builder(builder: (context) {
          // 检查 controller 是否已销毁
          if (_c == null) return const SizedBox.shrink();
          return Row(
            children: [
              _buildCurrencyDropdown(),
              SizedBox(width: 12.w),
              Expanded(child: _buildCustomBudgetField()),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildBudgetChip(String label, String value) {
    final controller = _c;
    if (controller == null) return const SizedBox.shrink();

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
  }

  Widget _buildCurrencyDropdown() {
    final controller = _c;
    if (controller == null) return const SizedBox.shrink();

    return Obx(() {
      if (_c == null) return const SizedBox.shrink();
      return Container(
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
      );
    });
  }

  Widget _buildCustomBudgetField() {
    final controller = _c;
    if (controller == null) return const SizedBox.shrink();

    return TextFormField(
      controller: controller.customBudgetController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '0.00',
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

  Widget _buildSectionTitle(String title, IconData icon) {
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
