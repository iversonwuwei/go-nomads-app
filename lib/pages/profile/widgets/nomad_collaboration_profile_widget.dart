import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/surfaces/app_section_surface.dart';
import 'package:go_nomads_app/widgets/surfaces/app_state_surface.dart';

class NomadCollaborationProfileWidget extends GetView<ProfileController> {
  const NomadCollaborationProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Obx(() {
      final profile = controller.collaborationProfile;
      if (profile == null) {
        return const SizedBox.shrink();
      }

      final summaryItems = <_InfoCardData>[
        _InfoCardData(
          icon: Icons.badge_outlined,
          label: l10n.profileCollaborationProfessionalIdentity,
          value: profile.professionalIdentity,
        ),
        _InfoCardData(
          icon: Icons.translate_rounded,
          label: l10n.profileCollaborationLanguageAbility,
          value: profile.languageAbility,
        ),
        _InfoCardData(
          icon: Icons.handshake_outlined,
          label: l10n.profileCollaborationMode,
          value: profile.collaborationMode,
        ),
        _InfoCardData(
          icon: Icons.radar_rounded,
          label: l10n.profileCollaborationDiscovery,
          value: profile.discoveryReadiness,
        ),
      ];

      return AppSectionSurface(
        title: l10n.profileCollaborationTitle,
        subtitle: isMobile ? null : l10n.profileCollaborationSubtitle,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final columns = isMobile ? 2 : 2;
                final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: summaryItems
                      .map(
                        (item) => SizedBox(
                          width: cardWidth,
                          child: _InfoCard(
                            item: item,
                            isCompact: isMobile,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: 16),
            _TagGroup(
              icon: Icons.psychology_alt_outlined,
              title: l10n.profileCollaborationTopSkills,
              tags: profile.skillTags,
              emptyLabel: l10n.profileCollaborationNoSkills,
              accentColor: AppColors.cityPrimary,
            ),
            const SizedBox(height: 16),
            _TagGroup(
              icon: Icons.interests_outlined,
              title: l10n.profileCollaborationTopInterests,
              tags: profile.interestTags,
              emptyLabel: l10n.profileCollaborationNoInterests,
              accentColor: const Color(0xFF457B9D),
            ),
            const SizedBox(height: 16),
            _TagGroup(
              icon: Icons.alternate_email_rounded,
              title: l10n.profileCollaborationSocialPresence,
              tags: profile.socialTags,
              emptyLabel: l10n.profileCollaborationNoLinks,
              accentColor: const Color(0xFF2A9D8F),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () => Get.toNamed(AppRoutes.editSkills),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.profileCollaborationEditSkills),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.editInterests),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.profileCollaborationEditInterests),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed(AppRoutes.editSocialLinks),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(l10n.profileCollaborationEditLinks),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _InfoCardData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCardData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoCardData item;
  final bool isCompact;

  const _InfoCard({
    required this.item,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.66),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.74)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isCompact ? 36 : 40,
            height: isCompact ? 36 : 40,
            decoration: BoxDecoration(
              color: AppColors.cityPrimaryLight.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              size: isCompact ? 18 : 20,
              color: AppColors.cityPrimary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.value,
                  maxLines: isCompact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
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

class _TagGroup extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> tags;
  final String emptyLabel;
  final Color accentColor;

  const _TagGroup({
    required this.icon,
    required this.title,
    required this.tags,
    required this.emptyLabel,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 18, color: accentColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tags.length.toString(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tags.isEmpty)
            AppStateSurface.message(
              message: emptyLabel,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                      ),
                      child: Text(
                        tag,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}
