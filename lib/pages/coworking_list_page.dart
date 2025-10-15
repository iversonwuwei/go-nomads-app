import 'package:df_admin_mobile/controllers/coworking_controller.dart';
import 'package:df_admin_mobile/models/coworking_space_model.dart';
import 'package:df_admin_mobile/pages/coworking_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../generated/app_localizations.dart';

/// Coworking List Page
/// 共享办公空间列表页面
class CoworkingListPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CoworkingListPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CoworkingListPage> createState() => _CoworkingListPageState();
}

class _CoworkingListPageState extends State<CoworkingListPage> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.put(CoworkingController());
    controller.filterByCity(widget.cityName);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cityName} - ${l10n.coworkingSpaces}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter drawer
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      '${controller.filteredSpaces.length} spaces',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                Row(
                  children: [
                    // Grid/List toggle
                    IconButton(
                      icon: Icon(
                        _isGridView
                            ? Icons.view_list_outlined
                            : Icons.grid_view_outlined,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                    ),
                    // Sort
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.sort, size: 20),
                      onSelected: (value) {
                        switch (value) {
                          case 'rating':
                            controller.sortByRating();
                            break;
                          case 'price':
                            controller.sortByPrice();
                            break;
                          case 'distance':
                            controller.sortByDistance();
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return [
                          PopupMenuItem(
                            value: 'rating',
                            child: Row(
                              children: [
                                const Icon(Icons.star, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.rating),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'price',
                            child: Row(
                              children: [
                                const Icon(Icons.attach_money, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.price),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'distance',
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, size: 20),
                                const SizedBox(width: 8),
                                Text(l10n.distance),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildFilterChips(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredSpaces.isEmpty) {
                return Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noData,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => controller.clearFilters(),
                            child: Text(l10n.reset),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredSpaces.length,
                itemBuilder: (context, index) {
                  final space = controller.filteredSpaces[index];
                  return _buildCoworkingCard(context, space);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  /// 筛选条件
  Widget _buildFilterChips(CoworkingController controller) {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        controller,
                        'WiFi',
                        Icons.wifi,
                      ),
                      _buildFilterChip(
                        controller,
                        '24/7',
                        Icons.access_time,
                      ),
                      _buildFilterChip(
                        controller,
                        l10n.meetingRooms,
                        Icons.meeting_room,
                      ),
                      _buildFilterChip(
                        controller,
                        'Coffee',
                        Icons.coffee,
                      ),
                      if (controller.selectedFilters.isNotEmpty)
                        ActionChip(
                          avatar: const Icon(Icons.clear, size: 18),
                          label: Text(l10n.reset),
                          onPressed: () => controller.clearFilters(),
                        ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    CoworkingController controller,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.selectedFilters.contains(label);
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => controller.toggleFilter(label),
    );
  }

  /// 共享办公空间卡片
  Widget _buildCoworkingCard(BuildContext context, CoworkingSpace space) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CoworkingDetailPage(space: space),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    space.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.business, size: 50),
                      );
                    },
                  ),
                ),
                if (space.isVerified)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                size: 14,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                l10n.verified,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),

            // 信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和评分
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          space.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            space.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${space.reviewCount})',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // 地址
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          space.address,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 关键信息
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.wifi,
                        '${space.specs.wifiSpeed?.toStringAsFixed(0) ?? '0'} Mbps',
                        Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      if (space.pricing.monthlyRate != null)
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return _buildInfoChip(
                              Icons.attach_money,
                              '${space.pricing.monthlyRate!.toStringAsFixed(0)}/${l10n.monthlyRate}',
                              Colors.green,
                            );
                          },
                        ),
                      const SizedBox(width: 8),
                      if (space.amenities.has24HourAccess)
                        _buildInfoChip(
                          Icons.access_time,
                          '24/7',
                          Colors.orange,
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 设施
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: space.amenities
                        .getAvailableAmenities()
                        .take(4)
                        .map((amenity) => Chip(
                              label: Text(
                                amenity,
                                style: const TextStyle(fontSize: 11),
                              ),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),

                  if (space.pricing.hasFreeTrial) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_offer,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            'Free ${space.pricing.trialDuration} trial available',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
