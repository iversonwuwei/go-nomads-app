import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddCoworkingBasicInfoSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingBasicInfoSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
        SizedBox(height: 16.h),
        _buildTextField(controller: _c.nameController, label: l10n.spaceName, hint: l10n.spaceNameHint, required: true),
        SizedBox(height: 16.h),
        _buildTextField(controller: _c.descriptionController, label: l10n.description, hint: l10n.descriptionHint, maxLines: 4, required: true),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24.r),
        SizedBox(width: 8.w),
        Text(title, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, int maxLines = 1, bool required = false}) {
    final l10n = AppLocalizations.of(Get.context!)!;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required ? (v) => (v == null || v.isEmpty) ? l10n.thisFieldIsRequired : null : null,
    );
  }
}
