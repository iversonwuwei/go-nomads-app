import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/meetup_list/meetup_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// Meetup 筛选抽屉组件
class MeetupFilterDrawer extends GetView<MeetupListController> {
  const MeetupFilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏
          _FilterHeader(l10n: l10n),
          // 筛选选项（可滚动）
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CountryFilter(l10n: l10n),
                  SizedBox(height: 24.h),
                  _CityFilter(l10n: l10n),
                  SizedBox(height: 24.h),
                  _TypeFilter(l10n: l10n),
                  SizedBox(height: 24.h),
                  _TimeFilter(l10n: l10n),
                  SizedBox(height: 24.h),
                  _MaxAttendeesFilter(l10n: l10n),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          // 底部应用按钮
          _FilterApplyButton(l10n: l10n),
        ],
      ),
    );
  }
}

/// 筛选头部
class _FilterHeader extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _FilterHeader({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.filters,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: controller.resetFilters,
                child: Text(
                  l10n.reset,
                  style: TextStyle(
                    color: const Color(0xFFFF4458),
                    fontWeight: FontWeight.w600,
                    fontSize: 15.sp,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 24.sp),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 国家筛选
class _CountryFilter extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _CountryFilter({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.country),
        SizedBox(height: 12.h),
        Text(
          l10n.autoDetectedLocation,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.availableCountries.map((country) {
                final isSelected = controller.selectedCountries.contains(country);
                return _buildFilterChip(
                  label: country,
                  isSelected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCountries.add(country);
                    } else {
                      controller.selectedCountries.remove(country);
                    }
                  },
                );
              }).toList(),
            )),
      ],
    );
  }
}

/// 城市筛选
class _CityFilter extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _CityFilter({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.city),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.availableCities.map((city) {
                final isSelected = controller.selectedCities.contains(city);
                return _buildFilterChip(
                  label: city,
                  isSelected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCities.add(city);
                    } else {
                      controller.selectedCities.remove(city);
                    }
                  },
                );
              }).toList(),
            )),
      ],
    );
  }
}

/// 类型筛选
class _TypeFilter extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _TypeFilter({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.meetupType),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: controller.availableTypes.map((type) {
                final isSelected = controller.selectedTypes.contains(type);
                return _buildFilterChip(
                  label: type,
                  isSelected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedTypes.add(type);
                    } else {
                      controller.selectedTypes.remove(type);
                    }
                  },
                );
              }).toList(),
            )),
      ],
    );
  }
}

/// 时间筛选
class _TimeFilter extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _TimeFilter({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.timeRange),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _buildTimeChip(l10n.all, 'all'),
                _buildTimeChip(l10n.today, 'today'),
                _buildTimeChip(l10n.thisWeek, 'week'),
                _buildTimeChip(l10n.thisMonth, 'month'),
              ],
            )),
      ],
    );
  }

  Widget _buildTimeChip(String label, String value) {
    final isSelected = controller.timeFilter.value == value;
    return _buildFilterChip(
      label: label,
      isSelected: isSelected,
      onSelected: (selected) {
        if (selected) {
          controller.timeFilter.value = value;
        }
      },
    );
  }
}

/// 最大人数筛选
class _MaxAttendeesFilter extends GetView<MeetupListController> {
  final AppLocalizations l10n;

  const _MaxAttendeesFilter({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.maximumAttendees),
        SizedBox(height: 12.h),
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.maxAttendees.value >= 100
                      ? l10n.peoplePlus
                      : l10n.peopleCount('${controller.maxAttendees.value}'),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Slider(
                  value: controller.maxAttendees.value.toDouble(),
                  min: 5,
                  max: 100,
                  divisions: 19,
                  activeColor: const Color(0xFFFF4458),
                  inactiveColor: AppColors.borderLight,
                  onChanged: (value) {
                    controller.maxAttendees.value = value.toInt();
                  },
                ),
              ],
            )),
      ],
    );
  }
}

/// 应用筛选按钮
class _FilterApplyButton extends StatelessWidget {
  final AppLocalizations l10n;

  const _FilterApplyButton({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              l10n.applyFilters,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 构建节标题
Widget _buildSectionTitle(String title) {
  return Text(
    title,
    style: TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: AppColors.textPrimary,
    ),
  );
}

/// 构建筛选芯片
Widget _buildFilterChip({
  required String label,
  required bool isSelected,
  required Function(bool) onSelected,
}) {
  return FilterChip(
    label: Text(label),
    selected: isSelected,
    onSelected: onSelected,
    selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
    checkmarkColor: const Color(0xFFFF4458),
    labelStyle: TextStyle(
      color: isSelected ? const Color(0xFFFF4458) : AppColors.textSecondary,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      fontSize: 13.sp,
    ),
    side: BorderSide(
      color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
    ),
  );
}
