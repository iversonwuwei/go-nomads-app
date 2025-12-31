import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/controllers/meetup_detail_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class MeetupDetailImageSection extends StatelessWidget {
  final String controllerTag;

  const MeetupDetailImageSection({super.key, required this.controllerTag});

  MeetupDetailPageController get _c => Get.find<MeetupDetailPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_c.meetup.value.images.isEmpty) {
        return Container(
          color: AppColors.borderLight,
          child: Icon(FontAwesomeIcons.calendarDays, size: 64.sp, color: AppColors.textTertiary),
        );
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          // 图片轮播
          PageView.builder(
            controller: _c.imagePageController,
            itemCount: _c.meetup.value.images.length,
            onPageChanged: _c.onImagePageChanged,
            itemBuilder: (context, index) {
              return Image.network(
                _c.meetup.value.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.borderLight,
                    child: Icon(FontAwesomeIcons.imagePortrait, size: 64.sp, color: AppColors.textTertiary),
                  );
                },
              );
            },
          ),
          // 图片指示器
          if (_c.meetup.value.images.length > 1)
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _c.meetup.value.images.length,
                  (index) => Container(
                    width: _c.currentImageIndex.value == index ? 24.w : 8.w,
                    height: 8.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      color: _c.currentImageIndex.value == index ? Colors.white : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              )),
            ),
          // 图片计数器
          if (_c.meetup.value.images.length > 1)
            Positioned(
              top: 100.h,
              right: 16.w,
              child: Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_c.currentImageIndex.value + 1} / ${_c.meetup.value.images.length}',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.w500),
                ),
              )),
            ),
        ],
      );
    });
  }
}
