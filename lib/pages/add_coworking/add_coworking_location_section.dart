import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_page.dart';
import 'package:go_nomads_app/widgets/location_picker_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCoworkingLocationSection extends StatelessWidget {
  final String controllerTag;
  final bool isEditMode;
  final String? fixedCityId;

  const AddCoworkingLocationSection({super.key, required this.controllerTag, this.isEditMode = false, this.fixedCityId});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.location, FontAwesomeIcons.locationDot),
        SizedBox(height: 16.h),
        _buildTextField(controller: _c.addressController, label: l10n.address, hint: l10n.addressHint, required: true),
        SizedBox(height: 16.h),
        Obx(() => LocationPickerField(
              locationController: _c.locationController,
              initialCountryId: _c.selectedCountryId.value,
              initialCountryName: _c.selectedCountry.value,
              initialCityId: _c.selectedCityId.value,
              initialCityName: _c.selectedCity.value,
              required: true,
              enabled: !(isEditMode || fixedCityId != null),
              label: l10n.city,
              onChanged: (r) => _c.updateLocation(countryId: r.countryId, countryNameValue: r.countryName, cityIdValue: r.cityId, cityNameValue: r.cityName),
            )),
        SizedBox(height: 16.h),
        _buildLocationPicker(l10n),
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

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, bool required = false}) {
    final l10n = AppLocalizations.of(Get.context!)!;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? l10n.thisFieldIsRequired : null : null,
    );
  }

  Future<void> _openMapPicker() async {
    final lat = _c.latitude.value;
    final lng = _c.longitude.value;
    final result = await Get.to(
      () => const MapPickerPage(),
      binding: MapPickerBinding(),
      arguments: {
        'initialLatitude': lat != 0 ? lat : null,
        'initialLongitude': lng != 0 ? lng : null,
        'searchQuery': _c.addressController.text.trim().isNotEmpty ? _c.addressController.text.trim() : null,
        'country': _c.selectedCountry.value,
        'city': _c.selectedCity.value,
      },
    );
    if (result != null && result is Map<String, dynamic>) {
      _c.updateCoordinates(result['latitude'] ?? 0.0, result['longitude'] ?? 0.0);
    }
  }

  Widget _buildLocationPicker(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _c.latitudeController,
            decoration: InputDecoration(
              labelText: l10n.latitude,
              hintText: 39.904200.toString(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) _c.latitude.value = parsed;
            },
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: TextFormField(
            controller: _c.longitudeController,
            decoration: InputDecoration(
              labelText: l10n.longitude,
              hintText: 116.407396.toString(),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: IconButton(
                icon: Icon(FontAwesomeIcons.mapLocationDot, color: Color(0xFFFF4458), size: 20.r),
                tooltip: l10n.pickLocationOnMap,
                onPressed: _openMapPicker,
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
            onChanged: (v) {
              final parsed = double.tryParse(v);
              if (parsed != null) _c.longitude.value = parsed;
            },
          ),
        ),
      ],
    );
  }
}
