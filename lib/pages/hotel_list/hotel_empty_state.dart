import 'package:go_nomads_app/controllers/hotel_list_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 空状态组件
class HotelEmptyState extends StatelessWidget {
  final String controllerTag;

  const HotelEmptyState({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);

    return RefreshIndicator(
      onRefresh: controller.loadHotels,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 图标
                Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    FontAwesomeIcons.hotel,
                    size: 48.w,
                    color: Colors.grey[400],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'No hotels yet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: 0.5.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  'Help build the community',
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                // 添加按钮 - 所有用户都可以看到，点击时会检查权限
                InkWell(
                  onTap: controller.navigateToAddHotel,
                  borderRadius: BorderRadius.circular(30.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          FontAwesomeIcons.plus,
                          size: 20.w,
                          color: Colors.grey[700],
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Add First Hotel',
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
