import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/add_innovation_page_controller.dart';
import 'package:go_nomads_app/features/innovation_project/infrastructure/models/innovation_project_dto.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/dialogs/app_bottom_drawer.dart';

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
                Icon(FontAwesomeIcons.userGroup, size: 20.r, color: Color(0xFF8B5CF6)),
                SizedBox(width: 8.w),
                Text(l10n.teamMembers, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                SizedBox(width: 8.w),
                Text('(${l10n.optional})', style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showAddTeamMemberDialog(context),
              icon: Icon(FontAwesomeIcons.plus, size: 14.r),
              label: Text(l10n.addTeamMember),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => _c.teamMembers.isEmpty ? _buildEmptyState(l10n) : _buildTeamMemberList(context, l10n)),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), shape: BoxShape.circle),
            child: Icon(FontAwesomeIcons.users, size: 24.r, color: Colors.grey[400]),
          ),
          SizedBox(height: 12.h),
          Text(l10n.noTeamMembersAdded, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
          SizedBox(height: 4.h),
          Text(l10n.addTeamMember, style: TextStyle(fontSize: 12.sp, color: Colors.grey[400])),
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
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [BoxShadow(color: Colors.grey.withAlpha(25), blurRadius: 4.r, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withAlpha(25), borderRadius: BorderRadius.circular(24.r)),
            child: Center(child: Text(member.name.isNotEmpty ? member.name[0].toUpperCase() : '?', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)))),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                if (member.role.isNotEmpty) Text(member.role, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(FontAwesomeIcons.penToSquare, size: 16.r, color: Theme.of(context).primaryColor),
                onPressed: () => _showEditTeamMemberDialog(context, member),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.trash, size: 16.r, color: Colors.red[400]),
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

    AppBottomDrawer.show<void>(
      context,
      title: l10n.addTeamMember,
      maxHeightFactor: 0.56,
      child: Column(
        children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.enterMemberName,
                  prefixIcon: Icon(FontAwesomeIcons.user, size: 16.r),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: l10n.role,
                  hintText: l10n.enterMemberRole,
                  prefixIcon: Icon(FontAwesomeIcons.briefcase, size: 16.r),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
        ],
      ),
      footer: AppBottomDrawerActionRow(
        secondaryLabel: l10n.cancel,
        onSecondaryPressed: () => Get.back<void>(),
        primaryLabel: l10n.add,
        onPrimaryPressed: () {
          if (nameController.text.isNotEmpty) {
            _c.addTeamMember(TeamMemberDto(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: nameController.text.trim(),
                role: roleController.text.trim()));
            Get.back<void>();
          }
        },
      ),
    );
  }

  void _showEditTeamMemberDialog(BuildContext context, TeamMemberDto member) {
    final nameController = TextEditingController(text: member.name);
    final roleController = TextEditingController(text: member.role);
    final l10n = AppLocalizations.of(context)!;

    AppBottomDrawer.show<void>(
      context,
      title: l10n.editTeamMember,
      maxHeightFactor: 0.56,
      child: Column(
        children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  prefixIcon: Icon(FontAwesomeIcons.user, size: 16.r),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: roleController,
                decoration: InputDecoration(
                  labelText: l10n.role,
                  prefixIcon: Icon(FontAwesomeIcons.briefcase, size: 16.r),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
        ],
      ),
      footer: AppBottomDrawerActionRow(
        secondaryLabel: l10n.cancel,
        onSecondaryPressed: () => Get.back<void>(),
        primaryLabel: l10n.save,
        onPrimaryPressed: () {
          if (nameController.text.isNotEmpty) {
            _c.updateTeamMember(member,
                TeamMemberDto(id: member.id, name: nameController.text.trim(), role: roleController.text.trim()));
            Get.back<void>();
          }
        },
      ),
    );
  }
}
