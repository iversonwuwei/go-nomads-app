import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';

class AppSectionSurface extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const AppSectionSurface({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      padding: padding ?? EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CockpitSectionHeader(
            title: title,
            subtitle: subtitle,
            trailing: trailing,
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
