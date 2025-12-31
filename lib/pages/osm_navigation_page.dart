import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/controllers/osm_navigation_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class OSMNavigationPage extends StatelessWidget {
  final CoworkingSpace coworkingSpace;

  const OSMNavigationPage({
    super.key,
    required this.coworkingSpace,
  });

  @override
  Widget build(BuildContext context) {
    final controller = _useController();
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          _buildMap(controller),
          _buildTopBar(context, controller),
          _buildFilterColumn(controller, l10n),
          _buildZoomButtons(controller),
          _buildBottomBar(controller, l10n),
        ],
      ),
    );
  }

  OSMNavigationPageController _useController() {
    final tag = 'OSMNavigationPage_${coworkingSpace.id}';
    return Get.put(
      OSMNavigationPageController(coworkingSpace: coworkingSpace),
      tag: tag,
    );
  }

  Widget _buildMap(OSMNavigationPageController controller) {
    return Obx(() {
      return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: controller.center,
          initialZoom: 14.0,
          minZoom: 10.0,
          maxZoom: 16.0,
          backgroundColor: Colors.grey[300]!,
        ),
        children: [
          TileLayer(
            urlTemplate: controller.currentTileUrl,
            userAgentPackageName: 'com.digitalfuture.df_admin_mobile',
            maxZoom: 18,
            minZoom: 2,
            tileProvider: NetworkTileProvider(),
          ),
          MarkerLayer(markers: _buildPOIMarkers(controller)),
          MarkerLayer(markers: _buildCoworkingMarker(controller)),
        ],
      );
    });
  }

  List<Marker> _buildCoworkingMarker(OSMNavigationPageController controller) {
    return [
      Marker(
        point: controller.center,
        width: 80,
        height: 80,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4458),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                FontAwesomeIcons.briefcase,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                coworkingSpace.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Marker> _buildPOIMarkers(OSMNavigationPageController controller) {
    final markers = <Marker>[];
    for (final poi in controller.nearbyPOIs) {
      if (!controller.shouldShowPOI(poi.type)) continue;
      markers.add(
        Marker(
          point: poi.position,
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showPOIInfo(controller, poi),
            child: Container(
              decoration: BoxDecoration(
                color: controller.getPOIColor(poi.type),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(poi.icon, color: Colors.white, size: 20),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  Widget _buildTopBar(BuildContext context, OSMNavigationPageController controller) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          right: 16,
          bottom: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: Row(
          children: [
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 2,
              child: InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: const Icon(
                    FontAwesomeIcons.arrowLeft,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        coworkingSpace.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        coworkingSpace.location.address,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterColumn(OSMNavigationPageController controller, AppLocalizations l10n) {
    return Positioned(
      top: Get.mediaQuery.padding.top + 100,
      right: 16,
      child: Obx(() {
        return Column(
          children: [
            _buildFilterButton(
              icon: FontAwesomeIcons.layerGroup,
              label: controller.currentTileName,
              isActive: false,
              onTap: () => _changeTileSource(controller),
            ),
            const SizedBox(height: 12),
            _buildFilterButton(
              icon: FontAwesomeIcons.trainSubway,
              label: l10n.transit,
              isActive: controller.showTransit.value,
              onTap: controller.toggleTransit,
            ),
            const SizedBox(height: 8),
            _buildFilterButton(
              icon: FontAwesomeIcons.hotel,
              label: l10n.accommodation,
              isActive: controller.showAccommodation.value,
              onTap: controller.toggleAccommodation,
            ),
            const SizedBox(height: 8),
            _buildFilterButton(
              icon: FontAwesomeIcons.utensils,
              label: l10n.restaurant,
              isActive: controller.showRestaurant.value,
              onTap: controller.toggleRestaurant,
            ),
          ],
        );
      }),
    );
  }

  Widget _buildZoomButtons(OSMNavigationPageController controller) {
    return Positioned(
      right: 16,
      bottom: 100,
      child: Column(
        children: [
          _buildZoomButton(
            icon: FontAwesomeIcons.plus,
            onTap: controller.zoomIn,
          ),
          const SizedBox(height: 8),
          _buildZoomButton(
            icon: FontAwesomeIcons.minus,
            onTap: controller.zoomOut,
          ),
        ],
      ),
    );
  }

  Widget _buildZoomButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: FaIcon(
              icon,
              color: const Color(0xFF1976D2),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(OSMNavigationPageController controller, AppLocalizations l10n) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: Get.mediaQuery.padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.recenter,
                icon: const Icon(FontAwesomeIcons.locationCrosshairs),
                label: Text(l10n.recenter),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFFF4458), width: 2),
                  foregroundColor: const Color(0xFFFF4458),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => _openSystemMap(controller),
                icon: const Icon(FontAwesomeIcons.compassDrafting),
                label: Text(l10n.startNavigation),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isActive ? const Color(0xFFFF4458) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : AppColors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPOIInfo(OSMNavigationPageController controller, POI poi) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final distance = controller.calculateDistance(
      controller.center,
      poi.position,
      (v) => l10n.meters(v),
      (v) => l10n.kilometers(v),
    );

    showDialog(
      context: Get.context!,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPOITop(poi, controller),
              _buildPOIBody(poi, controller, l10n, distance),
              _buildPOIFooter(poi, controller, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPOITop(POI poi, OSMNavigationPageController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            controller.getPOIColor(poi.type),
            controller.getPOIColor(poi.type).withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(poi.icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPOITypeName(poi.type, controller),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  poi.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOIBody(
    POI poi,
    OSMNavigationPageController controller,
    AppLocalizations l10n,
    String distance,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: controller.getPOIColor(poi.type).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    FontAwesomeIcons.paperPlane,
                    color: controller.getPOIColor(poi.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.distanceFrom(coworkingSpace.name),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: l10n.longitude,
                  value: poi.position.longitude.toStringAsFixed(6),
                  color: controller.getPOIColor(poi.type),
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: Colors.grey[300]),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: FontAwesomeIcons.locationDot,
                  label: l10n.latitude,
                  value: poi.position.latitude.toStringAsFixed(6),
                  color: controller.getPOIColor(poi.type),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.circleInfo, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.tapMarkersTip,
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPOIFooter(POI poi, OSMNavigationPageController controller, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(Get.context!),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                '关闭',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(Get.context!);
                controller.focusOnLocation(poi.position);
              },
              icon: const Icon(FontAwesomeIcons.locationCrosshairs, size: 20),
              label: Text(
                l10n.viewOnMap,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: controller.getPOIColor(poi.type),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  void _changeTileSource(OSMNavigationPageController controller) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: Row(
                      children: const [
                        FaIcon(FontAwesomeIcons.layerGroup, color: Color(0xFF1976D2), size: 20),
                        SizedBox(width: 12),
                        Text(
                          '选择地图瓦片源',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: controller.tileSources.entries.map((entry) {
                        final isSelected = controller.selectedTileSource.value == entry.key;
                        return ListTile(
                          leading: FaIcon(
                            FontAwesomeIcons.map,
                            color: isSelected ? const Color(0xFF1976D2) : Colors.grey.shade600,
                            size: 20,
                          ),
                          title: Text(
                            entry.value['name']!,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? const Color(0xFF1976D2) : null,
                            ),
                          ),
                          trailing: isSelected
                              ? const FaIcon(FontAwesomeIcons.circleCheck, color: Color(0xFF1976D2), size: 20)
                              : null,
                          selected: isSelected,
                          onTap: () {
                            controller.changeTileSource(entry.key);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('已切换到 ${entry.value['name']}'),
                                duration: const Duration(seconds: 2),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSystemMap(OSMNavigationPageController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final mapApps = controller.getAvailableMapApps();

    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.diamondTurnRight, color: Color(0xFFFF4458), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        l10n.selectMapApp,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: mapApps.length,
                    itemBuilder: (context, index) {
                      final app = mapApps[index];
                      return ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: app.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: FaIcon(app.icon, color: app.color, size: 22),
                          ),
                        ),
                        title: Text(
                          app.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 14, color: Colors.grey),
                        onTap: () {
                          Navigator.pop(context);
                          controller.launchMapApp(app);
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPOITypeName(POIType type, OSMNavigationPageController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    switch (type) {
      case POIType.transit:
        return l10n.transit;
      case POIType.accommodation:
        return l10n.accommodation;
      case POIType.restaurant:
        return l10n.restaurant;
    }
  }
}
