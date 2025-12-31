import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/create_meetup_page_controller.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_datetime_section.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_images_section.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_location_section.dart';
import 'package:df_admin_mobile/pages/create_meetup/create_meetup_title_type_section.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class CreateMeetupPage extends StatelessWidget {
  final Meetup? editingMeetup;

  const CreateMeetupPage({super.key, this.editingMeetup});

  String get _controllerTag => editingMeetup != null ? 'edit_meetup_${editingMeetup!.id}' : 'create_meetup_new';

  @override
  Widget build(BuildContext context) {
    // Register controller with unique tag
    final controller = Get.put(
      CreateMeetupPageController(editingMeetup: editingMeetup),
      tag: _controllerTag,
    );

    final l10n = AppLocalizations.of(context)!;
    final isEditMode = editingMeetup != null;

    return WillPopScope(
      onWillPop: () async {
        _cleanupController();
        return true;
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
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title section
                        _buildSectionCard(
                          child: CreateMeetupTitleSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Type section
                        _buildSectionCard(
                          child: CreateMeetupTypeSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Location section
                        _buildSectionCard(
                          child: CreateMeetupLocationSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Date & Time section
                        _buildSectionCard(
                          child: CreateMeetupDateTimeSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Attendees section
                        _buildSectionCard(
                          child: CreateMeetupAttendeesSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Description section
                        _buildSectionCard(
                          child: CreateMeetupDescriptionSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 16),
                        // Images section
                        _buildSectionCard(
                          child: CreateMeetupImagesSection(controllerTag: _controllerTag),
                        ),
                        const SizedBox(height: 24),
                        // Submit button
                        _buildSubmitButton(context, l10n, controller, isEditMode),
                        const SizedBox(height: 32),
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
        icon: const Icon(FontAwesomeIcons.arrowLeft, size: 18),
        onPressed: () {
          _cleanupController();
          Get.back();
        },
      ),
      title: Text(
        isEditMode ? l10n.editMeetup : l10n.createMeetup,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderBanner(AppLocalizations l10n, bool isEditMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.calendarPlus,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            isEditMode ? l10n.editMeetup : l10n.createMeetup,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            isEditMode ? l10n.editMeetup : l10n.createMeetup,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSubmitButton(BuildContext context, AppLocalizations l10n, CreateMeetupPageController controller, bool isEditMode) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value || controller.isUploadingImages.value
            ? null
            : () => _handleSubmit(context, l10n, controller),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4458),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: controller.isSubmitting.value || controller.isUploadingImages.value
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.submitting,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.calendarPlus, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    isEditMode ? l10n.editMeetup : l10n.createMeetup,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    ));
  }

  Future<void> _handleSubmit(BuildContext context, AppLocalizations l10n, CreateMeetupPageController controller) async {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectLocation),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate date and time
    if (controller.selectedDate.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectDate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (controller.selectedTime.value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.selectTime),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create meetup
    final success = await controller.createMeetup(context);
    if (success) {
      _cleanupController();
      Get.back(result: true);
    }
  }

  void _cleanupController() {
    if (Get.isRegistered<CreateMeetupPageController>(tag: _controllerTag)) {
      Get.delete<CreateMeetupPageController>(tag: _controllerTag);
    }
  }
}
