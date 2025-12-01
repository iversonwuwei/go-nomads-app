import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

/// Flutter-map implementation of the venue picker used by the meetup form.
class VenueMapPickerPage extends StatefulWidget {
  final String? cityName;

  const VenueMapPickerPage({super.key, this.cityName});

  @override
  State<VenueMapPickerPage> createState() => _VenueMapPickerPageState();
}

class _VenueMapPickerPageState extends State<VenueMapPickerPage> {
  static const _tileUrl =
      'https://webrd01.is.autonavi.com/appmaptile?lang=zh_cn&size=1&scale=1&style=8&x={x}&y={y}&z={z}';

  final List<Map<String, dynamic>> _allVenues = [
    {
      'name': 'The Commons Thonglor',
      'address': '335 Thong Lo Rd, Bangkok',
      'type': 'Coworking',
      'latitude': 13.7345,
      'longitude': 100.5802,
      'rating': 4.7,
      'priceRange': '฿฿',
    },
    {
      'name': 'Rocket Coffee Bar',
      'address': '149 Sathorn Soi 12, Bangkok',
      'type': 'Restaurants',
      'latitude': 13.7213,
      'longitude': 100.5324,
      'rating': 4.5,
      'priceRange': '฿฿',
    },
    {
      'name': 'True Digital Park',
      'address': '101 Sukhumvit Rd, Bangkok',
      'type': 'Coworking',
      'latitude': 13.6891,
      'longitude': 100.6090,
      'rating': 4.6,
      'priceRange': 'Day pass',
    },
    {
      'name': 'The Standard Bangkok',
      'address': '88 Witthayu Rd, Bangkok',
      'type': 'Hotels',
      'latitude': 13.7432,
      'longitude': 100.5497,
      'rating': 4.8,
      'priceRange': '฿฿฿',
    },
    {
      'name': 'Grows Coworking',
      'address': '53 Ratchaprarop Rd, Bangkok',
      'type': 'Coworking',
      'latitude': 13.7511,
      'longitude': 100.5408,
      'rating': 4.4,
      'priceRange': '฿฿',
    },
    {
      'name': 'The Yard Hostel Café',
      'address': '51 Soi Ari 4, Bangkok',
      'type': 'Restaurants',
      'latitude': 13.7802,
      'longitude': 100.5468,
      'rating': 4.3,
      'priceRange': '฿฿',
    },
    {
      'name': 'Capella Bangkok',
      'address': '300 Charoenkrung Rd, Bangkok',
      'type': 'Hotels',
      'latitude': 13.7056,
      'longitude': 100.5148,
      'rating': 4.9,
      'priceRange': '฿฿฿',
    },
  ];

  final MapController _mapController = MapController();
  late LatLng _initialCenter;
  String _selectedFilter = 'All';
  String? _selectedVenueName;

  @override
  void initState() {
    super.initState();
    final first = _allVenues.first;
    _initialCenter = LatLng(
      first['latitude'] as double,
      first['longitude'] as double,
    );
  }

  List<Map<String, dynamic>> get _filteredVenues {
    if (_selectedFilter == 'All') return _allVenues;
    return _allVenues.where((v) => v['type'] == _selectedFilter).toList();
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _selectedVenueName = null;
    });
  }

  void _selectVenue(Map<String, dynamic> venue, {bool moveCamera = true}) {
    setState(() => _selectedVenueName = venue['name']);
    if (moveCamera) {
      _mapController.move(
        LatLng(venue['latitude'] as double, venue['longitude'] as double),
        15,
      );
    }
  }

  void _confirmSelection() {
    final l10n = AppLocalizations.of(context)!;
    final name = _selectedVenueName;
    if (name == null) {
      AppToast.warning(l10n.pleaseSelectVenue, title: l10n.noSelection);
      return;
    }
    final venue = _allVenues.firstWhere((v) => v['name'] == name);
    Get.back(result: {
      'name': venue['name'],
      'address': venue['address'],
      'type': venue['type'],
      'latitude': venue['latitude'],
      'longitude': venue['longitude'],
    });
  }

  Color _markerColor(String type) {
    switch (type) {
      case 'Restaurants':
        return const Color(0xFFFF6B6B);
      case 'Coworking':
        return const Color(0xFF3A86FF);
      case 'Hotels':
        return const Color(0xFF8338EC);
      default:
        return const Color(0xFFFF4458);
    }
  }

  IconData _markerIcon(String type) {
    switch (type) {
      case 'Restaurants':
        return FontAwesomeIcons.utensils;
      case 'Coworking':
        return FontAwesomeIcons.building;
      case 'Hotels':
        return FontAwesomeIcons.hotel;
      default:
        return FontAwesomeIcons.locationDot;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.backButtonDark),
        title: Text(
          l10n.selectVenue,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text(
              l10n.confirm,
              style: const TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChips(l10n),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMap(l10n),
            ),
          ),
          Expanded(child: _buildVenueList(l10n)),
        ],
      ),
    );
  }

  Widget _buildFilterChips(AppLocalizations l10n) {
    final filters = [
      {'key': 'All', 'label': l10n.all},
      {'key': 'Restaurants', 'label': l10n.restaurants},
      {'key': 'Coworking', 'label': 'Coworking'},
      {'key': 'Hotels', 'label': l10n.hotels},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _selectedFilter == filter['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter['label']!),
                selected: isSelected,
                onSelected: (_) => _onFilterChanged(filter['key']!),
                backgroundColor: Colors.white,
                selectedColor: const Color(0xFFFF4458).withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color:
                      isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMap(AppLocalizations l10n) {
    final markers = _filteredVenues.map((venue) {
      final venueLatLng = LatLng(
        venue['latitude'] as double,
        venue['longitude'] as double,
      );
      final isSelected = venue['name'] == _selectedVenueName;
      return Marker(
        width: 60,
        height: 60,
        point: venueLatLng,
        alignment: Alignment.topCenter,
        child: GestureDetector(
          onTap: () => _selectVenue(venue, moveCamera: false),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _markerIcon(venue['type'] as String),
                color: _markerColor(venue['type'] as String),
                size: isSelected ? 32 : 26,
              ),
              Icon(
                FontAwesomeIcons.locationDot,
                color: isSelected ? _markerColor(venue['type'] as String) : Colors.grey[700],
                size: isSelected ? 30 : 24,
              ),
            ],
          ),
        ),
      );
    }).toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'df_admin_mobile',
              ),
              MarkerLayer(markers: markers),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _mapBadge(
              icon: FontAwesomeIcons.city,
              text: widget.cityName ?? 'Bangkok',
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: _mapBadge(
              icon: FontAwesomeIcons.layerGroup,
              text: '${_filteredVenues.length} ${l10n.venues}',
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList(AppLocalizations l10n) {
    final venues = _filteredVenues;
    final selectedName = _selectedVenueName;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${venues.length} Venues',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: venues.length,
              itemBuilder: (context, index) {
                final venue = venues[index];
                final isSelected = selectedName == venue['name'];
                return _venueCard(venue, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _venueCard(Map<String, dynamic> venue, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF4458).withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _markerColor(venue['type'] as String).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _markerIcon(venue['type'] as String),
                color: _markerColor(venue['type'] as String),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['address'] as String,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.star,
                          size: 14, color: Colors.amber[700]),
                      const SizedBox(width: 4),
                      Text(
                        venue['rating'].toString(),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        venue['priceRange'] as String,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _markerColor(venue['type'] as String).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                venue['type'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _markerColor(venue['type'] as String),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
