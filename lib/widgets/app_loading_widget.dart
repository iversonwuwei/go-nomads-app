import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/double_spin_loader.dart';

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
  final Color accentColor;

  const _AppLoadingSceneSpec({
    required this.title,
    required this.accentColor,
  });
}

class AppSceneLoading extends StatelessWidget {
  final AppLoadingScene scene;
  final bool fullScreen;
  final String? subtitleOverride;
  final double cardWidth;
  final double cardHeight;

  const AppSceneLoading({
    super.key,
    this.scene = AppLoadingScene.generic,
    this.fullScreen = true,
    this.subtitleOverride,
    this.cardWidth = 320,
    this.cardHeight = 220,
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
          accentColor: _brandBlue,
        );
      case AppLoadingScene.coworkingList:
        return _AppLoadingSceneSpec(
          title: l10n.coworkingSpaces,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.hotel:
        return _AppLoadingSceneSpec(
          title: l10n.hotel,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.hotelDetail:
        return _AppLoadingSceneSpec(
          title: l10n.hotel,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.innovation:
        return _AppLoadingSceneSpec(
          title: l10n.innovation,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.innovationDetail:
        return _AppLoadingSceneSpec(
          title: l10n.innovation,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.meetup:
        return _AppLoadingSceneSpec(
          title: l10n.meetup,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.meetupDetail:
        return _AppLoadingSceneSpec(
          title: l10n.meetup,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.profile:
        return _AppLoadingSceneSpec(
          title: l10n.profile,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.form:
        return _AppLoadingSceneSpec(
          title: l10n.edit,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.notifications:
        return _AppLoadingSceneSpec(
          title: l10n.notifications,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.weather:
        return _AppLoadingSceneSpec(
          title: l10n.weather,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.reviews:
        return _AppLoadingSceneSpec(
          title: l10n.review,
          accentColor: _brandBlue,
        );
      case AppLoadingScene.costs:
        return _AppLoadingSceneSpec(
          title: l10n.cost,
          accentColor: _brandTeal,
        );
      case AppLoadingScene.tags:
        return _AppLoadingSceneSpec(
          title: l10n.loading,
          accentColor: _brandAmber,
        );
      case AppLoadingScene.travelPlan:
        return _AppLoadingSceneSpec(
          title: l10n.generatingAiPlan,
          accentColor: _brandRed,
        );
      case AppLoadingScene.generic:
        return _AppLoadingSceneSpec(
          title: l10n.loading,
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
        cardWidth: cardWidth,
        cardHeight: cardHeight,
      );
    }
    final spec = _resolveSpec(l10n);
    return AppLoadingWidget(
      fullScreen: fullScreen,
      title: spec.title,
      subtitle: subtitleOverride ?? l10n.loading,
      accentColor: spec.accentColor,
      cardWidth: cardWidth,
      cardHeight: cardHeight,
    );
  }
}

/// Unified loading widget used across the app.
/// It avoids heavy skeleton/shimmer rendering and provides a smooth transition.
class AppLoadingWidget extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? accentColor;
  final bool showSpinner;
  final bool fullScreen;
  final double cardWidth;
  final double cardHeight;
  final bool keepAspectScale;
  final double minScale;

  const AppLoadingWidget({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.showSpinner = true,
    this.fullScreen = false,
    this.cardWidth = 320,
    this.cardHeight = 220,
    this.keepAspectScale = true,
    this.minScale = 0.3,
  });

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  static const _brandTitle = '行途 Go Nomads';
  static const _brandTagline = 'Explore cities, workspaces and community';

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

    final inlineLoader = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSpinner)
          DoubleSpinLoader(
            size: 38.w,
            strokeWidth: 2.8,
            color1: accent,
            color2: accent.withValues(alpha: 0.72),
            trackColor: accent.withValues(alpha: 0.14),
          ),
        if (widget.title != null) ...[
          SizedBox(height: 14.h),
          Text(
            widget.title!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: 0.2,
            ),
          ),
        ],
        if (widget.subtitle != null) ...[
          SizedBox(height: 6.h),
          Text(
            widget.subtitle!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    final content = Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final baseWidth = widget.cardWidth.w;
          final baseHeight = widget.cardHeight.h;
          final horizontalPadding = 24.w;
          final verticalPadding = 24.h;
          final availableWidth =
              constraints.maxWidth.isFinite ? math.max(1.0, constraints.maxWidth - (horizontalPadding * 2)) : baseWidth;
          final availableHeight = constraints.maxHeight.isFinite
              ? math.max(1.0, constraints.maxHeight - (verticalPadding * 2))
              : baseHeight;

          final widthScale = availableWidth / baseWidth;
          final heightScale = availableHeight / baseHeight;
          final fitScale = math.min(widthScale, heightScale);
          final safeFitScale = fitScale.isFinite ? fitScale : 1.0;
          final adaptiveScale = widget.keepAspectScale ? safeFitScale.clamp(widget.minScale, 1.0) : 1.0;

          return AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final t = _pulseController.value;
              final pulseScale = widget.fullScreen ? 0.985 + (t * 0.015) : 0.97 + (t * 0.03);
              final opacity = widget.fullScreen ? 0.9 + (t * 0.1) : 0.78 + (t * 0.22);

              return Opacity(
                opacity: opacity,
                child: Transform.scale(
                  scale: pulseScale * adaptiveScale,
                  child: child,
                ),
              );
            },
            child: inlineLoader,
          );
        },
      ),
    );

    if (!widget.fullScreen) return content;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            Color.lerp(AppColors.background, Colors.white, 0.45)!,
            Color.lerp(AppColors.background, accent, 0.06)!,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -80.h,
            right: -50.w,
            child: _DecorativeGlow(
              size: 220.w,
              color: accent.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            bottom: -90.h,
            left: -60.w,
            child: _DecorativeGlow(
              size: 240.w,
              color: AppColors.containerBlueGrey.withValues(alpha: 0.12),
            ),
          ),
          SizedBox.expand(
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final t = _pulseController.value;
                  final pulseScale = 0.985 + (t * 0.015);
                  final opacity = 0.9 + (t * 0.1);

                  return Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: pulseScale,
                      child: child,
                    ),
                  );
                },
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final maxHeight = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
                    final topGap = math.max(24.h, maxHeight * 0.12);
                    final betweenGap = math.max(18.h, maxHeight * 0.04);
                    final bottomGap = math.max(12.h, maxHeight * 0.03);

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 24.h),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: math.max(0, maxHeight - (48.h)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(height: topGap),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 72.w,
                                  height: 72.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(22.r),
                                    gradient: LinearGradient(
                                      colors: [
                                        accent.withValues(alpha: 0.92),
                                        Color.lerp(accent, AppColors.cityPrimaryLight, 0.55)!,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.18),
                                        blurRadius: 22.r,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.explore_rounded,
                                    color: Colors.white,
                                    size: 34.w,
                                  ),
                                ),
                                SizedBox(height: betweenGap),
                                Text(
                                  _brandTitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 280.w),
                                  child: Text(
                                    _brandTagline,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w400,
                                      height: 1.45,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                if (widget.showSpinner) ...[
                                  SizedBox(height: math.max(24.h, maxHeight * 0.05)),
                                  DoubleSpinLoader(
                                    size: 58.w,
                                    strokeWidth: 3.2,
                                    color1: accent,
                                    color2: accent.withValues(alpha: 0.5),
                                    trackColor: accent.withValues(alpha: 0.12),
                                  ),
                                ],
                                SizedBox(height: math.max(18.h, maxHeight * 0.035)),
                                Text(
                                  widget.title ?? 'Loading',
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (widget.subtitle != null) ...[
                                  SizedBox(height: 8.h),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(maxWidth: 300.w),
                                    child: Text(
                                      widget.subtitle!,
                                      textAlign: TextAlign.center,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 14.h),
                                _LoadingStatusDots(
                                  color: accent.withValues(alpha: 0.7),
                                  animation: _pulseController,
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: betweenGap, bottom: bottomGap),
                              child: Text(
                                'v1.0',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingStatusDots extends StatelessWidget {
  final Color color;
  final Animation<double> animation;

  const _LoadingStatusDots({
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final phase = ((animation.value + (index * 0.18)) % 1.0);
            final opacity = 0.28 + ((1 - ((phase - 0.5).abs() * 2)) * 0.72);
            final scale = 0.82 + ((1 - ((phase - 0.5).abs() * 2)) * 0.26);
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 7.w,
                    height: 7.w,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _DecorativeGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _DecorativeGlow({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
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
  final double loadingCardWidth;
  final double loadingCardHeight;

  const AppLoadingSwitcher({
    super.key,
    required this.isLoading,
    required this.child,
    this.loading,
    this.title,
    this.subtitle,
    this.loadingCardWidth = 320,
    this.loadingCardHeight = 220,
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
              child: loading ??
                  AppLoadingWidget(
                    title: title,
                    subtitle: subtitle,
                    fullScreen: true,
                    cardWidth: loadingCardWidth,
                    cardHeight: loadingCardHeight,
                  ),
            )
          : KeyedSubtree(
              key: const ValueKey('content'),
              child: child,
            ),
    );
  }
}
