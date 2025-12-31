import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/create_travel_plan_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 景点选择部分
class TravelPlanAttractionsSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanAttractionsSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('想去的景点', FontAwesomeIcons.city),
        const SizedBox(height: 8),
        Text(
          '选择您在${_c.cityName}想要游览的景点类型',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _c.cityAttractions.map((attraction) {
                return _buildAttractionChip(
                  attraction['name'] as String,
                  attraction['id'] as String,
                  attraction['icon'] as IconData,
                );
              }).toList(),
            )),
      ],
    );
  }

  Widget _buildAttractionChip(String label, String id, IconData icon) {
    final isSelected = _c.selectedAttractions.contains(id);
    return GestureDetector(
      onTap: () => _c.toggleAttraction(id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFFFF4458)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

/// 旅行风格部分
class TravelPlanStyleSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanStyleSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.travelStyle, FontAwesomeIcons.paintbrush),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStyleChip(l10n.culture, 'culture', FontAwesomeIcons.landmark),
                _buildStyleChip(l10n.adventure, 'adventure', FontAwesomeIcons.mountain),
                _buildStyleChip(l10n.relaxation, 'relaxation', FontAwesomeIcons.spa),
                _buildStyleChip(l10n.nightlife, 'nightlife', FontAwesomeIcons.champagneGlasses),
              ],
            )),
      ],
    );
  }

  Widget _buildStyleChip(String label, String value, IconData icon) {
    final isSelected = _c.travelStyle.value == value;
    return GestureDetector(
      onTap: () => _c.setTravelStyle(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.black54),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
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

/// 兴趣爱好部分
class TravelPlanInterestsSection extends StatelessWidget {
  final String controllerTag;

  const TravelPlanInterestsSection({super.key, required this.controllerTag});

  CreateTravelPlanPageController get _c => Get.find<CreateTravelPlanPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.interests, FontAwesomeIcons.heart),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInterestChip(l10n.photography),
                _buildInterestChip(l10n.history),
                _buildInterestChip('Art'),
                _buildInterestChip(l10n.nature),
                _buildInterestChip('Beach'),
                _buildInterestChip('Temples'),
                _buildInterestChip('Markets'),
                _buildInterestChip('Coffee'),
              ],
            )),
      ],
    );
  }

  Widget _buildInterestChip(String label) {
    final isSelected = _c.interests.contains(label);
    return GestureDetector(
      onTap: () => _c.toggleInterest(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
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
