import 'package:go_nomads_app/controllers/add_cost_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 总费用显示组件
class TotalDisplaySection extends StatelessWidget {
  final String controllerTag;

  const TotalDisplaySection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCostPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final currencySymbol = _getCurrencySymbol(context, controller);
      return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFF4458).withValues(alpha: 0.1),
                const Color(0xFFFF4458).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color(0xFFFF4458).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.totalMonthly,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                  '$currencySymbol ${controller.totalCost.value.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  FontAwesomeIcons.calculator,
                  color: Colors.white,
                  size: 32.r,
                ),
              ),
            ],
          ),
      );
    });
  }

  String _getCurrencySymbol(BuildContext context, AddCostPageController controller) {
    final l10n = AppLocalizations.of(context)!;
    final currencies = [
      {'code': 'USD', 'symbol': '\$', 'name': l10n.currencyUSD},
      {'code': 'EUR', 'symbol': '€', 'name': l10n.currencyEUR},
      {'code': 'GBP', 'symbol': '£', 'name': l10n.currencyGBP},
      {'code': 'JPY', 'symbol': '¥', 'name': l10n.currencyJPY},
      {'code': 'CNY', 'symbol': '¥', 'name': l10n.currencyCNY},
      {'code': 'THB', 'symbol': '฿', 'name': l10n.currencyTHB},
      {'code': 'SGD', 'symbol': 'S\$', 'name': l10n.currencySGD},
      {'code': 'AUD', 'symbol': 'A\$', 'name': l10n.currencyAUD},
      {'code': 'CAD', 'symbol': 'C\$', 'name': l10n.currencyCAD},
      {'code': 'INR', 'symbol': '₹', 'name': l10n.currencyINR},
      {'code': 'KRW', 'symbol': '₩', 'name': l10n.currencyKRW},
      {'code': 'MYR', 'symbol': 'RM', 'name': l10n.currencyMYR},
      {'code': 'VND', 'symbol': '₫', 'name': l10n.currencyVND},
      {'code': 'IDR', 'symbol': 'Rp', 'name': l10n.currencyIDR},
      {'code': 'PHP', 'symbol': '₱', 'name': l10n.currencyPHP},
    ];
    return currencies.firstWhere((c) => c['code'] == controller.selectedCurrency.value)['symbol']!;
  }
}

/// 备注区域组件
class NotesSection extends StatelessWidget {
  final String controllerTag;

  const NotesSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCostPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '📝',
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              l10n.additionalNotes,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: controller.notesController,
          maxLines: 4,
          maxLength: 500,
          decoration: InputDecoration(
            hintText: l10n.additionalCostInfo,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: EdgeInsets.all(16.w),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Color(0xFFFF4458), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

/// 提交按钮组件
class SubmitButton extends StatelessWidget {
  final String controllerTag;
  final VoidCallback onSubmit;

  const SubmitButton({
    super.key,
    required this.controllerTag,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCostPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: controller.isSubmitting.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        l10n.submitCost,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),
      ),
    );
  }
}
