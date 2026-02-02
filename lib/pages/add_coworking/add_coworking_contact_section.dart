import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/controllers/add_coworking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddCoworkingContactSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingContactSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.contactInformation, FontAwesomeIcons.addressBook),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.phoneController, label: l10n.phone, hint: l10n.phoneHint, keyboardType: TextInputType.phone),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.emailController, label: l10n.email, hint: l10n.emailHint, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.websiteController, label: l10n.website, hint: l10n.websiteHint, keyboardType: TextInputType.url),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, String? hint, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
