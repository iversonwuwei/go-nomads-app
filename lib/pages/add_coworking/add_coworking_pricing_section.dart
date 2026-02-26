import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCoworkingPricingSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingPricingSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.pricing, FontAwesomeIcons.moneyBill),
        SizedBox(height: 16.h),
        _buildTextField(controller: _c.dailyRateController, label: l10n.dailyRate, hint: l10n.dailyRateHint, keyboardType: TextInputType.number),
        SizedBox(height: 16.h),
        _buildTextField(controller: _c.monthlyRateController, label: l10n.monthlyRate, hint: l10n.monthlyRateHint, keyboardType: TextInputType.number),
        SizedBox(height: 16.h),
        _buildCurrencyDropdown(context, l10n),
        SizedBox(height: 16.h),
        _buildFreeTrialSwitch(l10n),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24.r),
        SizedBox(width: 8.w),
        Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildCurrencyDropdown(BuildContext context, AppLocalizations l10n) {
    return Obx(() => DropdownButtonFormField<String>(
          value: _c.currency.value.isEmpty ? 'USD' : _c.currency.value,
          decoration: InputDecoration(
            labelText: l10n.currency,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: const [
            DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
            DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
            DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
            DropdownMenuItem(value: 'CNY', child: Text('CNY (¥)')),
            DropdownMenuItem(value: 'JPY', child: Text('JPY (¥)')),
            DropdownMenuItem(value: 'THB', child: Text('THB (฿)')),
            DropdownMenuItem(value: 'VND', child: Text('VND (₫)')),
            DropdownMenuItem(value: 'IDR', child: Text('IDR (Rp)')),
            DropdownMenuItem(value: 'MYR', child: Text('MYR (RM)')),
            DropdownMenuItem(value: 'SGD', child: Text('SGD (S\$)')),
          ],
          onChanged: (value) => _c.currency.value = value ?? 'USD',
        ));
  }

  Widget _buildFreeTrialSwitch(AppLocalizations l10n) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.freeTrialAvailable, style: TextStyle(fontSize: 16.sp)),
              Switch(value: _c.hasFreeTrial.value, onChanged: (value) => _c.hasFreeTrial.value = value, activeColor: const Color(0xFFFF4458)),
            ],
          ),
        ));
  }
}
