import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CoworkingDetailPricingSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailPricingSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final space = _c.space.value;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pricing, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                if (space.pricing.hourlyRate != null)
                  Expanded(child: _buildPriceCard(l10n.hourly, space.pricing.hourlyRate!, space.pricing.currency, FontAwesomeIcons.clock)),
                if (space.pricing.dailyRate != null) ...[
                  if (space.pricing.hourlyRate != null) const SizedBox(width: 8),
                  Expanded(child: _buildPriceCard(l10n.daily, space.pricing.dailyRate!, space.pricing.currency, FontAwesomeIcons.calendarDay)),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (space.pricing.weeklyRate != null)
                  Expanded(child: _buildPriceCard(l10n.weekly, space.pricing.weeklyRate!, space.pricing.currency, FontAwesomeIcons.calendarDays)),
                if (space.pricing.monthlyRate != null) ...[
                  if (space.pricing.weeklyRate != null) const SizedBox(width: 8),
                  Expanded(child: _buildPriceCard(l10n.monthly, space.pricing.monthlyRate!, space.pricing.currency, FontAwesomeIcons.calendarDays)),
                ],
              ],
            ),
            if (space.pricing.hasFreeTrial) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.tag, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${l10n.freeTrialAvailable} ${space.pricing.trialDuration ?? ''}',
                        style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildPriceCard(String label, double price, String currency, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 4),
          Text('$currency ${price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CoworkingDetailSpecsSection extends StatelessWidget {
  final String controllerTag;

  const CoworkingDetailSpecsSection({super.key, required this.controllerTag});

  CoworkingDetailPageController get _c => Get.find<CoworkingDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final space = _c.space.value;
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.specifications, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildSpecCard(l10n.wifiSpeed, '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? 'N/A'} Mbps', FontAwesomeIcons.wifi, Colors.blue)),
                const SizedBox(width: 8),
                Expanded(child: _buildSpecCard(l10n.capacity, '${space.specs.capacity ?? 'N/A'} ${l10n.people}', FontAwesomeIcons.users, Colors.green)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (space.specs.numberOfDesks != null)
                  Expanded(child: _buildSpecCard(l10n.desks, '${space.specs.numberOfDesks}', FontAwesomeIcons.chair, Colors.orange)),
                if (space.specs.numberOfMeetingRooms != null) ...[
                  if (space.specs.numberOfDesks != null) const SizedBox(width: 8),
                  Expanded(child: _buildSpecCard(l10n.meetingRooms, '${space.specs.numberOfMeetingRooms}', FontAwesomeIcons.doorOpen, Colors.purple)),
                ],
              ],
            ),
            if (space.specs.noiseLevel != null) ...[
              const SizedBox(height: 8),
              _buildSpecCard(l10n.noiseLevel, _getNoiseDisplayText(space.specs.noiseLevel!, l10n), FontAwesomeIcons.volumeLow, Colors.red),
            ],
            if (space.specs.spaceType != null) ...[
              const SizedBox(height: 8),
              _buildSpecCard('Space Type', _getSpaceTypeDisplayText(space.specs.spaceType!, l10n), FontAwesomeIcons.gaugeHigh, Colors.indigo),
            ],
            if (space.specs.hasNaturalLight) ...[
              const SizedBox(height: 8),
              _buildSpecCard('Natural Light', 'Available', FontAwesomeIcons.sun, Colors.amber),
            ],
          ],
        ),
      );
    });
  }

  String _getNoiseDisplayText(NoiseLevel level, AppLocalizations l10n) {
    switch (level) {
      case NoiseLevel.quiet:
        return 'Quiet';
      case NoiseLevel.moderate:
        return 'Moderate';
      case NoiseLevel.loud:
        return 'Loud';
    }
  }

  String _getSpaceTypeDisplayText(SpaceType type, AppLocalizations l10n) {
    switch (type) {
      case SpaceType.open:
        return 'Open Space';
      case SpaceType.private:
        return 'Private Space';
      case SpaceType.mixed:
        return 'Mixed Space';
    }
  }

  Widget _buildSpecCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
