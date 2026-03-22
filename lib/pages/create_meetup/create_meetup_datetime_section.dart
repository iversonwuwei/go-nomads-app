import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

class CreateMeetupDateTimeSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupDateTimeSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 日期标题
        Text(l10n.dateAndTime, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
        SizedBox(height: 12.h),

        // 快速日期选择 chips
        _buildQuickDateChips(context, l10n),
        SizedBox(height: 16.h),

        // 时间选择
        Text(l10n.time, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        _buildTimeGrid(context),
      ],
    );
  }

  /// 快速日期选择 — 显示最近 7 天的日期横向滚动
  Widget _buildQuickDateChips(BuildContext context, AppLocalizations l10n) {
    final now = DateTime.now();
    final dates = List.generate(14, (i) => DateTime(now.year, now.month, now.day).add(Duration(days: i)));
    final weekDays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekDaysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final isZh = Localizations.localeOf(context).languageCode == 'zh';

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length + 1, // +1 更多选项
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          if (index == dates.length) {
            // "更多" 按钮，打开系统日历选择器
            return _buildMoreDateButton(context, l10n);
          }

          final date = dates[index];
          final isToday = index == 0;
          final isTomorrow = index == 1;

          String label;
          if (isToday) {
            label = isZh ? '今天' : 'Today';
          } else if (isTomorrow) {
            label = isZh ? '明天' : 'Tmrw';
          } else {
            label = isZh ? weekDays[date.weekday - 1] : weekDaysEn[date.weekday - 1];
          }
          final dayStr = '${date.month}/${date.day}';

          return Obx(() {
            final isSelected = _c.selectedDate.value != null &&
                _c.selectedDate.value!.year == date.year &&
                _c.selectedDate.value!.month == date.month &&
                _c.selectedDate.value!.day == date.day;

            return GestureDetector(
              onTap: () => _c.selectedDate.value = date,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56.w,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF4458) : Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                              color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      dayStr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }

  /// "更多" 日期按钮
  Widget _buildMoreDateButton(BuildContext context, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () => _c.selectDate(context),
      child: Container(
        width: 56.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.calendarPlus, size: 16.r, color: Colors.black54),
            SizedBox(height: 4.h),
            Text(
              '...',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  /// 时间选择网格 — 常用时间段快速选择
  Widget _buildTimeGrid(BuildContext context) {
    // 常用聚会时间段（含半小时）
    final timeSlots = [
      TimeOfDay(hour: 9, minute: 0),
      TimeOfDay(hour: 9, minute: 30),
      TimeOfDay(hour: 10, minute: 0),
      TimeOfDay(hour: 10, minute: 30),
      TimeOfDay(hour: 11, minute: 0),
      TimeOfDay(hour: 11, minute: 30),
      TimeOfDay(hour: 12, minute: 0),
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 14, minute: 0),
      TimeOfDay(hour: 15, minute: 0),
      TimeOfDay(hour: 16, minute: 0),
      TimeOfDay(hour: 17, minute: 0),
      TimeOfDay(hour: 18, minute: 0),
      TimeOfDay(hour: 19, minute: 0),
      TimeOfDay(hour: 20, minute: 0),
      TimeOfDay(hour: 21, minute: 0),
    ];

    return Column(
      children: [
        // 时间网格
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8.h,
            crossAxisSpacing: 8.w,
            childAspectRatio: 2.2,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            return Obx(() {
              final isSelected = _c.selectedTime.value != null &&
                  _c.selectedTime.value!.hour == slot.hour &&
                  _c.selectedTime.value!.minute == slot.minute;

              return GestureDetector(
                onTap: () => _c.selectedTime.value = slot,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFFF4458) : Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFFF4458) : AppColors.borderLight,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${slot.hour.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            });
          },
        ),

        SizedBox(height: 8.h),

        // 自定义时间按钮
        Obx(() {
          final isCustom = _c.selectedTime.value != null &&
              !timeSlots.any((s) => s.hour == _c.selectedTime.value!.hour && s.minute == _c.selectedTime.value!.minute);

          return GestureDetector(
            onTap: () => _showWheelTimePicker(context),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h),
              decoration: BoxDecoration(
                color: isCustom ? const Color(0xFFFF4458).withValues(alpha: 0.08) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isCustom ? const Color(0xFFFF4458) : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FontAwesomeIcons.clock, size: 14.r, color: isCustom ? const Color(0xFFFF4458) : Colors.black54),
                  SizedBox(width: 8.w),
                  Text(
                    isCustom
                        ? '${_c.selectedTime.value!.hour.toString().padLeft(2, '0')}:${_c.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                        : '自定义时间 / Custom time',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isCustom ? FontWeight.w700 : FontWeight.w500,
                      color: isCustom ? const Color(0xFFFF4458) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 滚轮式时间选择器底部弹窗
  void _showWheelTimePicker(BuildContext context) {
    final initialTime = _c.selectedTime.value ?? TimeOfDay.now();
    final hourController = FixedExtentScrollController(initialItem: initialTime.hour);
    final minuteController = FixedExtentScrollController(initialItem: initialTime.minute ~/ 5);

    int pickedHour = initialTime.hour;
    int pickedMinute = (initialTime.minute ~/ 5) * 5;

    const brandColor = Color(0xFFFF4458);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: 320.h,
            child: Column(
              children: [
                // 顶部标题栏
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Text('取消', style: TextStyle(fontSize: 15.sp, color: Colors.black54)),
                      ),
                      Text(
                        '选择时间',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black87),
                      ),
                      GestureDetector(
                        onTap: () {
                          _c.selectedTime.value = TimeOfDay(hour: pickedHour, minute: pickedMinute);
                          Navigator.pop(ctx);
                        },
                        child: Text('确定',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: brandColor)),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Colors.grey.shade200),

                // 滚轮选择器
                Expanded(
                  child: Row(
                    children: [
                      // 小时列
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: hourController,
                          itemExtent: 44.h,
                          diameterRatio: 1.2,
                          selectionOverlay: Container(
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(color: brandColor.withValues(alpha: 0.2), width: 1),
                              ),
                            ),
                          ),
                          onSelectedItemChanged: (i) => pickedHour = i,
                          children: List.generate(24, (i) {
                            return Center(
                              child: Text(
                                i.toString().padLeft(2, '0'),
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            );
                          }),
                        ),
                      ),
                      // 分隔符
                      Text(':', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                      // 分钟列（5 分钟间隔）
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: minuteController,
                          itemExtent: 44.h,
                          diameterRatio: 1.2,
                          selectionOverlay: Container(
                            decoration: BoxDecoration(
                              border: Border.symmetric(
                                horizontal: BorderSide(color: brandColor.withValues(alpha: 0.2), width: 1),
                              ),
                            ),
                          ),
                          onSelectedItemChanged: (i) => pickedMinute = i * 5,
                          children: List.generate(12, (i) {
                            return Center(
                              child: Text(
                                (i * 5).toString().padLeft(2, '0'),
                                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CreateMeetupAttendeesSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupAttendeesSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.maxAttendees, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: Obx(() => Slider(
                    value: _c.maxAttendees.value,
                    min: 2,
                    max: 50,
                    divisions: 48,
                    activeColor: const Color(0xFFFF4458),
                    label: _c.maxAttendees.value.toInt().toString(),
                    onChanged: (value) => _c.maxAttendees.value = value,
                  )),
            ),
            SizedBox(width: 12.w),
            Obx(() => Text(
                  _c.maxAttendees.value.toInt().toString(),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Color(0xFFFF4458)),
                )),
          ],
        ),
      ],
    );
  }
}

class CreateMeetupDescriptionSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupDescriptionSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.description, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _c.descriptionController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: l10n.enterMeetupDescription,
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}
