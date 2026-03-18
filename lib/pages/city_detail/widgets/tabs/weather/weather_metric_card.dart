import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 天气指标卡片 - 显示单个天气指标（如湿度、风速等）
class WeatherMetricCard extends StatelessWidget {
  const WeatherMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? const Color(0xFFFF4458), size: 20.r),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
            ),
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 天气指标网格 - 响应式布局显示多个指标卡片
class WeatherMetricsGrid extends StatelessWidget {
  const WeatherMetricsGrid({
    super.key,
    required this.metrics,
  });

  final List<WeatherMetricData> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        const spacing = 16.0;

        // 计算可以放置的卡片数量(2或3列)
        int crossAxisCount = 2;
        if (screenWidth > 600) {
          crossAxisCount = 3;
        }

        // 计算每个卡片的宽度
        final totalSpacing = spacing * (crossAxisCount - 1);
        final cardWidth = (screenWidth - totalSpacing) / crossAxisCount;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: metrics.map((metric) {
            return SizedBox(
              width: cardWidth,
              child: WeatherMetricCard(
                icon: metric.icon,
                label: metric.label,
                value: metric.value,
                subtitle: metric.subtitle,
                iconColor: metric.iconColor,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// 天气指标数据类
class WeatherMetricData {
  const WeatherMetricData({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? iconColor;
}
