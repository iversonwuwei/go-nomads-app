import 'package:flutter/material.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

/// 社区亮点展示
class RegisterFeatureHighlights extends StatelessWidget {
  const RegisterFeatureHighlights({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.joinMembers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureItem(
            emoji: '🍹',
            title: l10n.attendMeetups,
            subtitle: l10n.inCitiesWorldwide,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            emoji: '❤️',
            title: l10n.meetNewPeople,
            subtitle: l10n.forDatingAndFriends,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            emoji: '🧪',
            title: l10n.researchDestinations,
            subtitle: l10n.findBestPlace,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            emoji: '💬',
            title: l10n.joinExclusiveChat,
            subtitle: l10n.messagesSentThisMonth,
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            emoji: '🗺️',
            title: l10n.trackTravels,
            subtitle: l10n.shareJourney,
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
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
