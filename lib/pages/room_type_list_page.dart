import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/controllers/room_type_list_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 房型列表页面
class RoomTypeListPage extends StatelessWidget {
  final String hotelId;
  final String hotelName;

  const RoomTypeListPage({
    super.key,
    required this.hotelId,
    required this.hotelName,
  });

  String get _tag => 'RoomTypeListPage_$hotelId';

  RoomTypeListPageController get _controller {
    if (!Get.isRegistered<RoomTypeListPageController>(tag: _tag)) {
      Get.put(
        RoomTypeListPageController(hotelId: hotelId, hotelName: hotelName),
        tag: _tag,
      );
    }
    return Get.find<RoomTypeListPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(hotelName),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const HotelListSkeleton();
        }

        if (controller.roomTypes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.hotel, size: 48.w, color: Colors.grey),
                SizedBox(height: 12.h),
                Text(
                  l10n.addHotelNoRoomTypes,
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.roomTypes.length,
          itemBuilder: (context, index) {
            final roomType = controller.roomTypes[index];
            return _buildRoomTypeCard(roomType, l10n);
          },
        );
      }),
    );
  }

  Widget _buildRoomTypeCard(RoomType roomType, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () {
          // TODO: 跳转到房型详情页或预订页
          AppToast.info(l10n.roomTypePreviewToast(roomType.name));
        },
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 房型图片
              if (roomType.images.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    roomType.images.first,
                    height: 180.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180.h,
                        color: Colors.grey[300],
                        child: Icon(FontAwesomeIcons.imagePortrait, size: 48.w, color: Colors.grey),
                      );
                    },
                  ),
                ),
              SizedBox(height: 12.h),

              // 房型名称
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      roomType.name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!roomType.isAvailable)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        '已满',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),

              // 房型描述
              if (roomType.description.isNotEmpty)
                Text(
                  roomType.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 12.h),

              // 房型信息
              Wrap(
                spacing: 16.w,
                runSpacing: 8.h,
                children: [
                  _buildInfoChip(
                    icon: FontAwesomeIcons.bed,
                    label: roomType.bedType,
                  ),
                  _buildInfoChip(
                    icon: FontAwesomeIcons.users,
                    label: '最多${roomType.maxOccupancy}人',
                  ),
                  _buildInfoChip(
                    icon: FontAwesomeIcons.rulerCombined,
                    label: '${roomType.size.toStringAsFixed(0)}㎡',
                  ),
                  if (roomType.isAvailable)
                    _buildInfoChip(
                      icon: FontAwesomeIcons.hotel,
                      label: '${roomType.availableRooms}间可用',
                      color: Colors.green,
                    ),
                ],
              ),
              SizedBox(height: 12.h),

              // 设施列表
              if (roomType.amenities.isNotEmpty)
                Wrap(
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: roomType.amenities.take(6).map((amenity) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        amenity,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blue[700],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 12.h),

              // 价格和预订按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${roomType.currency} ${roomType.pricePerNight.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        '每晚',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: roomType.isAvailable
                        ? () {
                            // TODO: 跳转到预订页面
                            AppToast.info(l10n.roomTypeBookingToast(roomType.name));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      roomType.isAvailable ? '立即预订' : '已满',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color? color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.w, color: color ?? Colors.grey[600]),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: color ?? Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
