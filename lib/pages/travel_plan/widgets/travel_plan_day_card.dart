import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/features/travel_plan/domain/entities/travel_plan.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 每日行程卡片组件 - 无状态组件
class TravelPlanDayCard extends StatelessWidget {
  final DailyItinerary dayItinerary;
  final VoidCallback? onReplan;
  final ValueChanged<String>? onReplanPeriod;
  final List<String> availablePeriodKeys;
  final bool isHighlighted;
  final String? highlightedPeriodKey;

  const TravelPlanDayCard({
    super.key,
    required this.dayItinerary,
    this.onReplan,
    this.onReplanPeriod,
    this.availablePeriodKeys = const ['morning', 'afternoon', 'evening'],
    this.isHighlighted = false,
    this.highlightedPeriodKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFFFFBF7) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isHighlighted ? const Color(0xFFFFD9BF) : Colors.grey[200]!,
          width: isHighlighted ? 1.4 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFFFF7A57).withValues(alpha: 0.08),
                  blurRadius: 12.r,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  l10n.dayNumber(dayItinerary.day),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  dayItinerary.theme,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onReplan != null) ...[
                SizedBox(width: 8.w),
                TextButton.icon(
                  onPressed: onReplan,
                  icon: Icon(FontAwesomeIcons.wandMagicSparkles, size: 12.r),
                  label: Text(
                    '重排这一天',
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF4458),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ],
          ),
          if (isHighlighted) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E8),
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                highlightedPeriodKey == null ? '当前重点调整：这一天' : '当前重点调整：${_periodLabel(highlightedPeriodKey)}',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFF7A57),
                ),
              ),
            ),
          ],
          if (onReplanPeriod != null) ...[
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: const [
                _PeriodReplanChipData(key: 'morning', label: '改上午'),
                _PeriodReplanChipData(key: 'afternoon', label: '改下午'),
                _PeriodReplanChipData(key: 'evening', label: '改晚上'),
              ]
                  .where((item) => availablePeriodKeys.contains(item.key))
                  .map(
                    (item) => _PeriodReplanChip(
                      data: item,
                      isHighlighted: highlightedPeriodKey == item.key,
                      onTap: () => onReplanPeriod!(item.key),
                    ),
                  )
                  .toList(),
            ),
          ],
          SizedBox(height: 16.h),
          // 活动列表
          ...dayItinerary.activities.map(
            (activity) => _ActivityItem(
              activity: activity,
              isHighlighted: highlightedPeriodKey != null && _matchesPeriod(activity.time, highlightedPeriodKey!),
            ),
          ),
          // 备注
          if (dayItinerary.notes != null && dayItinerary.notes!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(FontAwesomeIcons.circleInfo, size: 16.r, color: Colors.amber),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      dayItinerary.notes!,
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

class _PeriodReplanChipData {
  final String key;
  final String label;

  const _PeriodReplanChipData({
    required this.key,
    required this.label,
  });
}

class _PeriodReplanChip extends StatelessWidget {
  final _PeriodReplanChipData data;
  final VoidCallback onTap;
  final bool isHighlighted;

  const _PeriodReplanChip({
    required this.data,
    required this.onTap,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: isHighlighted ? const Color(0xFFFF4458) : const Color(0xFFFFF4F6),
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: isHighlighted ? const Color(0xFFFF4458) : const Color(0xFFFFD9DE)),
        ),
        child: Text(
          data.label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isHighlighted ? Colors.white : const Color(0xFFFF4458),
          ),
        ),
      ),
    );
  }
}

String? _periodLabel(String? key) {
  switch (key) {
    case 'morning':
      return '上午';
    case 'afternoon':
      return '下午';
    case 'evening':
      return '晚上';
    default:
      return null;
  }
}

bool _matchesPeriod(String rawTime, String targetPeriod) {
  final normalized = rawTime.trim().toLowerCase();
  if (normalized.isEmpty) {
    return false;
  }

  if (normalized.contains('上午') || normalized.contains('早上') || normalized.contains('morning')) {
    return targetPeriod == 'morning';
  }
  if (normalized.contains('下午') || normalized.contains('午后') || normalized.contains('afternoon')) {
    return targetPeriod == 'afternoon';
  }
  if (normalized.contains('晚上') ||
      normalized.contains('夜间') ||
      normalized.contains('傍晚') ||
      normalized.contains('evening') ||
      normalized.contains('night')) {
    return targetPeriod == 'evening';
  }

  final match = RegExp(r'(\d{1,2})[:：]?(\d{2})?').firstMatch(normalized);
  final hour = int.tryParse(match?.group(1) ?? '');
  if (hour == null) {
    return false;
  }

  if (hour < 12) {
    return targetPeriod == 'morning';
  }
  if (hour < 18) {
    return targetPeriod == 'afternoon';
  }
  return targetPeriod == 'evening';
}

/// 活动项组件
class _ActivityItem extends StatelessWidget {
  final PlannedActivity activity;
  final bool isHighlighted;

  const _ActivityItem({required this.activity, this.isHighlighted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60.w,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: isHighlighted ? const Color(0xFFFFEDE4) : Colors.grey[100],
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              activity.time,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: isHighlighted ? EdgeInsets.all(10.w) : EdgeInsets.zero,
              decoration: isHighlighted
                  ? BoxDecoration(
                      color: const Color(0xFFFFFBF7),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: const Color(0xFFFFE0CC)),
                    )
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isHighlighted)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF1E8),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            '本次重点',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFFF7A57),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    activity.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.locationDot, size: 12.r, color: Colors.grey[500]),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          activity.location,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[500],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(FontAwesomeIcons.dollarSign, size: 12.r, color: Colors.grey[500]),
                      Text(
                        '\$${activity.estimatedCost.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[500],
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
