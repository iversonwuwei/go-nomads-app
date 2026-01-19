import 'package:go_nomads_app/features/travel_history/routes/travel_history_routes.dart';
import 'package:go_nomads_app/features/user/domain/entities/user.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

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
        // 标题行：点击可进入完整旅行历史页面
        InkWell(
          onTap: () => Get.toNamed(TravelHistoryRoutes.travelHistory),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.travelHistory,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF6b7280),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
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
        borderRadius: BorderRadius.circular(12),
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
            const SizedBox(height: 16),
            Text(
              'No travel history yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start your digital nomad journey!',
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
    final dateRange = _formatDateRange(trip.arrivalTime, trip.departureTime);
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
        borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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
                      trip.isOngoing ? 'Now' : _formatDaysAgo(daysAgo),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 城市和国家
                Row(
                  children: [
                    _CountryFlag(country: trip.country),
                    const SizedBox(width: 14),
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
                          const SizedBox(height: 2),
                          Text(
                            trip.country,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    _NavigationArrow(),
                  ],
                ),
                const SizedBox(height: 16),

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

  String _formatDateRange(DateTime arrival, DateTime? departure) {
    final arrivalStr = '${arrival.month}/${arrival.day}';
    if (departure != null) {
      final departureStr = '${departure.month}/${departure.day}';
      if (arrival.year == departure.year) {
        return '$arrivalStr - $departureStr, ${arrival.year}';
      }
      return '${arrival.year}/$arrivalStr - ${departure.year}/$departureStr';
    }
    return '${arrival.year}/$arrivalStr - Present';
  }

  String _formatDaysAgo(int days) {
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    if (days < 365) return '${(days / 30).floor()} months ago';
    return '${(days / 365).floor()} years ago';
  }
}

/// 状态标签
class _StatusBadge extends StatelessWidget {
  final bool isOngoing;

  const _StatusBadge({required this.isOngoing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOngoing ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOngoing ? Icons.flight_takeoff : Icons.check_circle,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isOngoing ? 'Currently Here' : 'Recent Trip',
            style: const TextStyle(
              fontSize: 12,
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
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getCountryEmoji(country),
          style: const TextStyle(fontSize: 24),
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    dateRange,
                    style: TextStyle(
                      fontSize: 13,
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
              width: 1,
              height: 20,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  '$durationDays ${durationDays == 1 ? 'day' : 'days'}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          if (hasLocation) ...[
            Container(
              width: 1,
              height: 20,
              color: Colors.grey[300],
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.location_on_outlined,
              size: 16,
              color: Colors.grey[600],
            ),
          ],
        ],
      ),
    );
  }
}
