import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_hero_banner.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_metric_card.dart';
import 'package:go_nomads_app/widgets/surfaces/app_card_surface.dart';
import 'package:go_nomads_app/widgets/surfaces/app_section_surface.dart';
import 'package:go_nomads_app/widgets/surfaces/app_state_surface.dart';
import 'package:go_nomads_app/widgets/surfaces/app_subsection_header.dart';

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

      final cards = <_SummaryCardData>[
        _SummaryCardData(
          title: l10n.homeDashboardMigrationTitle,
          headline: '${controller.migrationWorkspace.value?.activePlans ?? 0}',
          supporting:
              controller.migrationWorkspace.value?.recommendedAction ?? '',
          routeName: AppRoutes.migrationWorkspace,
          accentColor: const Color(0xFFFF6B6B),
          icon: Icons.flight_takeoff_rounded,
        ),
        _SummaryCardData(
          title: l10n.homeDashboardBudgetTitle,
          headline:
              '\$${controller.budgetCenter.value?.forecastMonthlyCostUsd.round() ?? 0}',
          supporting: controller.budgetCenter.value?.recommendedAction ?? '',
          routeName: AppRoutes.budgetCenter,
          accentColor: const Color(0xFF2A9D8F),
          icon: Icons.savings_rounded,
        ),
        _SummaryCardData(
          title: l10n.homeDashboardVisaTitle,
          headline:
              '${controller.visaCenter.value?.attentionRequiredCount ?? 0}',
          supporting: controller.visaCenter.value?.recommendedAction ?? '',
          routeName: AppRoutes.visaCenter,
          accentColor: const Color(0xFFE9C46A),
          icon: Icons.badge_rounded,
        ),
        _SummaryCardData(
          title: l10n.homeDashboardInboxTitle,
          headline:
              '${controller.inboxSummary.value?.unreadNotifications ?? 0}',
          supporting: controller.inboxSummary.value == null
              ? ''
              : '${controller.inboxSummary.value!.actionRequiredCount} action required',
          routeName: AppRoutes.inbox,
          accentColor: const Color(0xFF457B9D),
          icon: Icons.mark_email_unread_rounded,
        ),
      ];

      return AppSectionSurface(
        title: l10n.homeDashboardTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CockpitHeroBanner(
              icon: Icons.space_dashboard_rounded,
              title: l10n.homeDashboardTitle,
              subtitle: '',
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFF1F2),
                  Color(0xFFF7FAFC),
                  Color(0xFFEAF4FF)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              metrics: [
                CockpitHeroMetric(
                  icon: Icons.flight_takeoff_rounded,
                  label:
                      '${controller.migrationWorkspace.value?.activePlans ?? 0} ${l10n.homeDashboardMigrationTitle}',
                ),
                CockpitHeroMetric(
                  icon: Icons.badge_rounded,
                  label:
                      '${controller.visaCenter.value?.attentionRequiredCount ?? 0} ${l10n.homeDashboardVisaTitle}',
                ),
                CockpitHeroMetric(
                  icon: Icons.mark_email_unread_rounded,
                  label:
                      '${controller.inboxSummary.value?.actionRequiredCount ?? 0} ${l10n.inboxActionRequired}',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (controller.isLoadingDashboard.value &&
                !controller.hasDashboardData)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child:
                    AppStateSurface.loading(message: l10n.homeDashboardLoading),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    isMobile ? (constraints.maxWidth - 12) / 2 : 220.0;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: cards
                      .map(
                        (card) => SizedBox(
                          width: cardWidth,
                          child: _SummaryCard(card: card),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
            if (controller.priorityQueueTasks.isNotEmpty) ...[
              const SizedBox(height: 18),
              AppSubsectionHeader(
                title: l10n.homePriorityQueueTitle,
              ),
              const SizedBox(height: 10),
              ...controller.priorityQueueTasks.map(
                (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _PriorityTaskTile(task: task),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _PromptCard extends StatelessWidget {
  final AppLocalizations l10n;

  const _PromptCard({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return AppSectionSurface(
      title: l10n.homeDashboardPromptTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FilledButton.tonalIcon(
            onPressed: () => Get.toNamed(AppRoutes.login),
            icon: const Icon(Icons.login_rounded),
            label: Text(l10n.homeDashboardPromptCta),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardData {
  final String title;
  final String headline;
  final String supporting;
  final String routeName;
  final Color accentColor;
  final IconData icon;

  const _SummaryCardData({
    required this.title,
    required this.headline,
    required this.supporting,
    required this.routeName,
    required this.accentColor,
    required this.icon,
  });
}

class _SummaryCard extends StatelessWidget {
  final _SummaryCardData card;

  const _SummaryCard({required this.card});

  @override
  Widget build(BuildContext context) {
    return CockpitMetricCard(
      icon: card.icon,
      label: card.title,
      value: card.headline,
      supporting: card.supporting.isEmpty ? null : card.supporting,
      accentColor: card.accentColor,
      onTap: () => Get.toNamed(card.routeName),
    );
  }
}

class _PriorityTaskTile extends StatelessWidget {
  final HomeDashboardTask task;

  const _PriorityTaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return AppCardSurface(
      onTap: () => Get.toNamed(task.routeName),
      padding: const EdgeInsets.all(14),
      backgroundColor: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: task.accentColor.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: task.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(task.icon, size: 16, color: task.accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  task.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 14, color: AppColors.iconSecondary),
        ],
      ),
    );
  }
}
