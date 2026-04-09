import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';

/// 住宿卡片组件 - 无状态组件
class TravelPlanAccommodationCard extends StatelessWidget {
  final TripAccommodation accommodation;
  final String pricePerNightLabel;

  const TravelPlanAccommodationCard({
    super.key,
    required this.accommodation,
    required this.pricePerNightLabel,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                ),
                child: Text(
                  accommodation.type.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cityPrimary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '\$${accommodation.pricePerNight.toStringAsFixed(0)}/$pricePerNightLabel',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cityPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            accommodation.recommendation,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(FontAwesomeIcons.locationDot, size: 14.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  accommodation.recommendedArea,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // 设施标签
          Wrap(
            spacing: 8.w,
            runSpacing: 8.w,
            children: accommodation.amenities
                .map((amenity) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textPrimary),
                      ),
                    ))
                .toList(),
          ),
          // 预订提示
          if (accommodation.bookingTips != null && accommodation.bookingTips!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.lightbulb, size: 16.r, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      accommodation.bookingTips!,
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
