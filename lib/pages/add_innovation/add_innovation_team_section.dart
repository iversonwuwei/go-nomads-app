import 'package:df_admin_mobile/features/innovation_project/infrastructure/models/innovation_project_dto.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/add_innovation_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddInnovationTeamSection extends StatelessWidget {
  final String controllerTag;

  const AddInnovationTeamSection({super.key, required this.controllerTag});

  AddInnovationPageController get _c => Get.find<AddInnovationPageController>(tag: controllerTag);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(FontAwesomeIcons.userGroup, size: 20, color: Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text(l10n.teamMembers, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(width: 8),
                Text('(${l10n.optional})', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddTeamMemberDialog(context),
              icon: const Icon(FontAwesomeIcons.plus, size: 14),
              label: Text(l10n.addTeamMember),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => _c.teamMembers.isEmpty ? _buildEmptyState(l10n) : _buildTeamMemberList(context, l10n)),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), shape: BoxShape.circle),
            child: Icon(FontAwesomeIcons.users, size: 24, color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Text(l10n.noTeamMembersAdded, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(l10n.addTeamMember, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildTeamMemberList(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: _c.teamMembers.map((member) => _buildTeamMemberCard(context, member, l10n)).toList(),
    );
  }

  Widget _buildTeamMemberCard(BuildContext context, TeamMemberDto member, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), borderRadius: BorderRadius.circular(24)),
            child: Center(child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                if (member.role.isNotEmpty) Text(member.role, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(FontAwesomeIcons.penToSquare, size: 16, color: Theme.of(context).primaryColor),
                onPressed: () => _showEditTeamMemberDialog(context, member),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.trash, size: 16, color: Colors.red[400]),
                onPressed: () => _c.removeTeamMember(member),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddTeamMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), borderRadius: BorderRadius.circular(8)),
              child: const Icon(FontAwesomeIcons.userPlus, size: 18, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: 12),
            Text(l10n.addTeamMember),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.enterMemberName,
                  prefixIcon: const Icon(FontAwesomeIcons.user, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: l10n.role,
                  hintText: l10n.enterMemberRole,
                  prefixIcon: const Icon(FontAwesomeIcons.briefcase, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _c.addTeamMember(TeamMemberDto(id: DateTime.now().millisecondsSinceEpoch.toString(), name: nameController.text.trim(), role: roleController.text.trim()));
                Get.back();
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _showEditTeamMemberDialog(BuildContext context, TeamMemberDto member) {
    final nameController = TextEditingController(text: member.name);
    final roleController = TextEditingController(text: member.role);
    final l10n = AppLocalizations.of(context)!;

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), borderRadius: BorderRadius.circular(8)),
              child: const Icon(FontAwesomeIcons.penToSquare, size: 18, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(width: 12),
            Text(l10n.editTeamMember),
          ],
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: const Icon(FontAwesomeIcons.user, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: l10n.role,
                  prefixIcon: const Icon(FontAwesomeIcons.briefcase, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _c.updateTeamMember(member, TeamMemberDto(id: member.id, name: nameController.text.trim(), role: roleController.text.trim()));
                Get.back();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }
}
