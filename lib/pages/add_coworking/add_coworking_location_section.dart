import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:go_nomads_app/pages/flutter_map_picker_page.dart';
import 'package:go_nomads_app/widgets/location_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
        const SizedBox(height: 16),
        _buildTextField(controller: _c.addressController, label: l10n.address, hint: l10n.addressHint, required: true),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
        _buildLocationPicker(l10n),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? l10n.thisFieldIsRequired : null : null,
    );
  }

  Widget _buildLocationPicker(AppLocalizations l10n) {
    return Obx(() {
      final lat = _c.latitude.value;
      final lng = _c.longitude.value;
      return Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[300]!)),
        child: ListTile(
          leading: const Icon(FontAwesomeIcons.map, color: Color(0xFFFF4458)),
          title: (lat != 0 && lng != 0) ? Text(l10n.locationCoordinates(lat.toStringAsFixed(6), lng.toStringAsFixed(6))) : Text(l10n.pickLocationOnMap),
          trailing: const Icon(FontAwesomeIcons.arrowRight, size: 16),
          onTap: () async {
            final result = await Get.to(() => FlutterMapPickerPage(
                  initialLatitude: lat != 0 ? lat : null,
                  initialLongitude: lng != 0 ? lng : null,
                  searchQuery: _c.addressController.text.trim().isNotEmpty ? _c.addressController.text.trim() : null,
                  country: _c.selectedCountry.value,
                  city: _c.selectedCity.value,
                ));
            if (result != null && result is Map<String, dynamic>) {
              _c.updateCoordinates(result['latitude'] ?? 0.0, result['longitude'] ?? 0.0);
            }
          },
        ),
      );
    });
  }
}
