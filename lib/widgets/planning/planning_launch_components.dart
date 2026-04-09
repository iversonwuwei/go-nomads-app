import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlanningStageChip extends StatelessWidget {
  final String label;
  final String value;
  final double? minWidth;
  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final Color valueColor;
  final EdgeInsetsGeometry? padding;

  const PlanningStageChip({
    super.key,
    required this.label,
    required this.value,
    this.minWidth,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderColor = const Color(0xFFE3E7EF),
    this.labelColor = const Color(0xFF6B7280),
    this.valueColor = const Color(0xFF111827),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: minWidth == null ? null : BoxConstraints(minWidth: minWidth!),
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: labelColor,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: valueColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class PlanningPreviewCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color tint;
  final Color backgroundColor;
  final double borderOpacity;

  const PlanningPreviewCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.tint,
    this.backgroundColor = const Color(0xFFFFFFFF),
    this.borderOpacity = 0.12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: tint.withValues(alpha: borderOpacity)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 13.r, color: tint),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
