import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 技能与兴趣部分组件
class SkillsInterestsWidget extends StatelessWidget {
  final User user;
  final bool isMobile;

  const SkillsInterestsWidget({
    super.key,
    required this.user,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Skills Section
        Text(
          l10n.skills,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 12),
        user.skills.isEmpty
            ? _EmptyStateCard(
                icon: FontAwesomeIcons.lightbulb,
                message: 'No skills added yet',
                isMobile: isMobile,
              )
            : _SkillsWrap(skills: user.skills),
        const SizedBox(height: 24),

        // Interests Section
        Text(
          l10n.interests,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a1a),
          ),
        ),
        const SizedBox(height: 12),
        user.interests.isEmpty
            ? _EmptyStateCard(
                icon: FontAwesomeIcons.heart,
                message: 'No interests added yet',
                isMobile: isMobile,
              )
            : _InterestsWrap(interests: user.interests),
      ],
    );
  }
}

/// 空状态卡片
class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool isMobile;

  const _EmptyStateCard({
    required this.icon,
    required this.message,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 20 : 40,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isMobile ? 48 : 64,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 技能标签列表
class _SkillsWrap extends StatelessWidget {
  final List<dynamic> skills;

  const _SkillsWrap({required this.skills});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4458).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFFF4458).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (skill?.hasIcon == true) ...[
                Text(
                  skill.icon ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                skill?.name ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF4458),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// 兴趣标签列表
class _InterestsWrap extends StatelessWidget {
  final List<dynamic> interests;

  const _InterestsWrap({required this.interests});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: interests.map((interest) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (interest?.hasIcon == true) ...[
                Text(
                  interest.icon ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                interest?.name ?? '',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
