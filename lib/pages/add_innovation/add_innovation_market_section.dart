import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_innovation_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddInnovationMarketSection extends StatelessWidget {
  final String controllerTag;

  const AddInnovationMarketSection({super.key, required this.controllerTag});

  AddInnovationPageController get _c => Get.find<AddInnovationPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(icon: FontAwesomeIcons.users, title: l10n.marketPositioning, color: const Color(0xFF3B82F6)),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _c.targetAudienceController,
          label: l10n.targetAudience,
          hint: l10n.targetAudienceHint,
          icon: FontAwesomeIcons.users,
          maxLines: 3,
          validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseDescribeTargetAudience : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _c.productTypeController,
          label: l10n.productType,
          hint: l10n.productTypeHint,
          icon: FontAwesomeIcons.laptop,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _c.keyFeaturesController,
          label: l10n.keyFeatures,
          hint: l10n.keyFeaturesHint,
          icon: FontAwesomeIcons.star,
          maxLines: 4,
          validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterKeyFeatures : null,
        ),
      ],
    );
  }

  Widget _buildSectionTitle({required IconData icon, required String title, required Color color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
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
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444))),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }
}
