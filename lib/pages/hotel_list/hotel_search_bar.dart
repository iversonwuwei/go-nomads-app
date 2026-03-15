import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/hotel_list_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 搜索栏组件
class HotelSearchBar extends StatelessWidget {
  final String controllerTag;

  const HotelSearchBar({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HotelListPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: l10n.search,
                    prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                    suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(FontAwesomeIcons.xmark),
                            onPressed: controller.clearSearch,
                          )
                        : const SizedBox()),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: controller.updateSearchQuery,
                ),
              ),
              SizedBox(width: 12.w),
              IconButton(
                icon: const Icon(FontAwesomeIcons.sliders, color: Colors.black54),
                onPressed: () => _showSearchFilterSheet(context, controller),
                tooltip: 'Hotel Filters',
              ),
              IconButton(
                icon: const Icon(FontAwesomeIcons.circlePlus, color: Colors.black54),
                onPressed: controller.navigateToAddHotel,
                tooltip: 'Add Hotel',
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _InfoChip(
                    icon: FontAwesomeIcons.calendarDays,
                    label: controller.checkInLabel,
                  ),
                  _InfoChip(
                    icon: FontAwesomeIcons.moon,
                    label: '${controller.stayNights.value} nights',
                  ),
                  _InfoChip(
                    icon: FontAwesomeIcons.userGroup,
                    label: controller.occupancyLabel,
                  ),
                ],
              );
            }),
          ),
          Obx(() {
            if (!controller.shouldShowExternalStatusBanner) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: _ExternalStatusBanner(
                message: controller.externalStatusBannerText,
                isWarning: controller.externalDataStatus.value == 'unavailable' || controller.partialExternalData.value,
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _showSearchFilterSheet(
    BuildContext context,
    HotelListPageController controller,
  ) async {
    final selectedDate = controller.checkInDate.value ?? DateTime.now().add(const Duration(days: 7));

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hotel Search',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(FontAwesomeIcons.calendarDays),
                  title: const Text('Check-in Date'),
                  subtitle: Obx(() => Text(controller.checkInLabel)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      await controller.updateCheckInDate(picked);
                    }
                  },
                ),
                SizedBox(height: 12.h),
                Obx(() => _StepperRow(
                      icon: FontAwesomeIcons.moon,
                      title: 'Stay Nights',
                      value: controller.stayNights.value,
                      minValue: 1,
                      maxValue: 30,
                      onChanged: controller.updateStayNights,
                    )),
                SizedBox(height: 12.h),
                Obx(() => _StepperRow(
                      icon: FontAwesomeIcons.userGroup,
                      title: 'Adults',
                      value: controller.adultCount.value,
                      minValue: 1,
                      maxValue: 8,
                      onChanged: controller.updateAdultCount,
                    )),
                SizedBox(height: 12.h),
                Obx(() => _StepperRow(
                      icon: FontAwesomeIcons.bed,
                      title: 'Rooms',
                      value: controller.roomCount.value,
                      minValue: 1,
                      maxValue: 4,
                      onChanged: controller.updateRoomCount,
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExternalStatusBanner extends StatelessWidget {
  final String message;
  final bool isWarning;

  const _ExternalStatusBanner({required this.message, required this.isWarning});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isWarning ? const Color(0xFFFFF7ED) : const Color(0xFFF4F8FF);
    final borderColor = isWarning ? const Color(0xFFFED7AA) : const Color(0xFFD6E8FF);
    final foregroundColor = isWarning ? const Color(0xFFB45309) : const Color(0xFF0A66C2);
    final icon = isWarning ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.circleInfo;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h),
            child: FaIcon(icon, size: 13.sp, color: foregroundColor),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: foregroundColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.grey[700]),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final int minValue;
  final int maxValue;
  final Future<void> Function(int) onChanged;

  const _StepperRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.sp),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
          ),
        ),
        IconButton(
          onPressed: value > minValue ? () => onChanged(value - 1) : null,
          icon: const Icon(FontAwesomeIcons.minus),
        ),
        Text(
          '$value',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
        IconButton(
          onPressed: value < maxValue ? () => onChanged(value + 1) : null,
          icon: const Icon(FontAwesomeIcons.plus),
        ),
      ],
    );
  }
}
