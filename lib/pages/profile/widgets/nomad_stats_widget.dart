import 'package:df_admin_mobile/features/user/presentation/controllers/user_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 统计数据部分组件
class NomadStatsWidget extends StatelessWidget {
  final bool isMobile;

  const NomadStatsWidget({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<UserStateController>();

    return Obx(() {
      final stats = controller.nomadStats.value;
      final favoriteCityCount = controller.favoriteCityIds.length;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nomad Stats',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _StatCard(
                emoji: '🌍',
                value: (stats?.countriesVisited ?? 0).toString(),
                label: 'Countries',
                isMobile: isMobile,
              ),
              _StatCard(
                emoji: '🏙️',
                value: (stats?.citiesLived ?? 0).toString(),
                label: l10n.cities,
                isMobile: isMobile,
              ),
              _StatCard(
                emoji: '📅',
                value: (stats?.daysNomading ?? 0).toString(),
                label: 'Days nomading',
                isMobile: isMobile,
              ),
              _ClickableStatCard(
                emoji: '🤝',
                value: (stats?.meetupsCreated ?? 0).toString(),
                label: 'Meetups',
                isMobile: isMobile,
                onTap: () => Get.toNamed(AppRoutes.myMeetups),
              ),
              _StatCard(
                emoji: '✈️',
                value: (stats?.tripsCompleted ?? 0).toString(),
                label: 'Trips',
                isMobile: isMobile,
              ),
              _ClickableStatCard(
                emoji: '❤️',
                value: (stats?.favoriteCitiesCount ?? favoriteCityCount).toString(),
                label: 'Favorites',
                isMobile: isMobile,
                onTap: () => Get.toNamed(AppRoutes.favorites),
              ),
            ],
          ),
        ],
      );
    });
  }
}

/// 统计卡片
class _StatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final bool isMobile;

  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isMobile ? ((Get.width - 44) / 2) : 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a1a),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6b7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 可点击的统计卡片
class _ClickableStatCard extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  final bool isMobile;
  final VoidCallback? onTap;

  const _ClickableStatCard({
    required this.emoji,
    required this.value,
    required this.label,
    required this.isMobile,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isMobile ? ((Get.width - 44) / 2) : 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a1a),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6b7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Color(0xFF6b7280),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
