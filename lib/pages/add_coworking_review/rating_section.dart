import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_coworking_review_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

/// 评分区域组件
class RatingSection extends StatelessWidget {
  final String controllerTag;

  const RatingSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddCoworkingReviewPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Obx(() => Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                controller.getRatingColor(controller.rating.value).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: controller.getRatingColor(controller.rating.value).withValues(alpha: 0.15),
                blurRadius: 20.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Column(
            children: [
              // 标题
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.faceSmile,
                    color: controller.getRatingColor(controller.rating.value),
                    size: 24.sp,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    l10n.overallRating,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // 大表情符号显示
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  controller.getRatingEmoji(controller.rating.value),
                  key: ValueKey<double>(controller.rating.value),
                  style: TextStyle(
                    fontSize: 80.sp,
                    height: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // 评分文字
              Column(
                children: [
                  Text(
                    controller.rating.value == 0
                        ? l10n.tapStarsToRate
                        : controller.getRatingLabel(
                            controller.rating.value,
                            excellent: l10n.excellent,
                            good: l10n.good,
                            fair: l10n.fair,
                            poor: l10n.poor,
                            veryPoor: l10n.veryPoor,
                          ),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: controller.getRatingColor(controller.rating.value),
                    ),
                  ),
                  if (controller.rating.value > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${controller.rating.value.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF666666),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 32.h),

              // 滑动条
              _buildSlider(controller),
            ],
          ),
        ));
  }

  Widget _buildSlider(AddCoworkingReviewPageController controller) {
    return Column(
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8.h,
            activeTrackColor: controller.getRatingColor(controller.rating.value),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: Colors.white,
            overlayColor: controller.getRatingColor(controller.rating.value).withValues(alpha: 0.2),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 16.r,
              elevation: 4,
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 28.r,
            ),
            trackShape: const RoundedRectSliderTrackShape(),
          ),
          child: Slider(
            value: controller.rating.value,
            min: 0,
            max: 5,
            divisions: 10,
            onChanged: (value) {
              controller.rating.value = value;
            },
          ),
        ),
        SizedBox(height: 12.h),
        // 表情符号刻度
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final value = index.toDouble();
              final isSelected = (controller.rating.value - value).abs() < 0.3;
              return GestureDetector(
                onTap: () => controller.rating.value = value,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 8.w : 4.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? controller.getRatingColor(value).withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    controller.getRatingEmoji(value),
                    style: TextStyle(
                      fontSize: isSelected ? 28.sp : 20.sp,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
