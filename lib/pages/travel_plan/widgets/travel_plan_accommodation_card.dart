import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  accommodation.type.name,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '\$${accommodation.pricePerNight.toStringAsFixed(0)}/$pricePerNightLabel',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF4458),
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
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(FontAwesomeIcons.locationDot, size: 14.r, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                accommodation.recommendedArea,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey[600],
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
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(fontSize: 11.sp),
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.lightbulb, size: 16.r, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      accommodation.bookingTips!,
                      style: TextStyle(fontSize: 12.sp),
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
