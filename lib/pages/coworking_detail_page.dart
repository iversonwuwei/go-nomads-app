import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/coworking/domain/entities/coworking_space.dart';
import '../generated/app_localizations.dart';
import 'osm_navigation_page.dart';

/// Coworking Detail Page
/// 共享办公空间详情页面
class CoworkingDetailPage extends StatefulWidget {
  final CoworkingSpace space;

  const CoworkingDetailPage({
    super.key,
    required this.space,
  });

  @override
  State<CoworkingDetailPage> createState() => _CoworkingDetailPageState();
}

class _CoworkingDetailPageState extends State<CoworkingDetailPage> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // 获取所有图片列表
  List<String> get _allImages {
    final images = <String>[];
    images.add(widget.space.spaceInfo.imageUrl);
    images.addAll(widget.space.spaceInfo.images);
    return images;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allImages = _allImages;
    final hasMultipleImages = allImages.length > 1;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.space.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // 图片轮播
                  hasMultipleImages
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentImageIndex = index;
                            });
                          },
                          itemCount: allImages.length,
                          itemBuilder: (context, index) {
                            return Image.network(
                              allImages[index],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.business, size: 100),
                                );
                              },
                            );
                          },
                        )
                      : Image.network(
                          widget.space.spaceInfo.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.business, size: 100),
                            );
                          },
                        ),
                  // 渐变遮罩 (忽略手势，避免阻挡图片滑动)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(128),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 图片指示器
                  if (hasMultipleImages)
                    Positioned(
                      bottom: 80,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          allImages.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withAlpha(128),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // 图片计数器
                  if (hasMultipleImages)
                    Positioned(
                      top: 100,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${allImages.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rating & Verified Badge
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                size: 18, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              widget.space.spaceInfo.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ' (${widget.space.spaceInfo.reviewCount} ${l10n.reviews})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Verified Badge
                      if (widget.space.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified,
                                  size: 18, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                l10n.verified,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Last Updated Badge
                      if (widget.space.lastUpdated != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.update,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                'Updated ${_formatDate(widget.space.lastUpdated!)}',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const Divider(),

                // Address
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(widget.space.location.address),
                  subtitle: Text(
                      '${widget.space.location.city}, ${widget.space.location.country}'),
                ),

                const Divider(),

                // Description
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.about,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.space.spaceInfo.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // Pricing
                _buildPricingSection(context),

                const Divider(),

                // Specs
                _buildSpecsSection(context),

                const Divider(),

                // Amenities
                _buildAmenitiesSection(context),

                const Divider(),

                // Opening Hours
                if (widget.space.operationHours.hasHours)
                  _buildOpeningHoursSection(context),

                if (widget.space.operationHours.hasHours) const Divider(),

                // Contact
                _buildContactSection(context),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),

      // Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.directions),
                label: Text(l10n.directions),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // 跳转到 OSM Navigation 页面进行导航
                  Get.to(() => OSMNavigationPage(coworkingSpace: widget.space));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.language),
                label: Text(l10n.visitWebsite),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: widget.space.contactInfo.hasWebsite
                    ? () => _launchURL(widget.space.contactInfo.website)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 价格区域
  Widget _buildPricingSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.pricing,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.space.pricing.hourlyRate != null)
                Expanded(
                  child: _buildPriceCard(
                    l10n.hourly,
                    widget.space.pricing.hourlyRate!,
                    widget.space.pricing.currency,
                    Icons.access_time,
                  ),
                ),
              if (widget.space.pricing.dailyRate != null) ...[
                if (widget.space.pricing.hourlyRate != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: _buildPriceCard(
                    l10n.daily,
                    widget.space.pricing.dailyRate!,
                    widget.space.pricing.currency,
                    Icons.today,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.space.pricing.weeklyRate != null)
                Expanded(
                  child: _buildPriceCard(
                    l10n.weekly,
                    widget.space.pricing.weeklyRate!,
                    widget.space.pricing.currency,
                    Icons.date_range,
                  ),
                ),
              if (widget.space.pricing.monthlyRate != null) ...[
                if (widget.space.pricing.weeklyRate != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: _buildPriceCard(
                    l10n.monthly,
                    widget.space.pricing.monthlyRate!,
                    widget.space.pricing.currency,
                    Icons.calendar_month,
                  ),
                ),
              ],
            ],
          ),
          if (widget.space.pricing.hasFreeTrial) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.green[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${l10n.freeTrialAvailable} ${widget.space.pricing.trialDuration ?? ''}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceCard(
      String label, double price, String currency, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$currency ${price.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 规格区域
  Widget _buildSpecsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.specifications,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSpecCard(
                  l10n.wifiSpeed,
                  '${widget.space.specs.wifiSpeed?.toStringAsFixed(0) ?? 'N/A'} Mbps',
                  Icons.wifi,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecCard(
                  l10n.capacity,
                  '${widget.space.specs.capacity ?? 'N/A'} ${l10n.people}',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (widget.space.specs.numberOfDesks != null)
                Expanded(
                  child: _buildSpecCard(
                    l10n.desks,
                    '${widget.space.specs.numberOfDesks}',
                    Icons.desk,
                    Colors.orange,
                  ),
                ),
              if (widget.space.specs.numberOfMeetingRooms != null) ...[
                if (widget.space.specs.numberOfDesks != null)
                  const SizedBox(width: 8),
                Expanded(
                  child: _buildSpecCard(
                    l10n.meetingRooms,
                    '${widget.space.specs.numberOfMeetingRooms}',
                    Icons.meeting_room,
                    Colors.purple,
                  ),
                ),
              ],
            ],
          ),
          if (widget.space.specs.noiseLevel != null) ...[
            const SizedBox(height: 8),
            _buildSpecCard(
              l10n.noiseLevel,
              _getNoiseDisplayText(widget.space.specs.noiseLevel!, l10n),
              Icons.volume_down,
              Colors.red,
            ),
          ],
          // 空间类型
          if (widget.space.specs.spaceType != null) ...[
            const SizedBox(height: 8),
            _buildSpecCard(
              'Space Type',
              _getSpaceTypeDisplayText(widget.space.specs.spaceType!, l10n),
              Icons.dashboard,
              Colors.indigo,
            ),
          ],
          // 自然光
          if (widget.space.specs.hasNaturalLight) ...[
            const SizedBox(height: 8),
            _buildSpecCard(
              'Natural Light',
              'Available',
              Icons.wb_sunny,
              Colors.amber,
            ),
          ],
        ],
      ),
    );
  }

  /// 获取噪音等级显示文本
  String _getNoiseDisplayText(NoiseLevel level, AppLocalizations l10n) {
    switch (level) {
      case NoiseLevel.quiet:
        return 'Quiet';
      case NoiseLevel.moderate:
        return 'Moderate';
      case NoiseLevel.loud:
        return 'Loud';
    }
  }

  /// 获取空间类型显示文本
  String _getSpaceTypeDisplayText(SpaceType type, AppLocalizations l10n) {
    switch (type) {
      case SpaceType.open:
        return 'Open Space';
      case SpaceType.private:
        return 'Private Space';
      case SpaceType.mixed:
        return 'Mixed Space';
    }
  }

  Widget _buildSpecCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 设施区域
  Widget _buildAmenitiesSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final amenities = widget.space.amenities.getAvailableAmenities();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.amenities,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.map((amenity) {
              IconData icon = Icons.check_circle;
              Color color = Colors.green;

              // 为不同设施设置不同图标
              if (amenity.contains('WiFi')) {
                icon = Icons.wifi;
                color = Colors.blue;
              } else if (amenity.contains('Coffee')) {
                icon = Icons.coffee;
                color = Colors.brown;
              } else if (amenity.contains('Printer')) {
                icon = Icons.print;
                color = Colors.grey;
              } else if (amenity.contains('Meeting')) {
                icon = Icons.meeting_room;
                color = Colors.purple;
              } else if (amenity.contains('Phone')) {
                icon = Icons.phone;
                color = Colors.orange;
              } else if (amenity.contains('Kitchen')) {
                icon = Icons.kitchen;
                color = Colors.red;
              } else if (amenity.contains('Parking')) {
                icon = Icons.local_parking;
                color = Colors.indigo;
              } else if (amenity.contains('24/7')) {
                icon = Icons.access_time;
                color = Colors.deepOrange;
              } else if (amenity.contains('A/C') || amenity.contains('Air')) {
                icon = Icons.ac_unit;
                color = Colors.cyan;
              } else if (amenity.contains('Shower')) {
                icon = Icons.shower;
                color = Colors.lightBlue;
              } else if (amenity.contains('Standing Desk')) {
                icon = Icons.desk;
                color = Colors.teal;
              } else if (amenity.contains('Locker')) {
                icon = Icons.lock;
                color = Colors.blueGrey;
              } else if (amenity.contains('Bike')) {
                icon = Icons.directions_bike;
                color = Colors.lightGreen;
              } else if (amenity.contains('Event')) {
                icon = Icons.event;
                color = Colors.deepPurple;
              } else if (amenity.contains('Pet')) {
                icon = Icons.pets;
                color = Colors.pink;
              }

              return Chip(
                avatar: Icon(icon, size: 18, color: color),
                label: Text(amenity),
                backgroundColor: color.withAlpha(26),
                side: BorderSide(color: color.withAlpha(77)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 营业时间区域
  Widget _buildOpeningHoursSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.openingHours,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.space.operationHours.hours.map((hours) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      hours,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  /// 联系方式区域
  Widget _buildContactSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.contactInfo,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.space.contactInfo.phone.isNotEmpty)
            InkWell(
              onTap: () =>
                  _makePhoneCall(context, widget.space.contactInfo.phone),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.space.contactInfo.phone,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.call,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.call,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (widget.space.contactInfo.phone.isNotEmpty &&
              widget.space.contactInfo.email.isNotEmpty)
            const SizedBox(height: 12),
          if (widget.space.contactInfo.email.isNotEmpty)
            InkWell(
              onTap: () =>
                  _launchURL('mailto:${widget.space.contactInfo.email}'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.space.contactInfo.email,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          if ((widget.space.contactInfo.phone.isNotEmpty ||
                  widget.space.contactInfo.email.isNotEmpty) &&
              widget.space.contactInfo.hasWebsite)
            const SizedBox(height: 12),
          if (widget.space.contactInfo.hasWebsite)
            InkWell(
              onTap: () => _launchURL(widget.space.contactInfo.website),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[100]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.language,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.website,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.space.contactInfo.website,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 拨打电话
  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse('tel:$phoneNumber');

    try {
      // 在模拟器上，即使不能真正拨打，也尝试打开拨号界面
      final canLaunch = await canLaunchUrl(uri);

      if (canLaunch) {
        // 使用 LaunchMode.externalApplication 确保在外部应用中打开
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // 在模拟器上可能会失败，提供更友好的提示
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.cannotMakeCall,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '💡 提示：在真机上可以正常拨打',
                    style: TextStyle(fontSize: 11),
                  ),
                ],
              ),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: '复制',
                textColor: Colors.white,
                onPressed: () {
                  // 这里可以添加复制到剪贴板的功能
                },
              ),
            ),
          );
        }
      }
    } catch (e) {
      // 捕获异常并显示错误信息
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.error}: ${e.toString()}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 启动URL
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }
}
