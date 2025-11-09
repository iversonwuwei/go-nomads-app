import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../features/coworking/domain/entities/coworking_space.dart';
import '../generated/app_localizations.dart';
import 'osm_navigation_page.dart';

/// Coworking Detail Page
/// 共享办公空间详情页面
class CoworkingDetailPage extends StatelessWidget {
  final CoworkingSpace space;

  const CoworkingDetailPage({
    super.key,
    required this.space,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar with Image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                space.name,
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
                  Image.network(
                    space.spaceInfo.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.business, size: 100),
                      );
                    },
                  ),
                  Container(
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
                  child: Row(
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
                              space.spaceInfo.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ' (${space.spaceInfo.reviewCount} ${l10n.reviews})',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Verified Badge
                      if (space.isVerified)
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
                    ],
                  ),
                ),

                const Divider(),

                // Address
                ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.red),
                  title: Text(space.location.address),
                  subtitle:
                      Text('${space.location.city}, ${space.location.country}'),
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
                        space.spaceInfo.description,
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
                if (space.operationHours.hasHours)
                  _buildOpeningHoursSection(context),

                if (space.operationHours.hasHours) const Divider(),

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
                  Get.to(() => OSMNavigationPage(coworkingSpace: space));
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
                onPressed: space.contactInfo.hasWebsite
                    ? () => _launchURL(space.contactInfo.website)
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
              if (space.pricing.hourlyRate != null)
                Expanded(
                  child: _buildPriceCard(
                    l10n.hourly,
                    space.pricing.hourlyRate!,
                    space.pricing.currency,
                    Icons.access_time,
                  ),
                ),
              if (space.pricing.dailyRate != null) ...[
                if (space.pricing.hourlyRate != null) const SizedBox(width: 8),
                Expanded(
                  child: _buildPriceCard(
                    l10n.daily,
                    space.pricing.dailyRate!,
                    space.pricing.currency,
                    Icons.today,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (space.pricing.weeklyRate != null)
                Expanded(
                  child: _buildPriceCard(
                    l10n.weekly,
                    space.pricing.weeklyRate!,
                    space.pricing.currency,
                    Icons.date_range,
                  ),
                ),
              if (space.pricing.monthlyRate != null) ...[
                if (space.pricing.weeklyRate != null) const SizedBox(width: 8),
                Expanded(
                  child: _buildPriceCard(
                    l10n.monthly,
                    space.pricing.monthlyRate!,
                    space.pricing.currency,
                    Icons.calendar_month,
                  ),
                ),
              ],
            ],
          ),
          if (space.pricing.hasFreeTrial) ...[
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
                      '${l10n.freeTrialAvailable} ${space.pricing.trialDuration ?? ''}',
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
                  '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? 'N/A'} Mbps',
                  Icons.wifi,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSpecCard(
                  l10n.capacity,
                  '${space.specs.capacity ?? 'N/A'} ${l10n.people}',
                  Icons.people,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (space.specs.numberOfDesks != null)
                Expanded(
                  child: _buildSpecCard(
                    l10n.desks,
                    '${space.specs.numberOfDesks}',
                    Icons.desk,
                    Colors.orange,
                  ),
                ),
              if (space.specs.numberOfMeetingRooms != null) ...[
                if (space.specs.numberOfDesks != null) const SizedBox(width: 8),
                Expanded(
                  child: _buildSpecCard(
                    l10n.meetingRooms,
                    '${space.specs.numberOfMeetingRooms}',
                    Icons.meeting_room,
                    Colors.purple,
                  ),
                ),
              ],
            ],
          ),
          if (space.specs.noiseLevel != null) ...[
            const SizedBox(height: 8),
            _buildSpecCard(
              l10n.noiseLevel,
              space.specs.noiseLevel!.toString(),
              Icons.volume_down,
              Colors.red,
            ),
          ],
        ],
      ),
    );
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
    final amenities = space.amenities.getAvailableAmenities();

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
          ...space.operationHours.hours.map((hours) => Padding(
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
          if (space.contactInfo.phone.isNotEmpty)
            InkWell(
              onTap: () => _makePhoneCall(context, space.contactInfo.phone),
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
                            space.contactInfo.phone,
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
          if (space.contactInfo.phone.isNotEmpty &&
              space.contactInfo.email.isNotEmpty)
            const SizedBox(height: 12),
          if (space.contactInfo.email.isNotEmpty)
            InkWell(
              onTap: () => _launchURL('mailto:${space.contactInfo.email}'),
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
                            space.contactInfo.email,
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
          if ((space.contactInfo.phone.isNotEmpty ||
                  space.contactInfo.email.isNotEmpty) &&
              space.contactInfo.hasWebsite)
            const SizedBox(height: 12),
          if (space.contactInfo.hasWebsite)
            InkWell(
              onTap: () => _launchURL(space.contactInfo.website),
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
                            space.contactInfo.website,
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
}
