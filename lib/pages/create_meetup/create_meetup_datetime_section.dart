import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMeetupDateTimeSection extends StatelessWidget {
  final String controllerTag;

  const CreateMeetupDateTimeSection({super.key, required this.controllerTag});

  CreateMeetupPageController get _c => Get.find<CreateMeetupPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        // Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.date, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _c.selectDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.calendar, size: 18.r, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Obx(() => Text(
                        _c.selectedDate.value == null
                            ? l10n.selectDate
                            : '${_c.selectedDate.value!.year}-${_c.selectedDate.value!.month.toString().padLeft(2, '0')}-${_c.selectedDate.value!.day.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 14.sp, color: _c.selectedDate.value == null ? Colors.grey : Colors.black87),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        // Time
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.time, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
              SizedBox(height: 8.h),
              InkWell(
                onTap: () => _c.selectTime(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.borderLight), borderRadius: BorderRadius.circular(8.r)),
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.clock, size: 18.r, color: Colors.grey),
                      SizedBox(width: 8.w),
                      Obx(() => Text(
                        _c.selectedTime.value == null
                            ? l10n.selectTime
                            : '${_c.selectedTime.value!.hour.toString().padLeft(2, '0')}:${_c.selectedTime.value!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontSize: 14.sp, color: _c.selectedTime.value == null ? Colors.grey : Colors.black87),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.borderLight)),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
      ],
    );
  }
}
