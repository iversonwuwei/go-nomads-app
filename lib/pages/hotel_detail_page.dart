import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/hotel_detail_page_controller.dart';
import 'package:go_nomads_app/core/utils/map_app_launcher.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:go_nomads_app/widgets/skeletons/skeletons.dart';
import 'package:url_launcher/url_launcher.dart';

class HotelDetailPage extends StatelessWidget {
  final int hotelId;

  const HotelDetailPage({
    super.key,
    required this.hotelId,
  });

  String get _tag => 'hotel_detail_$hotelId';

  HotelDetailPageController get _controller {
    if (!Get.isRegistered<HotelDetailPageController>(tag: _tag)) {
      Get.put(HotelDetailPageController(hotelId: hotelId), tag: _tag);
    }
    return Get.find<HotelDetailPageController>(tag: _tag);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F3EE),
      body: Obx(() {
        Widget content;
        if (controller.error.value.isNotEmpty) {
          content = _buildErrorState(context, controller);
        } else {
          final hotel = controller.hotel.value;
          content = hotel == null ? _buildErrorState(context, controller) : _buildHotelDetail(context, hotel);
        }

        return AppLoadingSwitcher(
          isLoading: controller.isLoading.value,
          loading: const HotelDetailSkeleton(),
          child: content,
        );
      }),
      bottomNavigationBar: Obx(() {
        final hotel = controller.hotel.value;
        if (controller.isLoading.value || hotel == null) {
          return const SizedBox.shrink();
        }

        return _HotelActionBar(
          hotel: hotel,
          onOpenMap: () => MapAppLauncher.showMapSelectionDialog(
            context: context,
            latitude: hotel.latitude,
            longitude: hotel.longitude,
            destinationName: hotel.name,
          ),
          onOpenWebsite: hotel.website == null ? null : () => _launchExternalUrl(hotel.website!),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context, HotelDetailPageController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.circleExclamation,
              size: 60.r,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16.h),
            Text(
              controller.error.value.isNotEmpty ? controller.error.value : 'Hotel not found',
              style: TextStyle(fontSize: 16.sp, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            FilledButton(
              onPressed: Get.back,
              child: Text(l10n.goBack),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelDetail(BuildContext context, Hotel hotel) {
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 340.h,
          pinned: true,
          backgroundColor: const Color(0xFF121417),
          foregroundColor: Colors.white,
          flexibleSpace: FlexibleSpaceBar(
            background: _HotelHero(hotel: hotel),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: Offset(0, -42.h),
                  child: _StayProfileCard(hotel: hotel),
                ),
                SizedBox(height: 8.h),
                _SectionShell(
                  eyebrow: 'Stay signals',
                  title: 'What this stay optimizes for',
                  child: _SignalBoard(hotel: hotel),
                ),
                SizedBox(height: 16.h),
                _SectionShell(
                  eyebrow: 'Why it matters',
                  title: 'Nomad stay brief',
                  child: Text(
                    hotel.description.isEmpty
                        ? 'No stay brief has been written for this hotel yet.'
                        : hotel.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: const Color(0xFF4F5B67),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                _SectionShell(
                  eyebrow: 'Work mode',
                  title: 'Nomad-ready features',
                  child: _NomadFeatureWrap(hotel: hotel),
                ),
                SizedBox(height: 16.h),
                _SectionShell(
                  eyebrow: 'Daily comfort',
                  title: l10n.amenities,
                  child: _AmenityGrid(hotel: hotel),
                ),
                if (hotel.roomTypes.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  _SectionShell(
                    eyebrow: 'Room mix',
                    title: 'Stay options on deck',
                    child: Column(
                      children: hotel.roomTypes.map((roomType) => _RoomTypeCard(roomType: roomType)).toList(),
                    ),
                  ),
                ],
                if (hotel.phone != null || hotel.email != null || hotel.website != null) ...[
                  SizedBox(height: 16.h),
                  _SectionShell(
                    eyebrow: 'Reach out',
                    title: l10n.contact,
                    child: _ContactBoard(hotel: hotel),
                  ),
                ],
                SizedBox(height: 96.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchExternalUrl(String rawUrl) async {
    final normalizedUrl = rawUrl.startsWith('http://') || rawUrl.startsWith('https://') ? rawUrl : 'https://$rawUrl';
    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) {
      return;
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _HotelHero extends StatelessWidget {
  const _HotelHero({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hotel.images.isNotEmpty)
          PageView.builder(
            itemCount: hotel.images.length,
            itemBuilder: (context, index) {
              return Image.network(
                hotel.images[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF262B33),
                  child: Icon(FontAwesomeIcons.hotel, size: 58.r, color: Colors.white30),
                ),
              );
            },
          )
        else
          Container(
            color: const Color(0xFF262B33),
            child: Icon(FontAwesomeIcons.hotel, size: 58.r, color: Colors.white30),
          ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.18),
                Colors.black.withValues(alpha: 0.24),
                const Color(0xFF0F141A).withValues(alpha: 0.92),
              ],
            ),
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          bottom: 94.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [
                  _HeroPill(
                    icon: hotel.isBookingHotel ? FontAwesomeIcons.globe : FontAwesomeIcons.userGroup,
                    label: hotel.sourceLabel,
                  ),
                  if (hotel.isFeatured)
                    const _HeroPill(
                      icon: FontAwesomeIcons.solidStar,
                      label: 'Featured stay',
                    ),
                  if (hotel.starRating != null)
                    _HeroPill(
                      icon: FontAwesomeIcons.star,
                      label: '${hotel.starRating}-star',
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                hotel.name,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(FontAwesomeIcons.locationDot, size: 13.r, color: Colors.white70),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${hotel.cityName}${hotel.country != null ? ', ${hotel.country}' : ''}',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StayProfileCard extends StatelessWidget {
  const _StayProfileCard({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F2E8), Color(0xFFF1E6D8)],
        ),
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF201A14).withValues(alpha: 0.08),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay profile',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: const Color(0xFF8E5A33),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      hotel.category.isEmpty ? 'Flexible city stay' : hotel.category,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F1A17),
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      hotel.address,
                      style: TextStyle(
                        fontSize: 13.sp,
                        height: 1.5,
                        color: const Color(0xFF635449),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF17191D),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${hotel.currency} ${hotel.pricePerNight.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'per night',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Row(
            children: [
              Expanded(
                child: _ProfileMetric(
                  label: 'Rating',
                  value: hotel.rating > 0 ? hotel.rating.toStringAsFixed(1) : 'N/A',
                  hint: '${hotel.reviewCount} reviews',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ProfileMetric(
                  label: 'Nomad fit',
                  value:
                      hotel.nomadScore > 0 ? hotel.nomadScore.toString() : (hotel.isNomadFriendly ? 'Ready' : 'Basic'),
                  hint: hotel.hasGoodWifi ? 'Fast enough for remote work' : 'Verify setup before booking',
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ProfileMetric(
                  label: 'Inventory',
                  value: hotel.hasRooms ? '${hotel.availableRoomCount}' : 'N/A',
                  hint: hotel.hasRooms ? 'room types available' : 'availability not listed',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF8E5A33),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F1A17),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            hint,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.35,
              color: const Color(0xFF635449),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalBoard extends StatelessWidget {
  const _SignalBoard({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final signalCards = [
      _SignalCardData(
        label: 'Connection',
        value: hotel.hasWifi ? '${hotel.wifiSpeed ?? '--'} Mbps' : 'Unknown',
        detail: hotel.hasWifi ? 'WiFi confirmed on listing' : 'Ask host before booking',
        icon: FontAwesomeIcons.wifi,
        accent: const Color(0xFF2D6A8B),
      ),
      _SignalCardData(
        label: 'Workspace',
        value: hotel.hasCoworkingSpace ? 'Coworking' : (hotel.hasWorkDesk ? 'Desk ready' : 'Room only'),
        detail: hotel.hasCoworkingSpace ? 'Shared work zone available' : 'Best for focused solo sessions',
        icon: FontAwesomeIcons.laptop,
        accent: const Color(0xFF89552A),
      ),
      _SignalCardData(
        label: 'Stay leverage',
        value: hotel.hasLongStayDiscount
            ? '${hotel.longStayDiscountPercent?.toStringAsFixed(0) ?? '--'}% off'
            : 'Standard',
        detail: hotel.hasLongStayDiscount ? 'Long-stay pricing is listed' : 'No long-stay incentive shown',
        icon: FontAwesomeIcons.percent,
        accent: const Color(0xFF3B7A57),
      ),
      _SignalCardData(
        label: 'Trust layer',
        value: hotel.isPopular ? 'Popular' : hotel.sourceLabel,
        detail: hotel.reviewCount > 0 ? '${hotel.reviewCount} reviews in feed' : 'Fresh listing with light proof',
        icon: FontAwesomeIcons.shieldHalved,
        accent: const Color(0xFF7A3648),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: signalCards
              .map(
                (signal) => SizedBox(
                  width: cardWidth,
                  child: _SignalCard(signal: signal),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _SignalCardData {
  const _SignalCardData({
    required this.label,
    required this.value,
    required this.detail,
    required this.icon,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final IconData icon;
  final Color accent;
}

class _SignalCard extends StatelessWidget {
  const _SignalCard({required this.signal});

  final _SignalCardData signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: signal.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: signal.accent.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: signal.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(signal.icon, size: 16.r, color: signal.accent),
          ),
          SizedBox(height: 14.h),
          Text(
            signal.label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: signal.accent,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            signal.value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C232C),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            signal.detail,
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.45,
              color: const Color(0xFF51606B),
            ),
          ),
        ],
      ),
    );
  }
}

class _NomadFeatureWrap extends StatelessWidget {
  const _NomadFeatureWrap({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final features = <({IconData icon, String label, Color accent})>[];

    if (hotel.hasWifi) {
      features.add((
        icon: FontAwesomeIcons.wifi,
        label: hotel.wifiSpeed != null ? 'WiFi ${hotel.wifiSpeed} Mbps' : 'WiFi available',
        accent: const Color(0xFF2D6A8B),
      ));
    }
    if (hotel.hasWorkDesk) {
      features.add((
        icon: FontAwesomeIcons.desktop,
        label: 'In-room work desk',
        accent: const Color(0xFF89552A),
      ));
    }
    if (hotel.hasCoworkingSpace) {
      features.add((
        icon: FontAwesomeIcons.users,
        label: 'Coworking on-site',
        accent: const Color(0xFF3B7A57),
      ));
    }
    if (hotel.hasLongStayDiscount) {
      features.add((
        icon: FontAwesomeIcons.percent,
        label: 'Long-stay pricing',
        accent: const Color(0xFF7A3648),
      ));
    }
    if (hotel.hasKitchen) {
      features.add((
        icon: FontAwesomeIcons.kitchenSet,
        label: 'Kitchen access',
        accent: const Color(0xFF6A5D2D),
      ));
    }
    if (hotel.hasLaundry) {
      features.add((
        icon: FontAwesomeIcons.shirt,
        label: 'Laundry support',
        accent: const Color(0xFF5A4D8A),
      ));
    }

    if (features.isEmpty) {
      return Text(
        'This listing does not include a clear remote-work setup yet.',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF51606B)),
      );
    }

    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: features
          .map(
            (feature) => Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: feature.accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(feature.icon, size: 14.r, color: feature.accent),
                  SizedBox(width: 8.w),
                  Text(
                    feature.label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: feature.accent,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AmenityGrid extends StatelessWidget {
  const _AmenityGrid({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    if (hotel.amenities.isEmpty) {
      return Text(
        'No amenities are listed for this stay yet.',
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF51606B)),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = (constraints.maxWidth - 12.w) / 2;
        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: hotel.amenities
              .map(
                (amenity) => SizedBox(
                  width: width,
                  child: Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F0E7),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34.w,
                          height: 34.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            _amenityIconFor(amenity),
                            size: 15.r,
                            color: const Color(0xFF7A5531),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            amenity,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF352A21),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  IconData _amenityIconFor(String amenity) {
    final normalized = amenity.toLowerCase();
    if (normalized.contains('wifi')) return FontAwesomeIcons.wifi;
    if (normalized.contains('air')) return FontAwesomeIcons.snowflake;
    if (normalized.contains('kitchen')) return FontAwesomeIcons.kitchenSet;
    if (normalized.contains('laundry')) return FontAwesomeIcons.shirt;
    if (normalized.contains('parking')) return FontAwesomeIcons.squareParking;
    if (normalized.contains('pool')) return FontAwesomeIcons.personSwimming;
    if (normalized.contains('gym')) return FontAwesomeIcons.dumbbell;
    if (normalized.contains('pet')) return FontAwesomeIcons.paw;
    if (normalized.contains('desk')) return FontAwesomeIcons.desktop;
    if (normalized.contains('cowork')) return FontAwesomeIcons.users;
    if (normalized.contains('reception')) return FontAwesomeIcons.clock;
    return FontAwesomeIcons.check;
  }
}

class _RoomTypeCard extends StatelessWidget {
  const _RoomTypeCard({required this.roomType});

  final RoomType roomType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE9E2D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      roomType.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C232C),
                      ),
                    ),
                    if (roomType.description.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Text(
                        roomType.description,
                        style: TextStyle(
                          fontSize: 12.sp,
                          height: 1.45,
                          color: const Color(0xFF51606B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                '${roomType.currency} ${roomType.pricePerNight.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF89552A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _MiniFact(label: '${roomType.maxOccupancy} guests'),
              _MiniFact(label: '${roomType.size.toStringAsFixed(0)} sqm'),
              _MiniFact(label: roomType.bedType),
              _MiniFact(label: roomType.hasAvailableRooms ? '${roomType.availableRooms} left' : 'Sold out'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniFact extends StatelessWidget {
  const _MiniFact({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF4F5B67),
        ),
      ),
    );
  }
}

class _ContactBoard extends StatelessWidget {
  const _ContactBoard({required this.hotel});

  final Hotel hotel;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    if (hotel.phone != null && hotel.phone!.isNotEmpty) {
      rows.add(_ContactRow(icon: FontAwesomeIcons.phone, label: 'Phone', value: hotel.phone!));
    }
    if (hotel.email != null && hotel.email!.isNotEmpty) {
      rows.add(_ContactRow(icon: FontAwesomeIcons.envelope, label: 'Email', value: hotel.email!));
    }
    if (hotel.website != null && hotel.website!.isNotEmpty) {
      rows.add(_ContactRow(icon: FontAwesomeIcons.globe, label: 'Website', value: hotel.website!));
    }

    return Column(children: rows);
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F7),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E6D8),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, size: 15.r, color: const Color(0xFF7A5531)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF89552A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: const Color(0xFF1C232C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.eyebrow,
    required this.title,
    required this.child,
  });

  final String eyebrow;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: const Color(0xFFE6DDD2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: const Color(0xFF8E5A33),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 21.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C232C),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: Colors.white),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelActionBar extends StatelessWidget {
  const _HotelActionBar({
    required this.hotel,
    required this.onOpenMap,
    required this.onOpenWebsite,
  });

  final Hotel hotel;
  final VoidCallback onOpenMap;
  final VoidCallback? onOpenWebsite;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 22.r,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onOpenMap,
                icon: const Icon(FontAwesomeIcons.diamondTurnRight),
                label: Text(l10n.directions),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF1C232C),
                  side: const BorderSide(color: Color(0xFFD8CABB)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FilledButton.icon(
                onPressed: onOpenWebsite,
                icon: const Icon(FontAwesomeIcons.globe),
                label: Text(onOpenWebsite == null ? 'Website unavailable' : l10n.visitWebsite),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF17191D),
                  disabledBackgroundColor: const Color(0xFFB7B0A7),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
