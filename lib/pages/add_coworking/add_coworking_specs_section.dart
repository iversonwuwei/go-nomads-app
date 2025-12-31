import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_coworking_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddCoworkingSpecsSection extends StatelessWidget {
  final String controllerTag;

  const AddCoworkingSpecsSection({super.key, required this.controllerTag});

  AddCoworkingPageController get _c => Get.find<AddCoworkingPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.specifications, FontAwesomeIcons.listCheck),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.wifiSpeedController, label: l10n.wifiSpeed, hint: l10n.wifiSpeedHint, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.capacityController, label: l10n.capacity, hint: l10n.capacityHint, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildTextField(controller: _c.numberOfDesksController, label: l10n.numberOfDesks, hint: l10n.numberOfDesksHint, keyboardType: TextInputType.number),
        const SizedBox(height: 16),
        _buildNoiseLevelDropdown(context, l10n),
        const SizedBox(height: 16),
        _buildSpaceTypeDropdown(context, l10n),
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

  Widget _buildNoiseLevelDropdown(BuildContext context, AppLocalizations l10n) {
    return Obx(() => DropdownButtonFormField<String>(
          value: _c.noiseLevel.value,
          decoration: InputDecoration(
            labelText: l10n.noiseLevel,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: [
            DropdownMenuItem(value: 'quiet', child: Text(l10n.noiseLevelQuiet)),
            DropdownMenuItem(value: 'moderate', child: Text(l10n.noiseLevelModerate)),
            DropdownMenuItem(value: 'loud', child: Text(l10n.noiseLevelLoud)),
          ],
          onChanged: (value) => _c.noiseLevel.value = value,
        ));
  }

  Widget _buildSpaceTypeDropdown(BuildContext context, AppLocalizations l10n) {
    return Obx(() => DropdownButtonFormField<String>(
          value: _c.spaceType.value,
          decoration: InputDecoration(
            labelText: l10n.spaceType,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          items: [
            DropdownMenuItem(value: 'open', child: Text(l10n.spaceTypeOpen)),
            DropdownMenuItem(value: 'private', child: Text(l10n.spaceTypePrivate)),
            DropdownMenuItem(value: 'mixed', child: Text(l10n.spaceTypeMixed)),
          ],
          onChanged: (value) => _c.spaceType.value = value,
        ));
  }
}
