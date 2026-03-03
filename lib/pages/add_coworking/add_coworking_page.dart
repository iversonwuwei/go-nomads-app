import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_amenities_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_basic_info_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_contact_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_image_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_location_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_pricing_section.dart';
import 'package:go_nomads_app/pages/add_coworking/add_coworking_specs_section.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCoworkingPage extends StatelessWidget {
  final String? cityId;
  final String? cityName;
  final String? countryName;
  final CoworkingSpace? editingSpace;

  AddCoworkingPage({
    super.key,
    this.cityId,
    this.cityName,
    this.countryName,
    this.editingSpace,
  });

  final String _tag = 'add_coworking_${DateTime.now().millisecondsSinceEpoch}';

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      AddCoworkingPageController(
        cityId: cityId,
        cityName: cityName,
        countryName: countryName,
        editingSpace: editingSpace,
      ),
      tag: _tag,
    );
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.addCoworkingSpace),
        backgroundColor: const Color(0xFFFF4458),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() => Stack(
            children: [
              Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AddCoworkingImageSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingBasicInfoSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingLocationSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingContactSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingPricingSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingSpecsSection(controllerTag: _tag),
                      SizedBox(height: 24.h),
                      AddCoworkingAmenitiesSection(controllerTag: _tag),
                      SizedBox(height: 100.h),
                    ],
                  ),
                ),
              ),
              if (controller.isSubmitting.value)
                Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF4458))),
                ),
            ],
          )),
      bottomNavigationBar: _buildBottomBar(context, controller, l10n),
    );
  }

  Widget _buildBottomBar(BuildContext context, AddCoworkingPageController controller, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(25), blurRadius: 10.r, offset: const Offset(0, -2))],
      ),
      child: Obx(() => ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final success = await controller.submitCoworking(
                      l10n.selectCity,
                      l10n.updateSuccess,
                      l10n.saveSuccess,
                      (e) => e,
                    );
                    if (success && context.mounted) {
                      // 使用 NavigationUtil 确保在 iOS 上也能正确返回并传递结果
                      await NavigationUtil.popAfterSuccess(result: true, context: context);
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(controller.isSubmitting.value ? l10n.submitting : l10n.submit,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
          )),
    );
  }
}
