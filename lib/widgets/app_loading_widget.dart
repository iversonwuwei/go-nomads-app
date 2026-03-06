import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';

enum AppLoadingScene {
  generic,
  cityList,
  coworkingList,
  hotel,
  hotelDetail,
  innovation,
  innovationDetail,
  meetup,
  meetupDetail,
  profile,
  form,
  notifications,
  weather,
  reviews,
  costs,
  tags,
  travelPlan,
}

class _AppLoadingSceneSpec {
  final String title;
  final IconData icon;
  final Color accentColor;

  const _AppLoadingSceneSpec({
    required this.title,
    required this.icon,
    required this.accentColor,
  });
}

class AppSceneLoading extends StatelessWidget {
  final AppLoadingScene scene;
  final bool fullScreen;
  final String? subtitleOverride;

  const AppSceneLoading({
    super.key,
    this.scene = AppLoadingScene.generic,
    this.fullScreen = true,
    this.subtitleOverride,
  });

  static const _brandRed = Color(0xFFFF4458);
  static const _brandBlue = Color(0xFF4A6CF7);
  static const _brandTeal = Color(0xFF1E9E8F);
  static const _brandAmber = Color(0xFFF59E0B);

  _AppLoadingSceneSpec _resolveSpec(AppLocalizations l10n) {
    switch (scene) {
      case AppLoadingScene.cityList:
        return _AppLoadingSceneSpec(
          title: l10n.citiesList,
          icon: Icons.location_city_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.coworkingList:
        return _AppLoadingSceneSpec(
          title: l10n.coworkingSpaces,
          icon: Icons.business_center_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.hotel:
        return _AppLoadingSceneSpec(
          title: l10n.hotel,
          icon: Icons.hotel_rounded,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.hotelDetail:
        return _AppLoadingSceneSpec(
          title: l10n.hotel,
          icon: Icons.king_bed_rounded,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.innovation:
        return _AppLoadingSceneSpec(
          title: l10n.innovation,
          icon: Icons.lightbulb_rounded,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.innovationDetail:
        return _AppLoadingSceneSpec(
          title: l10n.innovation,
          icon: Icons.rocket_launch_rounded,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.meetup:
        return _AppLoadingSceneSpec(
          title: l10n.meetup,
          icon: Icons.groups_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.meetupDetail:
        return _AppLoadingSceneSpec(
          title: l10n.meetup,
          icon: Icons.event_note_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.profile:
        return _AppLoadingSceneSpec(
          title: l10n.profile,
          icon: Icons.person_rounded,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.form:
        return _AppLoadingSceneSpec(
          title: l10n.edit,
          icon: Icons.edit_note_rounded,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.notifications:
        return _AppLoadingSceneSpec(
          title: l10n.notifications,
          icon: Icons.notifications_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.weather:
        return _AppLoadingSceneSpec(
          title: l10n.weather,
          icon: Icons.wb_sunny_rounded,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.reviews:
        return _AppLoadingSceneSpec(
          title: l10n.review,
          icon: Icons.rate_review_rounded,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.costs:
        return _AppLoadingSceneSpec(
          title: l10n.cost,
          icon: Icons.paid_rounded,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.tags:
        return _AppLoadingSceneSpec(
          title: l10n.loading,
          icon: Icons.sell_rounded,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.travelPlan:
        return _AppLoadingSceneSpec(
          title: l10n.generatingAiPlan,
          icon: Icons.auto_awesome_rounded,
          accentColor: _brandRed,
        );
      case AppLoadingScene.generic:
        return _AppLoadingSceneSpec(
          title: l10n.loading,
          icon: Icons.hourglass_top_rounded,
          accentColor: _brandBlue,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return AppLoadingWidget(
        fullScreen: fullScreen,
        title: 'Loading...',
        subtitle: subtitleOverride,
      );
    }
    final spec = _resolveSpec(l10n);
    return AppLoadingWidget(
      fullScreen: fullScreen,
      title: spec.title,
      subtitle: subtitleOverride ?? l10n.loading,
      icon: spec.icon,
      accentColor: spec.accentColor,
    );
  }
}

/// Unified loading widget used across the app.
/// It avoids heavy skeleton/shimmer rendering and provides a smooth transition.
class AppLoadingWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData icon;
  final Color? accentColor;
  final bool showSpinner;
  final bool fullScreen;

  const AppLoadingWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon = Icons.hourglass_top_rounded,
    this.accentColor,
    this.showSpinner = true,
    this.fullScreen = false,
  });

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accentColor ?? Theme.of(context).colorScheme.primary;

    final content = Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final t = _pulseController.value;
          final scale = 0.96 + (t * 0.04);
          final opacity = 0.72 + (t * 0.28);

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: Container(
          constraints: BoxConstraints(maxWidth: 320.w),
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: accent.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18.r,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(widget.icon, size: 28.r, color: accent),
              ),
              if (widget.showSpinner) ...[
                SizedBox(height: 14.h),
                SizedBox(
                  width: 22.w,
                  height: 22.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
              ],
              if (widget.title != null) ...[
                SizedBox(height: 14.h),
                Text(
                  widget.title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
              if (widget.subtitle != null) ...[
                SizedBox(height: 6.h),
                Text(
                  widget.subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    if (!widget.fullScreen) return content;

    return ColoredBox(
      color: Colors.transparent,
      child: SizedBox.expand(child: content),
    );
  }
}

/// Smoothly switches between loading and content states.
class AppLoadingSwitcher extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Widget? loading;
  final String? title;
  final String? subtitle;

  const AppLoadingSwitcher({
    super.key,
    required this.isLoading,
    required this.child,
    this.loading,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: isLoading
          ? KeyedSubtree(
              key: const ValueKey('loading'),
              child: loading ?? AppLoadingWidget(title: title, subtitle: subtitle, fullScreen: true),
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}
