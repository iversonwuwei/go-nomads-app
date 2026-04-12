import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/controllers/coworking_detail_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

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
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.amenities,
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: amenities.map((amenity) {
                final (icon, color) = _getAmenityIconAndColor(amenity);
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: color.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(icon, size: 14.r, color: color),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        amenity,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
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
          Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.openingHours,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                SizedBox(height: 16.h),
                ..._c.space.value.operationHours.hours.map((hours) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: AppUiTokens.softFloatingShadow,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: AppColors.cityPrimaryLight,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(FontAwesomeIcons.clock, size: 14.r, color: AppColors.cityPrimary),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                hours,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      );
    });
  }
}
