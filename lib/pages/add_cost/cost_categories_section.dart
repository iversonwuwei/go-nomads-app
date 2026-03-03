import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_cost_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 费用类别区域组件
class CostCategoriesSection extends StatelessWidget {
  final String controllerTag;

  const CostCategoriesSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCostPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;
    final categories = _getCategories(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.monthlyCost,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          l10n.shareExperience,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 16.h),
        ...categories.map((category) => _buildCostInputField(context, controller, category)),
      ],
    );
  }

  Widget _buildCostInputField(
    BuildContext context,
    AddCostPageController controller,
    Map<String, dynamic> category,
  ) {
    final currencySymbol = _getCurrencySymbol(context, controller);
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                category['icon'],
                style: TextStyle(fontSize: 20.sp),
              ),
              SizedBox(width: 8.w),
              Text(
                category['name'],
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.controllers[category['key']],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: category['hint'],
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
              prefixText: '$currencySymbol ',
              prefixStyle: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: Color(0xFFFF4458), width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategories(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {'key': 'accommodation', 'name': l10n.accommodation, 'icon': '🏠', 'hint': l10n.monthlyRent},
      {'key': 'food', 'name': l10n.foodDining, 'icon': '🍽️', 'hint': l10n.groceriesRestaurants},
      {'key': 'transportation', 'name': l10n.transportation, 'icon': '🚗', 'hint': l10n.publicTransport},
      {'key': 'entertainment', 'name': l10n.entertainment, 'icon': '🎬', 'hint': l10n.moviesActivities},
      {'key': 'gym', 'name': l10n.gym, 'icon': '💪', 'hint': l10n.gymMembership},
      {'key': 'coworking', 'name': l10n.coworkingSpace, 'icon': '💼', 'hint': l10n.workspaceRental},
      {'key': 'utilities', 'name': l10n.utilities, 'icon': '💡', 'hint': l10n.electricityWater},
      {'key': 'healthcare', 'name': l10n.healthcare, 'icon': '🏥', 'hint': l10n.medicalInsurance},
      {'key': 'shopping', 'name': l10n.shopping, 'icon': '🛍️', 'hint': l10n.clothesPersonal},
      {'key': 'other', 'name': l10n.otherExpenses, 'icon': '📝', 'hint': l10n.miscellaneous},
    ];
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
