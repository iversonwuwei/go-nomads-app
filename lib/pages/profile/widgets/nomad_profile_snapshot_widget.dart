import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/profile_controller.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_section_header.dart';

class NomadProfileSnapshotWidget extends GetView<ProfileController> {
  const NomadProfileSnapshotWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Obx(() {
      final snapshot = controller.nomadProfileSnapshot;
      if (snapshot == null) {
        return const SizedBox.shrink();
      }

      final items = <_SnapshotItemData>[
        _SnapshotItemData(
          icon: Icons.explore_rounded,
          label: l10n.profileSnapshotNextDestination,
          value: snapshot.nextDestination,
        ),
        _SnapshotItemData(
          icon: Icons.payments_outlined,
          label: l10n.profileSnapshotBudgetLane,
          value: snapshot.budgetLane,
        ),
        _SnapshotItemData(
          icon: Icons.schedule_rounded,
          label: l10n.profileSnapshotWorkTimezone,
          value: snapshot.workTimezone,
        ),
        _SnapshotItemData(
          icon: Icons.hotel_rounded,
          label: l10n.profileSnapshotStayRhythm,
          value: snapshot.stayRhythm,
        ),
        _SnapshotItemData(
          icon: Icons.groups_rounded,
          label: l10n.profileSnapshotCommunity,
          value: snapshot.communityMomentum,
        ),
        _SnapshotItemData(
          icon: Icons.home_work_rounded,
          label: l10n.profileSnapshotBase,
          value: snapshot.baseLocation,
        ),
        _SnapshotItemData(
          icon: Icons.alt_route_rounded,
          label: l10n.profileSnapshotMigration,
          value: snapshot.migrationStatus,
        ),
        _SnapshotItemData(
          icon: Icons.task_alt_rounded,
          label: l10n.profileSnapshotReadiness,
          value: snapshot.profileReadiness,
        ),
      ];

      return CockpitPanel(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CockpitSectionHeader(
              title: l10n.profileSnapshotTitle,
              subtitle: isMobile ? '' : l10n.profileSnapshotSubtitle,
            ),
            if ((snapshot.departureDateLabel ?? '').isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cityPrimaryLight.withValues(alpha: 0.56),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flight_takeoff_rounded,
                      size: 14,
                      color: AppColors.cityPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isMobile
                          ? snapshot.departureDateLabel!
                          : '${l10n.profileSnapshotDeparture}: ${snapshot.departureDateLabel}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.cityPrimaryDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 10.0;
                final columns = isMobile ? 2 : (constraints.maxWidth > 920 ? 4 : 3);
                final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: items
                      .map(
                        (item) => SizedBox(
                          width: cardWidth,
                          child: _SnapshotStatCard(
                            item: item,
                            isCompact: isMobile,
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.tonal(
                  onPressed: () => Get.toNamed(snapshot.focusRouteName),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cityPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(snapshot.focusRouteLabel),
                ),
                OutlinedButton(
                  onPressed: () => Get.toNamed(snapshot.secondaryRouteName),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(snapshot.secondaryRouteLabel),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SnapshotItemData {
  final IconData icon;
  final String label;
  final String value;

  const _SnapshotItemData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _SnapshotStatCard extends StatelessWidget {
  final _SnapshotItemData item;
  final bool isCompact;

  const _SnapshotStatCard({
    required this.item,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.64),
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
              color: AppColors.cityPrimaryLight.withValues(alpha: 0.36),
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
