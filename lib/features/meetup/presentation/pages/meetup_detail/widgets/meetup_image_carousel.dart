import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/meetup/presentation/pages/meetup_detail/meetup_detail_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 图片轮播组件
///
/// 显示活动的图片列表，支持左右滑动
class MeetupImageCarousel extends GetView<MeetupDetailController> {
  const MeetupImageCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final meetup = controller.meetup.value;
      if (meetup == null) return const SizedBox.shrink();

      if (meetup.images.isEmpty) {
        return _buildPlaceholder();
      }

      return Stack(
        fit: StackFit.expand,
        children: [
          // 图片轮播
          PageView.builder(
            controller: controller.imagePageController,
            itemCount: meetup.images.length,
            onPageChanged: controller.onImagePageChanged,
            itemBuilder: (context, index) {
              return Image.network(
                meetup.images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              );
            },
          ),
          // 图片指示器 - 只有多张图片时显示
          if (meetup.images.length > 1) _buildIndicators(meetup.images.length),
          // 图片计数器
          if (meetup.images.length > 1) _buildCounter(meetup.images.length),
        ],
      );
    });
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cityPrimaryLight,
            AppColors.surfaceSubtle,
          ],
        ),
      ),
      child: Icon(
        FontAwesomeIcons.calendarDays,
        size: 64.sp,
        color: AppColors.cityPrimary.withValues(alpha: 0.38),
      ),
    );
  }

  Widget _buildIndicators(int count) {
    return Positioned(
      bottom: 16.h,
      left: 0,
      right: 0,
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              count,
              (index) => Container(
                width: controller.currentImageIndex.value == index ? 24.w : 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: controller.currentImageIndex.value == index
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildCounter(int count) {
    return Positioned(
      top: 100.h,
      right: 16.w,
      child: Obx(() => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Text(
              '${controller.currentImageIndex.value + 1} / $count',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
    );
  }
}
