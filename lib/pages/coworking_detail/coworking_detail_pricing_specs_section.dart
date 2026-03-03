import 'package:go_nomads_app/features/coworking/domain/entities/coworking_space.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pricing, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Row(
              children: [
                if (space.pricing.hourlyRate != null)
                  Expanded(child: _buildPriceCard(l10n.hourly, space.pricing.hourlyRate!, space.pricing.currency, FontAwesomeIcons.clock)),
                if (space.pricing.dailyRate != null) ...[
                  if (space.pricing.hourlyRate != null) SizedBox(width: 8.w),
                  Expanded(child: _buildPriceCard(l10n.daily, space.pricing.dailyRate!, space.pricing.currency, FontAwesomeIcons.calendarDay)),
                ],
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (space.pricing.weeklyRate != null)
                  Expanded(child: _buildPriceCard(l10n.weekly, space.pricing.weeklyRate!, space.pricing.currency, FontAwesomeIcons.calendarDays)),
                if (space.pricing.monthlyRate != null) ...[
                  if (space.pricing.weeklyRate != null) SizedBox(width: 8.w),
                  Expanded(child: _buildPriceCard(l10n.monthly, space.pricing.monthlyRate!, space.pricing.currency, FontAwesomeIcons.calendarDays)),
                ],
              ],
            ),
            if (space.pricing.hasFreeTrial) ...[
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(FontAwesomeIcons.tag, color: Colors.green[700]),
                    SizedBox(width: 8.w),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700]),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Text('$currency ${price.toStringAsFixed(0)}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.specifications, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildSpecCard(l10n.wifiSpeed, '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? 'N/A'} Mbps', FontAwesomeIcons.wifi, Colors.blue)),
                SizedBox(width: 8.w),
                Expanded(child: _buildSpecCard(l10n.capacity, '${space.specs.capacity ?? 'N/A'} ${l10n.people}', FontAwesomeIcons.users, Colors.green)),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                if (space.specs.numberOfDesks != null)
                  Expanded(child: _buildSpecCard(l10n.desks, '${space.specs.numberOfDesks}', FontAwesomeIcons.chair, Colors.orange)),
                if (space.specs.numberOfMeetingRooms != null) ...[
                  if (space.specs.numberOfDesks != null) SizedBox(width: 8.w),
                  Expanded(child: _buildSpecCard(l10n.meetingRooms, '${space.specs.numberOfMeetingRooms}', FontAwesomeIcons.doorOpen, Colors.purple)),
                ],
              ],
            ),
            if (space.specs.noiseLevel != null) ...[
              SizedBox(height: 8.h),
              _buildSpecCard(l10n.noiseLevel, _getNoiseDisplayText(space.specs.noiseLevel!, l10n), FontAwesomeIcons.volumeLow, Colors.red),
            ],
            if (space.specs.spaceType != null) ...[
              SizedBox(height: 8.h),
              _buildSpecCard('Space Type', _getSpaceTypeDisplayText(space.specs.spaceType!, l10n), FontAwesomeIcons.gaugeHigh, Colors.indigo),
            ],
            if (space.specs.hasNaturalLight) ...[
              SizedBox(height: 8.h),
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
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
                Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
