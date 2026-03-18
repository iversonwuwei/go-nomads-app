import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_section_header.dart';

/// 社交链接部分组件
class SocialLinksWidget extends StatelessWidget {
  final Map<String, String> links;
  final bool isMobile;
  final String title;

  const SocialLinksWidget({
    super.key,
    required this.links,
    required this.isMobile,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: title,
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: links.entries
              .map((entry) => _SocialLinkButton(
                    platform: entry.key,
                    url: entry.value,
                  ))
              .toList(),
        ),
      ],
    );
  }
}

/// 社交链接按钮
class _SocialLinkButton extends StatelessWidget {
  final String platform;
  final String url;

  const _SocialLinkButton({
    required this.platform,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final (icon, color) = _getPlatformStyle(platform);

    return InkWell(
      onTap: () {
        // TODO: 实现打开链接功能
      },
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.r, color: color),
            SizedBox(width: 8.w),
            Text(
              platform.toUpperCase(),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (IconData, Color) _getPlatformStyle(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
        return (FontAwesomeIcons.rocket, const Color(0xFF1DA1F2));
      case 'github':
        return (FontAwesomeIcons.code, const Color(0xFF171515));
      case 'linkedin':
        return (FontAwesomeIcons.building, const Color(0xFF0A66C2));
      case 'website':
        return (FontAwesomeIcons.globe, const Color(0xFF6B7280));
      default:
        return (FontAwesomeIcons.link, const Color(0xFF6B7280));
    }
  }
}
