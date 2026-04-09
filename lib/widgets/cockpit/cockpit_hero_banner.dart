import 'package:flutter/material.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/widgets/cockpit/cockpit_panel.dart';

class CockpitHeroMetric {
  final IconData icon;
  final String label;

  const CockpitHeroMetric({
    required this.icon,
    required this.label,
  });
}

class CockpitHeroBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<CockpitHeroMetric> metrics;
  final Gradient gradient;
  final Widget? trailing;
  final Color foregroundColor;
  final Color panelColor;
  final Color borderColor;

  const CockpitHeroBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.metrics = const [],
    required this.gradient,
    this.trailing,
    this.foregroundColor = AppColors.textPrimary,
    this.panelColor = Colors.white,
    this.borderColor = AppColors.borderLight,
  });

  @override
  Widget build(BuildContext context) {
    return CockpitPanel(
      gradient: gradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: panelColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor.withValues(alpha: 0.35)),
                ),
                child: Icon(icon, color: foregroundColor, size: 20),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: foregroundColor,
              height: 1.15,
                ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: foregroundColor.withValues(alpha: 0.82),
                    height: 1.35,
                  ),
            ),
          ],
          if (metrics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: metrics
                  .map(
                    (metric) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: panelColor.withValues(alpha: 0.74),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor.withValues(alpha: 0.45)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(metric.icon, size: 16, color: foregroundColor),
                          const SizedBox(width: 6),
                          Text(
                            metric.label,
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: foregroundColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
