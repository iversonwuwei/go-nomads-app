import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/features/travel_history/routes/travel_history_routes.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/profile/widgets/profile_section_header.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:intl/intl.dart';

/// 旅行历史部分组件
class TravelHistoryWidget extends StatelessWidget {
  final LatestTravelHistory? latestTrip;
  final bool isMobile;

  const TravelHistoryWidget({
    super.key,
    required this.latestTrip,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionHeader(
          title: l10n.travelHistory,
          onTap: () => Get.toNamed(TravelHistoryRoutes.travelHistory),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFF6b7280),
          ),
        ),
        SizedBox(height: 16.h),
        latestTrip == null
            ? _EmptyTravelHistory(isMobile: isMobile)
            : _LatestTripCard(trip: latestTrip!, isMobile: isMobile),
      ],
    );
  }
}

/// 空状态旅行历史
class _EmptyTravelHistory extends StatelessWidget {
  final bool isMobile;

  const _EmptyTravelHistory({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 40 : 60,
        horizontal: isMobile ? 20 : 40,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FontAwesomeIcons.compass,
              size: isMobile ? 48 : 64,
              color: Colors.grey.withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.noTravelHistoryYet,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.profileStartNomadJourney,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 最新旅行卡片
class _LatestTripCard extends StatelessWidget {
  final LatestTravelHistory trip;
  final bool isMobile;

  const _LatestTripCard({
    required this.trip,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateRange = _formatDateRange(
      context,
      trip.arrivalTime,
      trip.departureTime,
    );
    final daysAgo = DateTime.now().difference(trip.arrivalTime).inDays;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            trip.isOngoing
                ? const Color(0xFF10B981).withValues(alpha: 0.08)
                : const Color(0xFF3B82F6).withValues(alpha: 0.08),
            trip.isOngoing
                ? const Color(0xFF059669).withValues(alpha: 0.04)
                : const Color(0xFF1D4ED8).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: trip.isOngoing
              ? const Color(0xFF10B981).withValues(alpha: 0.2)
              : const Color(0xFF3B82F6).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed(
              TravelHistoryRoutes.visitedPlaces,
              arguments: {
                'travelHistoryId': trip.id,
                'cityId': trip.cityId,
                'cityName': trip.city,
                'countryName': trip.country,
              },
            );
          },
          onLongPress: () {
            if (trip.canNavigateToCityDetail) {
              Get.toNamed(
                AppRoutes.cityDetail,
                arguments: {
                  'cityId': trip.cityId,
                  'cityName': trip.city,
                  'cityImage': '',
                },
              );
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 顶部：状态标签和时间
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusBadge(isOngoing: trip.isOngoing),
                    Text(
                      trip.isOngoing ? l10n.today : _formatDaysAgo(l10n, daysAgo),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // 城市和国家
                Row(
                  children: [
                    _CountryFlag(country: trip.country),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.city,
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1a1a1a),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            trip.country,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _NavigationArrow(),
                  ],
                ),
                SizedBox(height: 16.h),

                // 底部信息栏
                _BottomInfoBar(
                  dateRange: dateRange,
                  durationDays: trip.durationDays,
                  hasLocation: trip.latitude != null && trip.longitude != null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(
    BuildContext context,
    DateTime arrival,
    DateTime? departure,
  ) {
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final fullFormat = DateFormat.yMMMd(localeTag);

    if (departure == null) {
      return '${fullFormat.format(arrival)} - ${AppLocalizations.of(context)!.present}';
    }

    if (arrival.year == departure.year) {
      final startFormat = DateFormat.MMMd(localeTag);
      return '${startFormat.format(arrival)} - ${fullFormat.format(departure)}';
    }

    return '${fullFormat.format(arrival)} - ${fullFormat.format(departure)}';
  }

  String _formatDaysAgo(AppLocalizations l10n, int days) {
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.yesterday;
    if (days < 7) return l10n.daysAgo(days.toString());
    if (days < 30) return l10n.weeksAgo(((days / 7).floor()).toString());
    if (days < 365) return l10n.monthsAgo(((days / 30).floor()).toString());
    return l10n.yearsAgo((days / 365).floor());
  }
}

/// 状态标签
class _StatusBadge extends StatelessWidget {
  final bool isOngoing;

  const _StatusBadge({required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isOngoing ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOngoing ? Icons.flight_takeoff : Icons.check_circle,
            size: 14.r,
            color: Colors.white,
          ),
          SizedBox(width: 4.w),
          Text(
            isOngoing ? l10n.profileCurrentlyHere : l10n.profileRecentTrip,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 国旗图标
class _CountryFlag extends StatelessWidget {
  final String country;

  const _CountryFlag({required this.country});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getCountryEmoji(country),
          style: TextStyle(fontSize: 24.sp),
        ),
      ),
    );
  }

  String _getCountryEmoji(String country) {
    final countryEmojis = {
      'China': '🇨🇳',
      'United States': '🇺🇸',
      'USA': '🇺🇸',
      'Japan': '🇯🇵',
      'South Korea': '🇰🇷',
      'Korea': '🇰🇷',
      'Thailand': '🇹🇭',
      'Vietnam': '🇻🇳',
      'Singapore': '🇸🇬',
      'Malaysia': '🇲🇾',
      'Indonesia': '🇮🇩',
      'Philippines': '🇵🇭',
      'Australia': '🇦🇺',
      'United Kingdom': '🇬🇧',
      'UK': '🇬🇧',
      'Germany': '🇩🇪',
      'France': '🇫🇷',
      'Italy': '🇮🇹',
      'Spain': '🇪🇸',
      'Portugal': '🇵🇹',
      'Netherlands': '🇳🇱',
      'Canada': '🇨🇦',
      'Brazil': '🇧🇷',
      'Mexico': '🇲🇽',
      'India': '🇮🇳',
      'Taiwan': '🇹🇼',
      'Hong Kong': '🇭🇰',
      'Macau': '🇲🇴',
      'New Zealand': '🇳🇿',
      'Switzerland': '🇨🇭',
      'Austria': '🇦🇹',
      'Belgium': '🇧🇪',
      'Sweden': '🇸🇪',
      'Norway': '🇳🇴',
      'Denmark': '🇩🇰',
      'Finland': '🇫🇮',
      'Ireland': '🇮🇪',
      'Greece': '🇬🇷',
      'Turkey': '🇹🇷',
      'Russia': '🇷🇺',
      'Poland': '🇵🇱',
      'Czech Republic': '🇨🇿',
      'Hungary': '🇭🇺',
      'UAE': '🇦🇪',
      'United Arab Emirates': '🇦🇪',
      'Saudi Arabia': '🇸🇦',
      'Israel': '🇮🇱',
      'Egypt': '🇪🇬',
      'South Africa': '🇿🇦',
      'Argentina': '🇦🇷',
      'Chile': '🇨🇱',
      'Colombia': '🇨🇴',
      'Peru': '🇵🇪',
    };
    return countryEmojis[country] ?? '🌍';
  }
}

/// 导航箭头
class _NavigationArrow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_forward_ios,
        size: 14.r,
        color: Color(0xFF6b7280),
      ),
    );
  }
}

/// 底部信息栏
class _BottomInfoBar extends StatelessWidget {
  final String dateRange;
  final int? durationDays;
  final bool hasLocation;

  const _BottomInfoBar({
    required this.dateRange,
    required this.durationDays,
    required this.hasLocation,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16.r,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (durationDays != null) ...[
            Container(
              width: 1.w,
              height: 20.h,
              color: Colors.grey[300],
            ),
            SizedBox(width: 12.w),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16.r,
                  color: Colors.grey[600],
                ),
                SizedBox(width: 6.w),
                Text(
                  '$durationDays ${durationDays == 1 ? l10n.profileDayUnit : l10n.profileDayUnitPlural}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (hasLocation) ...[
            Container(
              width: 1.w,
              height: 20.h,
              color: Colors.grey[300],
            ),
            SizedBox(width: 12.w),
            Icon(
              Icons.location_on_outlined,
              size: 16.r,
              color: Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }
}
