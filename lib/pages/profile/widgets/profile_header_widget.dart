import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:intl/intl.dart';

/// 个人资料头部组件
class ProfileHeaderWidget extends StatelessWidget {
  final User user;
  final bool isMobile;

  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locationLabel =
        user.currentCity != null && user.currentCountry != null ? '${user.currentCity}, ${user.currentCountry}' : null;
    final joinedLabel = _formatJoinDate(context, user.joinedDate);
    final bio = user.bio?.trim();

    if (isMobile) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.7),
              Colors.white.withValues(alpha: 0.52),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.profileEdit),
                  child: _IdentityAvatar(user: user, isMobile: true),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                height: 1.1,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isVerified)
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.cityPrimaryLight.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                FontAwesomeIcons.circleCheck,
                                color: AppColors.cityPrimary,
                                size: 16.r,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: [
                          _MetaPill(
                            icon: FontAwesomeIcons.at,
                            label: user.username,
                            background: Colors.white.withValues(alpha: 0.62),
                            foreground: AppColors.textSecondary,
                            iconColor: AppColors.textSecondary,
                          ),
                          if (locationLabel != null)
                            _MetaPill(
                              icon: FontAwesomeIcons.locationDot,
                              label: locationLabel,
                              background: AppColors.cityPrimaryLight.withValues(alpha: 0.65),
                              foreground: AppColors.textPrimary,
                              iconColor: AppColors.cityPrimary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _MetaPill(
                  icon: FontAwesomeIcons.calendar,
                  label: joinedLabel,
                  background: Colors.white.withValues(alpha: 0.55),
                  foreground: AppColors.textSecondary,
                  iconColor: AppColors.textSecondary,
                ),
                _MetaPill(
                  icon: user.isVerified ? FontAwesomeIcons.shield : FontAwesomeIcons.pen,
                  label: l10n.editProfile,
                  background: Colors.white.withValues(alpha: 0.55),
                  foreground: AppColors.textSecondary,
                  iconColor: AppColors.textSecondary,
                ),
              ],
            ),
            if (bio != null && bio.isNotEmpty) ...[
              SizedBox(height: 12.h),
              _BioCard(bio: bio, isMobile: true),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.72),
            Colors.white.withValues(alpha: 0.54),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.profileEdit),
            child: _IdentityAvatar(user: user, isMobile: false),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: TextStyle(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          height: 1.05,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.isVerified)
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.cityPrimaryLight.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FontAwesomeIcons.circleCheck,
                          color: AppColors.cityPrimary,
                          size: 17.r,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _MetaPill(
                      icon: FontAwesomeIcons.at,
                      label: user.username,
                      background: Colors.white.withValues(alpha: 0.62),
                      foreground: AppColors.textSecondary,
                      iconColor: AppColors.textSecondary,
                    ),
                    if (locationLabel != null)
                      _MetaPill(
                        icon: FontAwesomeIcons.locationDot,
                        label: locationLabel,
                        background: AppColors.cityPrimaryLight.withValues(alpha: 0.65),
                        foreground: AppColors.textPrimary,
                        iconColor: AppColors.cityPrimary,
                      ),
                    _MetaPill(
                      icon: FontAwesomeIcons.calendar,
                      label: joinedLabel,
                      background: Colors.white.withValues(alpha: 0.55),
                      foreground: AppColors.textSecondary,
                      iconColor: AppColors.textSecondary,
                    ),
                  ],
                ),
                if (bio != null && bio.isNotEmpty) ...[
                  SizedBox(height: 14.h),
                  _BioCard(bio: bio, isMobile: false),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatJoinDate(BuildContext context, DateTime date) {
    return DateFormat.yMMM(Localizations.localeOf(context).toLanguageTag()).format(date);
  }
}

class _IdentityAvatar extends StatelessWidget {
  final User user;
  final bool isMobile;

  const _IdentityAvatar({
    required this.user,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 80.0 : 112.0;
    final badgeSize = isMobile ? 24.0 : 30.0;

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.72),
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cityPrimary.withValues(alpha: 0.16),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: _ProfileAvatarImage(user: user),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: badgeSize,
            height: badgeSize,
            decoration: BoxDecoration(
              color: AppColors.cityPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              user.isVerified ? FontAwesomeIcons.check : FontAwesomeIcons.pen,
              color: Colors.white,
              size: isMobile ? 12 : 13,
            ),
          ),
        ),
      ],
    );
  }
}

class _BioCard extends StatelessWidget {
  final String bio;
  final bool isMobile;

  const _BioCard({
    required this.bio,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.short_text_rounded,
              size: 18,
              color: AppColors.cityPrimary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              bio,
              maxLines: isMobile ? 3 : 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: isMobile ? 13.sp : 14.sp,
                color: AppColors.textSecondary,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatarImage extends StatelessWidget {
  final User user;

  const _ProfileAvatarImage({required this.user});

  @override
  Widget build(BuildContext context) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.isNotEmpty;

    if (hasAvatar) {
      return Image.network(
        user.avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _ProfileInitialsAvatar(user: user);
        },
      );
    }

    return _ProfileInitialsAvatar(user: user);
  }
}

class _ProfileInitialsAvatar extends StatelessWidget {
  final User user;

  const _ProfileInitialsAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    String initials = '';
    if (user.name.isNotEmpty) {
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        initials = nameParts[0][0].toUpperCase() + nameParts[1][0].toUpperCase();
      } else {
        initials = user.name.substring(0, user.name.length >= 2 ? 2 : 1).toUpperCase();
      }
    } else {
      initials = '?';
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4458), Color(0xFFFF7A8A)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: 42.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.sp,
          ),
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
  final Color iconColor;

  const _MetaPill({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.sp,
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
