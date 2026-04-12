import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/config/app_ui_tokens.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:go_nomads_app/pages/home/home_page_controller.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';

class HomeHeroSection extends GetView<HomePageController> {
  final bool isMobile;

  const HomeHeroSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F6FA),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 18.w : 32.w,
            isMobile ? 12.h : 20.h,
            isMobile ? 18.w : 32.w,
            isMobile ? 8.h : 12.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroTopBar(isMobile: isMobile),
              SizedBox(height: 18.h),
              _HeroSearchBar(isMobile: isMobile),
              SizedBox(height: 14.h),
              _HeroTabs(isMobile: isMobile),
              SizedBox(height: 18.h),
              Obx(() {
                final cities = controller.displayCities;
                if (controller.isLoadingCities || cities.isEmpty) {
                  return _HeroLoadingState(isMobile: isMobile);
                }

                final featuredCity = cities.first;
                final supportingCities = cities.skip(1).take(2).toList(growable: false);

                if (isMobile) {
                  return Column(
                    children: [
                      _FeaturedCityCard(city: featuredCity, isMobile: true),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          Expanded(
                            child: _MiniInfoCard(
                              title: AppLocalizations.of(context)!.currentLocation,
                              subtitle: featuredCity.displayCountry,
                              accent: AppColors.cityPrimary,
                              icon: FontAwesomeIcons.locationDot,
                              child: _MapPattern(accent: AppColors.cityPrimary),
                              onTap: () => controller.checkLoginAndNavigate(
                                () => Get.toNamed(AppRoutes.globalMap),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _MiniInfoCard(
                              title: AppLocalizations.of(context)!.weather,
                              subtitle: featuredCity.displayCountry,
                              accent: const Color(0xFF69B8FF),
                              icon: FontAwesomeIcons.solidSun,
                              child: _WeatherPreview(city: featuredCity),
                            ),
                          ),
                        ],
                      ),
                      if (supportingCities.isNotEmpty) ...[
                        SizedBox(height: 14.h),
                        SizedBox(
                          height: 116.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: supportingCities.length,
                            separatorBuilder: (_, __) => SizedBox(width: 12.w),
                            itemBuilder: (context, index) => SizedBox(
                              width: 168.w,
                              child: _CompactDestinationCard(city: supportingCities[index]),
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _FeaturedCityCard(city: featuredCity, isMobile: false),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 5,
                      child: Column(
                        children: [
                          _MiniInfoCard(
                            title: AppLocalizations.of(context)!.currentLocation,
                            subtitle: featuredCity.displayCountry,
                            accent: AppColors.cityPrimary,
                            icon: FontAwesomeIcons.locationDot,
                            child: _MapPattern(accent: AppColors.cityPrimary),
                            onTap: () => controller.checkLoginAndNavigate(
                              () => Get.toNamed(AppRoutes.globalMap),
                            ),
                          ),
                          SizedBox(height: 14.h),
                          _MiniInfoCard(
                            title: AppLocalizations.of(context)!.weather,
                            subtitle: featuredCity.displayCountry,
                            accent: const Color(0xFF69B8FF),
                            icon: FontAwesomeIcons.solidSun,
                            child: _WeatherPreview(city: featuredCity),
                          ),
                          if (supportingCities.isNotEmpty) ...[
                            SizedBox(height: 14.h),
                            ...supportingCities.map(
                              (city) => Padding(
                                padding: EdgeInsets.only(bottom: 14.h),
                                child: _CompactDestinationCard(city: city),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTopBar extends StatelessWidget {
  final bool isMobile;

  const _HeroTopBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Text(
          l10n.explore,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: isMobile ? 28.sp : 34.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(width: 6.w),
        Icon(
          Icons.keyboard_arrow_down_rounded,
          color: AppColors.textSecondary,
          size: isMobile ? 24.r : 28.r,
        ),
        const Spacer(),
        Container(
          width: isMobile ? 38.w : 44.w,
          height: isMobile ? 38.w : 44.w,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Stack(
            children: [
              Center(
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.textPrimary,
                  size: isMobile ? 22.r : 24.r,
                ),
              ),
              const Positioned(top: 6, right: 6, child: _StatusDot()),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroSearchBar extends StatelessWidget {
  final bool isMobile;

  const _HeroSearchBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: isMobile ? 48.h : 54.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F6),
        borderRadius: BorderRadius.circular(18.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20.r),
          SizedBox(width: 10.w),
          Text(
            l10n.searchHint,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: isMobile ? 14.sp : 15.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroTabs extends StatelessWidget {
  final bool isMobile;

  const _HeroTabs({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [
      l10n.homeExploreTabNew,
      l10n.popular,
      l10n.homeExploreTabRecent,
      l10n.homeExploreTabRecommended,
    ];

    return SizedBox(
      height: 34.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (context, index) {
          final selected = index == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: selected ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: selected ? AppUiTokens.softFloatingShadow : null,
            ),
            child: Text(
              labels[index],
              style: TextStyle(
                color: selected ? AppColors.textPrimary : AppColors.textTertiary,
                fontSize: isMobile ? 12.sp : 13.sp,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedCityCard extends StatelessWidget {
  final City city;
  final bool isMobile;

  const _FeaturedCityCard({required this.city, required this.isMobile});

  void _openCity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CityDetailPage(
          cityId: city.id,
          cityName: city.name,
          cityImages: city.landscapeImageUrls ?? [],
          cityImage: city.displayImageUrl,
          overallScore: (city.overallScore as num?)?.toDouble() ?? 0.0,
          reviewCount: (city.reviewCount as num?)?.toInt() ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _openCity(context),
      child: Container(
        height: isMobile ? 250.h : 320.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x140F172A),
              blurRadius: 28.r,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeNetworkImage(
                imageUrl: city.displayImageUrl,
                fit: BoxFit.cover,
                placeholder: Container(color: const Color(0xFFE9EDF3)),
                errorWidget: Container(
                  color: const Color(0xFFE9EDF3),
                  child: Icon(FontAwesomeIcons.image, color: AppColors.iconSecondary, size: 24.r),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x14000000),
                      Color(0x22000000),
                      Color(0xA6000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16.h,
                left: 16.w,
                child: _GlassPill(
                  icon: FontAwesomeIcons.wifi,
                  label: '${city.displayInternetScore.toStringAsFixed(1)} Mbps',
                ),
              ),
              Positioned(
                top: 16.h,
                right: 16.w,
                child: _GlassIconButton(
                  icon: Icons.bookmark_border_rounded,
                  onTap: () {},
                ),
              ),
              Positioned(
                left: 18.w,
                right: 18.w,
                bottom: 18.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 24.sp : 30.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      city.description?.isNotEmpty == true
                          ? city.description!
                          : '${city.displayCountry} · ${l10n.byNomads}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: isMobile ? 12.sp : 13.sp,
                        height: 1.4,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _MetricBadge(
                          label: l10n.nomadScore,
                          value: city.displayOverallScore.toStringAsFixed(1),
                        ),
                        SizedBox(width: 10.w),
                        _MetricBadge(
                          label: l10n.cost,
                          value: city.averageCost != null && city.averageCost! > 0
                              ? '\$${city.averageCost!.toInt()}/${l10n.month}'
                              : '--',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accent;
  final IconData icon;
  final Widget child;
  final VoidCallback? onTap;

  const _MiniInfoCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.icon,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 122.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 14.r, color: accent),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          child,
        ],
      ),
    );

    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class _WeatherPreview extends StatelessWidget {
  final City city;

  const _WeatherPreview({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF74C8FF), Color(0xFFA7D9FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Text(
            '${city.displayTemperature}°',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          Icon(FontAwesomeIcons.cloudSun, color: Colors.white, size: 18.r),
        ],
      ),
    );
  }
}

class _MapPattern extends StatelessWidget {
  final Color accent;

  const _MapPattern({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: const Color(0xFFF7F8FB),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 14.w,
            top: 18.h,
            right: 14.w,
            child: Container(height: 1.2, color: const Color(0xFFE7EAF1)),
          ),
          Positioned(top: 12.h, left: 28.w, child: _MapDot(color: accent)),
          Positioned(top: 26.h, left: 72.w, child: const _MapDot(color: Color(0xFFFFBF66))),
          Positioned(top: 18.h, right: 34.w, child: const _MapDot(color: Color(0xFF76C4F7))),
        ],
      ),
    );
  }
}

class _MapDot extends StatelessWidget {
  final Color color;

  const _MapDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _CompactDestinationCard extends StatelessWidget {
  final City city;

  const _CompactDestinationCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: AppUiTokens.softFloatingShadow,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SafeNetworkImage(
              imageUrl: city.displayImageUrl,
              width: 64.w,
              height: 64.w,
              fit: BoxFit.cover,
              placeholder: Container(color: const Color(0xFFE9EDF3)),
              errorWidget: Container(color: const Color(0xFFE9EDF3)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  city.displayCountry,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.solidStar, size: 10.r, color: const Color(0xFFFBBF24)),
                    SizedBox(width: 4.w),
                    Text(
                      city.displayOverallScore.toStringAsFixed(1),
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroLoadingState extends StatelessWidget {
  final bool isMobile;

  const _HeroLoadingState({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: isMobile ? 250.h : 320.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        SizedBox(height: 14.h),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 122.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Container(
                height: 122.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, size: 18.r, color: Colors.white),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBadge({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 8,
      height: 8,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFFF6B4A),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class HomeFeatureHighlights extends StatelessWidget {
  final bool isMobile;

  const HomeFeatureHighlights({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {'icon': FontAwesomeIcons.userGroup, 'text': l10n.attendMeetupsInCities},
      {'icon': FontAwesomeIcons.heart, 'text': l10n.meetNewPeople},
      {'icon': FontAwesomeIcons.chartLine, 'text': l10n.researchDestinations},
      {'icon': FontAwesomeIcons.earthAmericas, 'text': l10n.keepTrackTravels},
      {'icon': FontAwesomeIcons.comments, 'text': l10n.joinCommunityChat},
    ];

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: features.map((feature) {
        return Container(
          constraints: BoxConstraints(
            minWidth: isMobile ? 150.w : 180.w,
            maxWidth: isMobile ? 190.w : 220.w,
          ),
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppUiTokens.softFloatingShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: AppColors.cityPrimary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  feature['icon']! as IconData,
                  size: 16.r,
                  color: AppColors.cityPrimary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  feature['text']! as String,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: isMobile ? 12.sp : 13.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(growable: false),
    );
  }
}
