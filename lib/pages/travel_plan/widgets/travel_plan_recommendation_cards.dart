import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 景点卡片组件 - 无状态组件
class TravelPlanAttractionCard extends StatelessWidget {
  final AttractionRecommendation attraction;

  const TravelPlanAttractionCard({super.key, required this.attraction});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
            child: Image.network(
              attraction.image ?? '',
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.image),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attraction.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    attraction.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.star, size: 12.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        attraction.rating.toString(),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      SizedBox(width: 12.w),
                      Icon(FontAwesomeIcons.dollarSign, size: 12.r, color: Color(0xFFFF4458)),
                      Text(
                        '\$${attraction.entryFee.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 11.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 餐厅卡片组件 - 无状态组件
class TravelPlanRestaurantCard extends StatelessWidget {
  final RestaurantRecommendation restaurant;

  const TravelPlanRestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(12.r)),
            child: Image.network(
              restaurant.image ?? '',
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: Colors.grey[300],
                  child: const Icon(FontAwesomeIcons.utensils),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.cuisine,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    restaurant.specialty,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.star, size: 12.r, color: Colors.amber),
                      SizedBox(width: 4.w),
                      Text(
                        restaurant.rating.toString(),
                        style: TextStyle(fontSize: 11.sp),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        restaurant.priceSymbol,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Color(0xFFFF4458),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 旅行提示项组件 - 无状态组件
class TravelPlanTipItem extends StatelessWidget {
  final String tip;

  const TravelPlanTipItem({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 6.w,
            height: 6.h,
            decoration: const BoxDecoration(
              color: Color(0xFFFF4458),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(fontSize: 13.sp),
            ),
          ),
        ],
      ),
    );
  }
}
