import 'package:flutter/material.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/app_config_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 社区亮点展示
class RegisterFeatureHighlights extends StatelessWidget {
  final PreAuthMarketingCopy? copy;

  const RegisterFeatureHighlights({super.key, this.copy});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            copy?.registerHighlightsTitle ?? l10n.joinMembers,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          _FeatureItem(
            emoji: '🍹',
            title: copy?.registerHighlightsMeetupsTitle ?? l10n.attendMeetups,
            subtitle: copy?.registerHighlightsMeetupsSubtitle ?? l10n.inCitiesWorldwide,
          ),
          SizedBox(height: 12.h),
          _FeatureItem(
            emoji: '❤️',
            title: copy?.registerHighlightsPeopleTitle ?? l10n.meetNewPeople,
            subtitle: copy?.registerHighlightsPeopleSubtitle ?? l10n.forDatingAndFriends,
          ),
          SizedBox(height: 12.h),
          _FeatureItem(
            emoji: '🧪',
            title: copy?.registerHighlightsDestinationsTitle ?? l10n.researchDestinations,
            subtitle: copy?.registerHighlightsDestinationsSubtitle ?? l10n.findBestPlace,
          ),
          SizedBox(height: 12.h),
          _FeatureItem(
            emoji: '💬',
            title: copy?.registerHighlightsChatTitle ?? l10n.joinExclusiveChat,
            subtitle: copy?.registerHighlightsChatSubtitle ?? l10n.messagesSentThisMonth,
          ),
          SizedBox(height: 12.h),
          _FeatureItem(
            emoji: '🗺️',
            title: copy?.registerHighlightsTravelsTitle ?? l10n.trackTravels,
            subtitle: copy?.registerHighlightsTravelsSubtitle ?? l10n.shareJourney,
          ),
        ],
      ),
    );
  }
}

/// 功能项
class _FeatureItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: TextStyle(fontSize: 24.sp)),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
