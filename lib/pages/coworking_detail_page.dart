import 'package:df_admin_mobile/models/coworking_space_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/app_localizations.dart';
import 'global_map_page.dart';

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
                    space.imageUrl,
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
                              space.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              ' (${space.reviewCount} ${l10n.reviews})',
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
                  title: Text(space.address),
                  subtitle: Text('${space.city}, ${space.country}'),
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
                        space.description,
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
                if (space.openingHours.isNotEmpty)
                  _buildOpeningHoursSection(context),

                if (space.openingHours.isNotEmpty) const Divider(),

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
                  // 跳转到 Global Map 页面进行导航
                  Get.to(() => const GlobalMapPage());
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
                onPressed: space.website.isNotEmpty
                    ? () => _launchURL(space.website)
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
              space.specs.noiseLevel!,
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
          ...space.openingHours.map((hours) => Padding(
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
          if (space.phone.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.blue),
              title: Text(space.phone),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _launchURL('tel:${space.phone}'),
            ),
          if (space.email.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.email, color: Colors.red),
              title: Text(space.email),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _launchURL('mailto:${space.email}'),
            ),
          if (space.website.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.language, color: Colors.green),
              title: Text(space.website),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _launchURL(space.website),
            ),
        ],
      ),
    );
  }

  /// 启动URL
  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

