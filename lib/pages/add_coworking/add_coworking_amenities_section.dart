import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddCoworkingAmenitiesSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingAmenitiesSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.amenities, FontAwesomeIcons.listCheck),
        const SizedBox(height: 16),
        _buildAmenitiesGrid(l10n),
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

  Widget _buildAmenitiesGrid(AppLocalizations l10n) {
    final amenities = [
      _AmenityItem(icon: FontAwesomeIcons.wifi, label: l10n.wifi, value: _c.hasWifi, onChanged: (v) => _c.hasWifi.value = v),
      _AmenityItem(icon: FontAwesomeIcons.mugHot, label: l10n.coffee, value: _c.hasCoffee, onChanged: (v) => _c.hasCoffee.value = v),
      _AmenityItem(icon: FontAwesomeIcons.print, label: l10n.printer, value: _c.hasPrinter, onChanged: (v) => _c.hasPrinter.value = v),
      _AmenityItem(icon: FontAwesomeIcons.video, label: l10n.meetingRooms, value: _c.hasMeetingRoom, onChanged: (v) => _c.hasMeetingRoom.value = v),
      _AmenityItem(icon: FontAwesomeIcons.phone, label: l10n.phoneBooth, value: _c.hasPhoneBooth, onChanged: (v) => _c.hasPhoneBooth.value = v),
      _AmenityItem(icon: FontAwesomeIcons.utensils, label: l10n.kitchen, value: _c.hasKitchen, onChanged: (v) => _c.hasKitchen.value = v),
      _AmenityItem(icon: FontAwesomeIcons.squareParking, label: l10n.parking, value: _c.hasParking, onChanged: (v) => _c.hasParking.value = v),
      _AmenityItem(icon: FontAwesomeIcons.shower, label: l10n.shower, value: _c.hasShower, onChanged: (v) => _c.hasShower.value = v),
      _AmenityItem(icon: FontAwesomeIcons.lock, label: l10n.locker, value: _c.hasLocker, onChanged: (v) => _c.hasLocker.value = v),
      _AmenityItem(icon: FontAwesomeIcons.clock, label: l10n.open24Hours, value: _c.has24HourAccess, onChanged: (v) => _c.has24HourAccess.value = v),
      _AmenityItem(icon: FontAwesomeIcons.snowflake, label: l10n.airConditioning, value: _c.hasAirConditioning, onChanged: (v) => _c.hasAirConditioning.value = v),
      _AmenityItem(icon: FontAwesomeIcons.paw, label: l10n.petFriendly, value: _c.hasPetFriendly, onChanged: (v) => _c.hasPetFriendly.value = v),
      _AmenityItem(icon: FontAwesomeIcons.bicycle, label: l10n.bikeStorage, value: _c.hasBike, onChanged: (v) => _c.hasBike.value = v),
      _AmenityItem(icon: FontAwesomeIcons.champagneGlasses, label: l10n.eventSpace, value: _c.hasEventSpace, onChanged: (v) => _c.hasEventSpace.value = v),
      _AmenityItem(icon: FontAwesomeIcons.chair, label: l10n.standingDesk, value: _c.hasStandingDesk, onChanged: (v) => _c.hasStandingDesk.value = v),
      _AmenityItem(icon: FontAwesomeIcons.sun, label: l10n.naturalLight, value: _c.hasNaturalLight, onChanged: (v) => _c.hasNaturalLight.value = v),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.5, crossAxisSpacing: 12, mainAxisSpacing: 12),
      itemCount: amenities.length,
      itemBuilder: (context, index) => _buildAmenityChip(amenities[index]),
    );
  }

  Widget _buildAmenityChip(_AmenityItem item) {
    return Obx(() => InkWell(
          onTap: () => item.onChanged(!item.value.value),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: item.value.value ? const Color(0xFFFF4458).withAlpha(25) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: item.value.value ? const Color(0xFFFF4458) : Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(item.icon, size: 18, color: item.value.value ? const Color(0xFFFF4458) : Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(child: Text(item.label, style: TextStyle(fontSize: 13, color: item.value.value ? const Color(0xFFFF4458) : AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
        ));
  }
}

class _AmenityItem {
  final IconData icon;
  final String label;
  final RxBool value;
  final Function(bool) onChanged;

  _AmenityItem({required this.icon, required this.label, required this.value, required this.onChanged});
}
