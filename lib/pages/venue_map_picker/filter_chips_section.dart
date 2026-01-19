import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/venue_map_picker_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 筛选器芯片组件
class FilterChipsSection extends StatelessWidget {
  final String controllerTag;

  const FilterChipsSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueMapPickerPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    final filters = [
      {'key': 'All', 'label': l10n.all, 'icon': FontAwesomeIcons.layerGroup},
      {'key': 'hotel', 'label': l10n.hotels, 'icon': FontAwesomeIcons.hotel},
      {'key': 'cafe', 'label': 'Cafes', 'icon': FontAwesomeIcons.mugHot},
      {'key': 'restaurant', 'label': l10n.restaurants, 'icon': FontAwesomeIcons.utensils},
      {'key': 'shopping', 'label': 'Shopping', 'icon': FontAwesomeIcons.bagShopping},
      {'key': 'attraction', 'label': 'Attractions', 'icon': FontAwesomeIcons.mountain},
    ];

    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                final isSelected = controller.selectedFilter.value == filter['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    avatar: Icon(filter['icon'] as IconData, size: 14),
                    label: Text(filter['label'] as String),
                    selected: isSelected,
                    onSelected: (_) => controller.onFilterChanged(filter['key'] as String),
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ));
  }
}
