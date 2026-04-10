import 'package:flutter/material.dart';
import 'package:go_nomads_app/widgets/surfaces/app_subsection_header.dart';

class ProfileSectionHeader extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;

  const ProfileSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSubsectionHeader(
      title: title,
      icon: icon,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
