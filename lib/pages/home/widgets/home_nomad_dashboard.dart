import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';

class HomeNomadDashboard extends GetView<HomePageController> {
  final bool isMobile;

  const HomeNomadDashboard({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      final isAuthenticated = controller.authController.isAuthenticated.value;
      if (!isAuthenticated) {
        return _PromptCard(l10n: l10n);
      }

      final cards = <_UtilityCardData>[
        _UtilityCardData(
          title: l10n.homeDashboardMigrationTitle,
          value: '${controller.migrationWorkspace.value?.activePlans ?? 0}',
          subtitle: controller.migrationWorkspace.value?.recommendedAction ?? l10n.exploreCities,
          icon: Icons.flight_takeoff_rounded,
          accent: const Color(0xFFFF7A59),
          routeName: AppRoutes.migrationWorkspace,
        ),
        _UtilityCardData(
          title: l10n.homeDashboardBudgetTitle,
          value: '\$${controller.budgetCenter.value?.forecastMonthlyCostUsd.round() ?? 0}',
          subtitle: controller.budgetCenter.value?.recommendedAction ?? l10n.costOfLiving,
          icon: Icons.savings_rounded,
          accent: const Color(0xFF59B77A),
          routeName: AppRoutes.budgetCenter,
        ),
        _UtilityCardData(
          title: l10n.homeDashboardVisaTitle,
          value: '${controller.visaCenter.value?.attentionRequiredCount ?? 0}',
          subtitle: controller.visaCenter.value?.recommendedAction ?? l10n.preferences,
          icon: Icons.badge_rounded,
          accent: const Color(0xFF5C8CFF),
          routeName: AppRoutes.visaCenter,
        ),
        _UtilityCardData(
          title: l10n.homeDashboardInboxTitle,
          value: '${controller.inboxSummary.value?.unreadNotifications ?? 0}',
          subtitle: controller.inboxSummary.value == null
              ? l10n.connect
              : '${controller.inboxSummary.value!.actionRequiredCount} ${l10n.current}',
          icon: Icons.mark_email_unread_rounded,
          accent: const Color(0xFFF3BB4A),
          routeName: AppRoutes.inbox,
        ),
      ];

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.forNomads,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.land),
                child: Text(l10n.seeAll),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            l10n.findYourTribe,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: isMobile ? 164 : 178,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cards.length,
              separatorBuilder: (_, __) => SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: isMobile ? 168 : 196,
                child: _UtilityCard(card: cards[index]),
              ),
            ),
          ),
          if (controller.priorityQueueTasks.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.priorityQueueTasks.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final task = controller.priorityQueueTasks[index];
                  return _TaskChip(task: task);
                },
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _PromptCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _PromptCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.cityPrimary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.login_rounded, color: AppColors.cityPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeDashboardPromptTitle,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.homeDashboardPromptCta,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          FilledButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            child: Text(l10n.open),
          ),
        ],
      ),
    );
  }
}

class _UtilityCardData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String routeName;

  const _UtilityCardData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.routeName,
  });
}

class _UtilityCard extends StatelessWidget {
  final _UtilityCardData card;

  const _UtilityCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(card.routeName),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppUiTokens.softFloatingShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: card.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(card.icon, size: 18, color: card.accent),
            ),
            const SizedBox(height: 14),
            Text(
              card.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              card.subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),
            const Spacer(),
            Row(
              children: [
                Text(
                  card.value,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, size: 18, color: card.accent),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskChip extends StatelessWidget {
  final HomeDashboardTask task;

  const _TaskChip({required this.task});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(task.routeName),
      child: Container(
        width: 240,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(22),
          boxShadow: AppUiTokens.softFloatingShadow,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: task.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(task.icon, size: 16, color: task.accentColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
