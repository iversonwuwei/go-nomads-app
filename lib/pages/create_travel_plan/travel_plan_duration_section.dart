import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 行程天数部分
class TravelPlanDurationSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanDurationSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.tripDuration, FontAwesomeIcons.calendar),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _c.duration.value.toDouble(),
                          min: 1,
                          max: 30,
                          divisions: 29,
                          label: l10n.days(_c.duration.value),
                          activeColor: const Color(0xFFFF4458),
                          inactiveColor: Colors.grey[300],
                          onChanged: (value) => _c.setDuration(value.toInt()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4458),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _c.duration.value.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 8),
              Obx(() => Text(
                    _c.duration.value == 1 ? l10n.day(1) : l10n.days(_c.duration.value),
                    style: const TextStyle(
                      color: Color(0xFFFF4458),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF4458)),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }
}
