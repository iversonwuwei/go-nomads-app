import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_section_header.dart';
import 'package:go_nomads_app/widgets/surfaces/app_card_surface.dart';

/// 徽章部分组件
class BadgesSectionWidget extends StatelessWidget {
  final List<Badge> badges;
  final bool isMobile;

  const BadgesSectionWidget({
    super.key,
    required this.badges,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (badges.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n.badges,
          trailing: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Text(
              '${badges.length}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.cityPrimary,
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.w,
          children: badges.map((badge) => _BadgeCard(badge: badge)).toList(),
        ),
      ],
    );
  }
}

/// 单个徽章卡片
class _BadgeCard extends StatelessWidget {
  final Badge badge;

  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    final isCompact = MediaQuery.of(context).size.width < 768;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: isCompact ? double.infinity : 156.w,
        maxWidth: isCompact ? double.infinity : 240.w,
      ),
      child: AppCardSurface(
        padding: EdgeInsets.all(14.w),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.82),
            const Color(0xFFFFF1F3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFFFD4DA)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4458).withValues(alpha: 0.12),
            blurRadius: 16.r,
            offset: const Offset(0, 8),
          ),
        ],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Text(badge.icon, style: TextStyle(fontSize: 20.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2B1A1D),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    badge.description,
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.35,
                      color: const Color(0xFF7A5B61),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
