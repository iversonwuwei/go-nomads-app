import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_cost_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 货币选择区域组件
class CurrencySection extends StatelessWidget {
  final String controllerTag;

  const CurrencySection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCostPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;
    final currencies = _getCurrencies(context);

    return Obx(() => Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '💱',
                    style: TextStyle(fontSize: 20.sp),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    l10n.selectCurrency,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: controller.selectedCurrency.value,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                items: currencies.map((currency) {
                  return DropdownMenuItem<String>(
                    value: currency['code'],
                    child: Row(
                      children: [
                        Text(
                          currency['symbol']!,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          '${currency['code']} - ${currency['name']}',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedCurrency.value = value;
                  }
                },
              ),
            ],
          ),
        ));
  }

  List<Map<String, String>> _getCurrencies(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
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
  }
}
