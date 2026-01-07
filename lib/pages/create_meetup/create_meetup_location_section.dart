import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/create_meetup_page_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/pages/venue_map_picker/venue_map_picker_page.dart';
import 'package:df_admin_mobile/widgets/location_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CreateMeetupLocationSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupLocationSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // City picker
        Obx(() => LocationPickerField(
              initialCountryId: _c.selectedCountryId.value,
              initialCountryName: _c.selectedCountry.value,
              initialCityId: _c.selectedCityId.value,
              initialCityName: _c.selectedCity.value,
              required: true,
              onChanged: (result) {
                _c.selectedCountryId.value = result.countryId;
                _c.selectedCountry.value = result.countryName;
                _c.selectedCityId.value = result.cityId;
                _c.selectedCity.value = result.cityName;
              },
            )),

        const SizedBox(height: 20),

        // Venue
        Text(l10n.venue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
        const SizedBox(height: 8),
        _buildVenueInput(context, l10n),
      ],
    );
  }

  Widget _buildVenueInput(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Obx(() => TextFormField(
                    controller: _c.venueController,
                    decoration: InputDecoration(
                      hintText: l10n.enterVenue,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: _c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty
                                ? Theme.of(context).colorScheme.error
                                : AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: _c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty
                                ? Theme.of(context).colorScheme.error
                                : const Color(0xFFFF4458)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        _c.venueErrorText.value = l10n.pleaseEnterVenue;
                        return '';
                      }
                      _c.venueErrorText.value = null;
                      return null;
                    },
                  )),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () => _selectVenueFromMap(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Icon(FontAwesomeIcons.map, size: 20),
              ),
            ),
          ],
        ),
        Obx(() {
          if (_c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text(_c.venueErrorText.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _selectVenueFromMap(BuildContext context) async {
    // 获取用户已输入的场地地址
    final venueAddress = _c.venueController.text.trim();

    final result = await Get.to<Map<String, dynamic>>(
      () => VenueMapPickerPage(
        cityName: _c.selectedCity.value ?? 'Bangkok',
        initialVenueAddress: venueAddress.isNotEmpty ? venueAddress : null,
      ),
    );

    if (result != null) {
      _c.setVenueFromMap(result);
    }
  }
}
