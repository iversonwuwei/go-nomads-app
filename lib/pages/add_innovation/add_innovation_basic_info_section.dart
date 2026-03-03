import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_innovation_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddInnovationBasicInfoSection extends StatelessWidget {
  final String controllerTag;

  const AddInnovationBasicInfoSection({super.key, required this.controllerTag});

  AddInnovationPageController get _c => Get.find<AddInnovationPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(icon: FontAwesomeIcons.rocket, title: l10n.basicInformation, color: const Color(0xFF8B5CF6)),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _c.projectNameController,
          label: l10n.projectName,
          hint: l10n.projectNameHint,
          icon: FontAwesomeIcons.heading,
          validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterProjectName : null,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: _c.elevatorPitchController,
          label: l10n.elevatorPitch,
          hint: l10n.elevatorPitchHint,
          icon: FontAwesomeIcons.message,
          maxLines: 2,
          validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterElevatorPitch : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8.r)),
          child: Icon(icon, color: color, size: 20.r),
        ),
        SizedBox(width: 12.w),
        Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.grey[800])),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, size: 20.r) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
