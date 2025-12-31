import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/coworking_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailAmenitiesSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailAmenitiesSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final amenities = _c.space.value.amenities.getAvailableAmenities();
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.amenities, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amenities.map((amenity) {
                final (icon, color) = _getAmenityIconAndColor(amenity);
                return Chip(
                  avatar: Icon(icon, size: 18, color: color),
                  label: Text(amenity),
                  backgroundColor: color.withAlpha(26),
                  side: BorderSide(color: color.withAlpha(77)),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  (IconData, Color) _getAmenityIconAndColor(String amenity) {
    if (amenity.contains('WiFi')) {
      return (FontAwesomeIcons.wifi, Colors.blue);
    } else if (amenity.contains('Coffee')) {
      return (FontAwesomeIcons.mugSaucer, Colors.brown);
    } else if (amenity.contains('Printer')) {
      return (FontAwesomeIcons.print, Colors.grey);
    } else if (amenity.contains('Meeting')) {
      return (FontAwesomeIcons.doorOpen, Colors.purple);
    } else if (amenity.contains('Phone')) {
      return (FontAwesomeIcons.phone, Colors.orange);
    } else if (amenity.contains('Kitchen')) {
      return (FontAwesomeIcons.kitchenSet, Colors.red);
    } else if (amenity.contains('Parking')) {
      return (FontAwesomeIcons.squareParking, Colors.indigo);
    } else if (amenity.contains('24/7')) {
      return (FontAwesomeIcons.clock, Colors.deepOrange);
    } else if (amenity.contains('A/C') || amenity.contains('Air')) {
      return (FontAwesomeIcons.snowflake, Colors.cyan);
    } else if (amenity.contains('Shower')) {
      return (FontAwesomeIcons.shower, Colors.lightBlue);
    } else if (amenity.contains('Standing Desk')) {
      return (FontAwesomeIcons.chair, Colors.teal);
    } else if (amenity.contains('Locker')) {
      return (FontAwesomeIcons.lock, Colors.blueGrey);
    } else if (amenity.contains('Bike')) {
      return (FontAwesomeIcons.personBiking, Colors.lightGreen);
    } else if (amenity.contains('Event')) {
      return (FontAwesomeIcons.calendarDays, Colors.deepPurple);
    } else if (amenity.contains('Pet')) {
      return (FontAwesomeIcons.paw, Colors.pink);
    }
    return (FontAwesomeIcons.circleCheck, Colors.green);
  }
}

class CoworkingDetailOpeningHoursSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailOpeningHoursSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      if (!_c.space.value.operationHours.hasHours) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.openingHours, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ..._c.space.value.operationHours.hours.map((hours) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(FontAwesomeIcons.clock, size: 20),
                          const SizedBox(width: 12),
                          Text(hours, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const Divider(),
        ],
      );
    });
  }
}
