import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/auth/presentation/controllers/auth_state_controller.dart';
import 'package:go_nomads_app/features/city/domain/entities/city.dart';
import 'package:go_nomads_app/features/city/presentation/controllers/city_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/city_detail/city_detail.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/safe_network_image.dart';

class HomeCityCard extends StatelessWidget {
  final City city;
  final VoidCallback? onReturnFromDetail;

  const HomeCityCard({
    super.key,
    required this.city,
    this.onReturnFromDetail,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => _navigateToDetail(context, l10n),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x140F172A),
              blurRadius: 22.r,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeNetworkImage(
                imageUrl: city.displayImageUrl,
                fit: BoxFit.cover,
                placeholder: Container(color: const Color(0xFFE7ECF3)),
                errorWidget: Container(
                  color: const Color(0xFFE7ECF3),
                  child: const Icon(FontAwesomeIcons.image, color: Colors.white70),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x1A000000),
                      Color(0x33000000),
                      Color(0xCC000000),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 12.h,
                left: 12.w,
                right: 12.w,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _GlassBadge(
                      icon: FontAwesomeIcons.wifi,
                      label: '${city.displayInternetScore.toStringAsFixed(1)} Mbps',
                    ),
                    const Spacer(),
                    Obx(() {
                      final authController = Get.find<AuthStateController>();
                      final user = authController.currentUser.value;
                      final isAdmin = user?.role.toLowerCase() == 'admin';
                      final isCityModerator = city.isCurrentUserModerator ||
                          (city.moderatorId != null && city.moderatorId == user?.id);
                      if (!isAdmin && !isCityModerator) {
                        return const SizedBox.shrink();
                      }

                      return _GenerateImageButton(
                        cityId: city.id,
                        cityName: city.name,
                        isMobile: isMobile,
                      );
                    }),
                  ],
                ),
              ),
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: 14.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 22.sp : 24.sp,
                        fontWeight: FontWeight.w800,
                        height: 1.02,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      city.displayCountry,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.86),
                        fontSize: isMobile ? 12.sp : 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _BottomMetric(
                          icon: FontAwesomeIcons.solidStar,
                          value: city.displayOverallScore.toStringAsFixed(1),
                          iconColor: const Color(0xFFFBBF24),
                        ),
                        SizedBox(width: 8.w),
                        if (city.averageCost != null && city.averageCost! > 0)
                          _BottomMetric(
                            icon: FontAwesomeIcons.dollarSign,
                            value: '\$${city.averageCost!.toInt()}/${l10n.month}',
                            iconColor: const Color(0xFF86EFAC),
                          ),
                        const Spacer(),
                        _CountPill(
                          icon: FontAwesomeIcons.laptop,
                          value: '${city.coworkingCount ?? 0}',
                        ),
                        SizedBox(width: 6.w),
                        _CountPill(
                          icon: FontAwesomeIcons.userGroup,
                          value: '${city.meetupCount ?? 0}',
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

  void _navigateToDetail(BuildContext context, AppLocalizations l10n) {
    log('🏙️ City card tapped: ${city.name}');

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(
        l10n.pleaseLoginToCreateMeetup,
        title: l10n.loginRequired,
      );
      Get.toNamed(AppRoutes.login);
      return;
    }

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
    ).then((_) {
      onReturnFromDetail?.call();
    });
  }
}

class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _GlassBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomMetric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color iconColor;

  const _BottomMetric({
    required this.icon,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: iconColor),
          SizedBox(width: 5.w),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final IconData icon;
  final String value;

  const _CountPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: AppColors.textSecondary),
          SizedBox(width: 4.w),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateImageButton extends StatelessWidget {
  final String cityId;
  final String cityName;
  final bool isMobile;

  const _GenerateImageButton({
    required this.cityId,
    required this.cityName,
    required this.isMobile,
  });

  AppLocalizations get _l10n => AppLocalizations.of(Get.context!)!;

  Future<void> _generateImages() async {
    final cityController = Get.find<CityStateController>();

    if (cityController.isGeneratingImages(cityId)) return;

    final authController = Get.find<AuthStateController>();
    if (!authController.isAuthenticated.value) {
      AppToast.warning(_l10n.pleaseLogin, title: _l10n.loginRequired);
      Get.toNamed(AppRoutes.login);
      return;
    }

    final user = authController.currentUser.value;
    final isAdmin = user?.role.toLowerCase() == 'admin';

    bool isCityModerator = false;
    try {
      final city = cityController.cities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.recommendedCities.firstWhereOrNull((c) => c.id == cityId) ??
          cityController.popularCities.firstWhereOrNull((c) => c.id == cityId);
      if (city != null) {
        isCityModerator =
            city.isCurrentUserModerator || (city.moderatorId != null && city.moderatorId == user?.id);
      }
    } catch (_) {}

    if (!isAdmin && !isCityModerator) {
      AppToast.warning(_l10n.dataServicePermissionDenied, title: _l10n.dataServicePermissionDenied);
      return;
    }

    AppToast.info(
      _l10n.dataServiceImageTaskCreated(cityName),
      title: _l10n.dataServiceTaskCreated,
    );

    final result = await cityController.generateCityImages(cityId);

    result.fold(
      onSuccess: (data) {
        final taskData = data['data'] as Map<String, dynamic>?;
        final taskId = taskData?['taskId'] as String? ?? '';
        log('🖼️ Image generation task created: taskId=$taskId');
      },
      onFailure: (exception) {
        AppToast.error(exception.message, title: _l10n.dataServiceTaskCreationFailed);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityController = Get.find<CityStateController>();

    return Obx(() {
      final isGenerating = cityController.isGeneratingImages(cityId);

      return GestureDetector(
        onTap: isGenerating ? null : _generateImages,
        child: Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: isGenerating
              ? Padding(
                  padding: EdgeInsets.all(9.r),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(
                  FontAwesomeIcons.arrowsRotate,
                  color: Colors.white,
                  size: isMobile ? 12 : 14,
                ),
        ),
      );
    });
  }
}
