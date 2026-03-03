import 'package:go_nomads_app/features/innovation_project/domain/entities/innovation_project.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Innovation Detail Team Section
/// 创意项目详情页 - 团队成员区块
class InnovationDetailTeamSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<TeamMember> team;
  final Color color;

  const InnovationDetailTeamSection({
    super.key,
    required this.icon,
    required this.title,
    required this.team,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, size: 20.r, color: color),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (team.isEmpty)
          _buildEmptyTeam(context)
        else
          ...team.map((member) => _buildTeamMember(member)),
      ],
    );
  }

  Widget _buildEmptyTeam(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.userGroup, size: 40.r, color: Colors.grey[300]),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.noTeamMembersAdded,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(TeamMember member) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color,
            child: Text(
              member.name.isNotEmpty ? member.name.substring(0, 1) : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${member.name} - ${member.role}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  member.description,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Color(0xFF4a5568),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
