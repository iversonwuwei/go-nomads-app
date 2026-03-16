import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_travel_plan_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/location_picker_field.dart';

class TravelPlanDestinationSection extends GetView<CreateTravelPlanPageController> {
  final String controllerTag;

  const TravelPlanDestinationSection({super.key, required this.controllerTag});

  @override
  String? get tag => controllerTag;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (!Get.isRegistered<CreateTravelPlanPageController>(tag: controllerTag)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: l10n.destination, icon: FontAwesomeIcons.route),
        SizedBox(height: 12.h),
        Obx(
          () => LocationPickerField(
            initialCountryId: controller.selectedCountryId.value.isEmpty ? null : controller.selectedCountryId.value,
            initialCountryName:
                controller.selectedCountryName.value.isEmpty ? null : controller.selectedCountryName.value,
            initialCityId: controller.selectedCityId.value.isEmpty ? null : controller.selectedCityId.value,
            initialCityName: controller.selectedCityName.value.isEmpty ? null : controller.selectedCityName.value,
            label: l10n.destination,
            required: true,
            onChanged: (result) {
              controller.setDestination(
                countryId: result.countryId,
                countryName: result.countryName,
                cityId: result.cityId,
                cityName: result.cityName,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
