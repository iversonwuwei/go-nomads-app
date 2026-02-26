import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/create_meetup_page_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_datetime_section.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_images_section.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_location_section.dart';
import 'package:go_nomads_app/pages/create_meetup/create_meetup_title_type_section.dart';
import 'package:go_nomads_app/utils/navigation_util.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMeetupPage extends StatelessWidget {
  final Meetup? editingMeetup;

  const CreateMeetupPage({super.key, this.editingMeetup});

  String get _controllerTag => editingMeetup != null ? 'edit_meetup_${editingMeetup!.id}' : 'create_meetup_new';

  CreateMeetupPageController get _controller {
    if (!Get.isRegistered<CreateMeetupPageController>(tag: _controllerTag)) {
      return Get.put(
        CreateMeetupPageController(editingMeetup: editingMeetup),
        tag: _controllerTag,
      );
    }
    return Get.find<CreateMeetupPageController>(tag: _controllerTag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final l10n = AppLocalizations.of(context)!;
    final isEditMode = editingMeetup != null;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 页面退出后延迟清理 controller
          Future.delayed(const Duration(milliseconds: 500), () {
            if (Get.isRegistered<CreateMeetupPageController>(tag: _controllerTag)) {
              Get.delete<CreateMeetupPageController>(tag: _controllerTag);
            }
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(context, l10n, isEditMode),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Form(
            key: controller.formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header banner
                  _buildHeaderBanner(l10n, isEditMode),
                  // Main form content
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section
                        _buildSectionCard(
                          child: CreateMeetupTitleSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Type section
                        _buildSectionCard(
                          child: CreateMeetupTypeSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Location section
                        _buildSectionCard(
                          child: CreateMeetupLocationSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Date & Time section
                        _buildSectionCard(
                          child: CreateMeetupDateTimeSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Attendees section
                        _buildSectionCard(
                          child: CreateMeetupAttendeesSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Description section
                        _buildSectionCard(
                          child: CreateMeetupDescriptionSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 16.h),
                        // Images section
                        _buildSectionCard(
                          child: CreateMeetupImagesSection(controllerTag: _controllerTag),
                        ),
                        SizedBox(height: 24.h),
                        // Submit button
                        _buildSubmitButton(context, l10n, controller, isEditMode),
                        SizedBox(height: 32.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n, bool isEditMode) {
    return AppBar(
      backgroundColor: const Color(0xFFFF4458),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.arrowLeft, size: 18.r),
        onPressed: () => Get.back(),
      ),
      title: Text(
        isEditMode ? l10n.editMeetup : l10n.createMeetup,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderBanner(AppLocalizations l10n, bool isEditMode) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.calendarPlus,
              color: Colors.white,
              size: 28.r,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isEditMode ? l10n.editMeetup : l10n.createMeetup,
            style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 4.h),
          Text(
            isEditMode ? l10n.editMeetup : l10n.createMeetup,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton(
      BuildContext context, AppLocalizations l10n, CreateMeetupPageController controller, bool isEditMode) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value || controller.isUploadingImages.value
                ? null
                : () => _handleSubmit(context, l10n, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: controller.isSubmitting.value || controller.isUploadingImages.value
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        l10n.submitting,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.calendarPlus, size: 18.r),
                      SizedBox(width: 10.w),
                      Text(
                        isEditMode ? l10n.editMeetup : l10n.createMeetup,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ));
  }

  Future<void> _handleSubmit(BuildContext context, AppLocalizations l10n, CreateMeetupPageController controller) async {
    // 防止重复提交 - 在任何操作之前立即检查
    if (controller.isSubmitting.value || controller.isUploadingImages.value) {
      return;
    }

    // Validate venue
    if (controller.venueController.text.trim().isEmpty) {
      controller.venueErrorText.value = l10n.pleaseEnterVenue;
      return;
    }

    // Validate form
    if (!controller.formKey.currentState!.validate()) {
      return;
    }

    // Validate location
    if (controller.selectedCity.value == null || controller.selectedCountry.value == null) {
      AppToast.error(l10n.selectLocation);
      return;
    }

    // Validate date and time
    if (controller.selectedDate.value == null) {
      AppToast.error(l10n.selectDate);
      return;
    }

    if (controller.selectedTime.value == null) {
      AppToast.error(l10n.selectTime);
      return;
    }

    // Create meetup
    final success = await controller.createMeetup(context);
    if (success && context.mounted) {
      // 使用统一的返回方法，让列表页面刷新数据
      await NavigationUtil.backWithRefresh<bool>(context: context);
    }
  }
}
