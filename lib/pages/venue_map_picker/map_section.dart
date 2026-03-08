import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/controllers/venue_map_picker_page_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';
import 'package:latlong2/latlong.dart';

/// 地图区域组件
class MapSection extends StatelessWidget {
  final String controllerTag;

  const MapSection({super.key, required this.controllerTag});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VenueMapPickerPageController>(tag: controllerTag);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Obx(() => _buildMapContent(context, controller, l10n)),
      ),
    );
  }

  Widget _buildMapContent(
    BuildContext context,
    VenueMapPickerPageController controller,
    AppLocalizations l10n,
  ) {
    // 还未初始化时显示加载指示器
    if (!controller.isInitialized.value) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          color: Colors.grey[200],
          child: AppLoadingWidget(
            fullScreen: true,
            title: l10n.loading,
            subtitle: '${l10n.loading}...',
            icon: Icons.map_rounded,
            accentColor: const Color(0xFFFF4458),
          ),
        ),
      );
    }

    final venues = controller.filteredVenues;

    // POI 标记
    final markers = _buildMarkers(controller, venues);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.initialCenter,
              initialZoom: 14,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: VenueMapPickerPageController.tileUrl,
                subdomains: VenueMapPickerPageController.subdomains,
                userAgentPackageName: 'df_admin_mobile',
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 12.h,
            left: 12.w,
            child: _mapBadge(
              icon: FontAwesomeIcons.city,
              text: controller.currentCityName.value.isNotEmpty
                  ? controller.currentCityName.value
                  : controller.cityName ?? l10n.currentLocation,
            ),
          ),
          // 缩放控制按钮
          Positioned(
            top: 12.h,
            right: 12.w,
            child: Column(
              children: [
                _zoomButton(
                  icon: FontAwesomeIcons.plus,
                  onTap: () {
                    final currentZoom = controller.mapController.camera.zoom;
                    if (currentZoom < 18) {
                      controller.mapController.move(controller.mapController.camera.center, currentZoom + 1);
                    }
                  },
                ),
                SizedBox(height: 8.h),
                _zoomButton(
                  icon: FontAwesomeIcons.minus,
                  onTap: () {
                    final currentZoom = controller.mapController.camera.zoom;
                    if (currentZoom > 3) {
                      controller.mapController.move(controller.mapController.camera.center, currentZoom - 1);
                    }
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12.h,
            right: 12.w,
            child: controller.isLoadingPoi.value
                ? _mapBadge(icon: FontAwesomeIcons.spinner, text: l10n.loading)
                : _mapBadge(icon: FontAwesomeIcons.layerGroup, text: '${venues.length} ${l10n.venues}'),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(VenueMapPickerPageController controller, List<PoiResult> venues) {
    final markers = venues.map((venue) {
      final venueLatLng = LatLng(venue.latitude, venue.longitude);
      final isSelected = venue.name == controller.selectedVenueName.value;
      return Marker(
        width: 50.w,
        height: 50.h,
        point: venueLatLng,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => controller.selectVenue(venue, moveCamera: false, fromMap: true),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _markerIcon(venue.type),
                color: controller.markerColor(venue.type),
                size: isSelected ? 24 : 20,
              ),
              Icon(
                FontAwesomeIcons.locationDot,
                color: isSelected ? controller.markerColor(venue.type) : Colors.grey[700],
                size: isSelected ? 24 : 20,
              ),
            ],
          ),
        ),
      );
    }).toList();

    // 用户位置标记
    if (controller.userLocation.value != null) {
      markers.add(Marker(
        width: 40.w,
        height: 40.h,
        point: controller.userLocation.value!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(FontAwesomeIcons.locationCrosshairs, color: Colors.blue, size: 20.r),
          ),
        ),
      ));
    }

    return markers;
  }

  IconData _markerIcon(String type) {
    switch (type) {
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'cafe':
        return FontAwesomeIcons.mugHot;
      case 'hotel':
        return FontAwesomeIcons.hotel;
      case 'shopping':
        return FontAwesomeIcons.bagShopping;
      case 'attraction':
        return FontAwesomeIcons.mountain;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  Widget _zoomButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: 16.r, color: Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _mapBadge({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.r, color: Colors.grey[700]),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
