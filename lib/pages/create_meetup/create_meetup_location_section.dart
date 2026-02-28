import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/venue_map_picker/venue_map_picker_page.dart';
import 'package:go_nomads_app/widgets/location_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

        SizedBox(height: 20.h),

        // Venue
        Text(l10n.venue, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
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
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: _c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty
                                ? Theme.of(context).colorScheme.error
                                : AppColors.borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                            color: _c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty
                                ? Theme.of(context).colorScheme.error
                                : const Color(0xFFFF4458)),
                      ),
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
            SizedBox(width: 12.w),
            SizedBox(
              child: ElevatedButton(
                onPressed: () => _selectVenueFromMap(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                child: Icon(FontAwesomeIcons.map, size: 20.r),
              ),
            ),
          ],
        ),
        Obx(() {
          if (_c.venueErrorText.value != null && _c.venueErrorText.value!.isNotEmpty) {
            return Padding(
              padding: EdgeInsets.only(left: 8.w, top: 4.h),
              child: Text(_c.venueErrorText.value!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12.sp)),
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
