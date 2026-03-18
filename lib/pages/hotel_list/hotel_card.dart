import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/hotel_list_page_controller.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/presentation/hotel_detail_page.dart' as hotel_detail;
import 'package:go_nomads_app/utils/navigation_util.dart';

/// 酒店卡片组件
class HotelCard extends StatelessWidget {
  final String controllerTag;
  final Hotel hotel;

  const HotelCard({
    super.key,
    required this.controllerTag,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);
    final priceLabel = hotel.currency.isNotEmpty
        ? '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}'
        : hotel.pricePerNight.toStringAsFixed(0);

    return GestureDetector(
      onTap: () async {
        // 跳转到酒店详情页面
        await NavigationUtil.toWithCallback<Hotel>(
          page: () => hotel_detail.HotelDetailPage(hotel: hotel),
          onResult: (result) {
            // 如果详情页返回了更新后的酒店数据，更新列表中的数据
            if (result.hasData) {
              controller.updateHotelInList(result.data!);
            }
          },
        );
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 16.h),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 酒店图片
            Stack(
              children: [
                hotel.images.isNotEmpty
                    ? Image.network(
                        hotel.images.first,
                        height: 200.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200.h,
                            color: Colors.grey[300],
                            child: Icon(FontAwesomeIcons.hotel, size: 64.r),
                          );
                        },
                      )
                    : Container(
                        height: 200.h,
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(FontAwesomeIcons.hotel, size: 64.r, color: Colors.grey[400]),
                        ),
                      ),
                // 精选标签
                if (hotel.isFeatured)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Row(
                        children: [
                          Icon(FontAwesomeIcons.star, size: 16.w, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: _SourceBadge(hotel: hotel, elevated: true),
                ),
              ],
            ),

            // 酒店信息
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 酒店名称
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),

                  // 城市名称
                  if (hotel.cityName.isNotEmpty)
                    Text(
                      hotel.cityName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  SizedBox(height: 8.h),

                  // 评分和类别
                  Row(
                    children: [
                      // 评分
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.star, size: 14.w, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text(
                              hotel.rating.toStringAsFixed(1),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),

                      // 评论数
                      Expanded(
                        child: Text(
                          '(${hotel.reviewCount} reviews) · ${hotel.category}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  Text(
                    hotel.isBookingHotel ? 'Live from Booking.com' : 'Community-contributed listing',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: hotel.isBookingHotel ? const Color(0xFF0A66C2) : const Color(0xFFB45309),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 价格
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          hotel.description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            priceLabel,
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'per night',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SourceBadge extends StatelessWidget {
  final Hotel hotel;
  final bool elevated;

  const _SourceBadge({required this.hotel, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = hotel.isBookingHotel ? const Color(0xFFE8F3FF) : const Color(0xFFFFF0E0);
    final foregroundColor = hotel.isBookingHotel ? const Color(0xFF0A66C2) : const Color(0xFFB45309);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: elevated ? Colors.white.withValues(alpha: 0.92) : backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(
          color: elevated ? foregroundColor.withValues(alpha: 0.25) : Colors.transparent,
        ),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12.r,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hotel.isBookingHotel ? Icons.public : Icons.people_alt_outlined,
            size: 10.sp,
            color: foregroundColor,
          ),
          SizedBox(width: 4.w),
          Text(
            hotel.sourceLabel,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
