import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Flutter-only MapLibre implementation of the venue picker.
class VenueMapPickerPage extends StatefulWidget {
  final String? cityName;

  const VenueMapPickerPage({
    super.key,
    this.cityName,
  });

  @override
  State<VenueMapPickerPage> createState() => _VenueMapPickerPageState();
}

class _VenueMapPickerPageState extends State<VenueMapPickerPage> {
  static const _mapStyleUrl = 'https://demotiles.maplibre.org/style.json';

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

  final Map<String, Symbol> _symbols = {};
  MapLibreMapController? _mapController;
  late final CameraPosition _initialCameraPosition;

  String _selectedFilter = 'All';
  String? _selectedVenueName;

  @override
  void initState() {
    super.initState();
    final firstVenue = _allVenues.first;
    _initialCameraPosition = CameraPosition(
      target: _venueLatLng(firstVenue),
      zoom: 12,
    );
  }

  @override
  void dispose() {
    _mapController?.onSymbolTapped.remove(_onSymbolTapped);
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredVenues {
    if (_selectedFilter == 'All') {
      return _allVenues;
    }
    return _allVenues
        .where((venue) => venue['type'] == _selectedFilter)
        .toList();
  }

  void _onFilterChanged(String filter) {
    if (_selectedFilter == filter) return;
    setState(() {
      _selectedFilter = filter;
      _selectedVenueName = null;
    });
    _refreshSymbols();
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _mapController = controller;
    controller.onSymbolTapped.add(_onSymbolTapped);
    await _refreshSymbols();
  }

  Future<void> _refreshSymbols() async {
    final controller = _mapController;
    if (controller == null) return;

    if (_symbols.isNotEmpty) {
      for (final symbol in _symbols.values) {
        await controller.removeSymbol(symbol);
      }
      _symbols.clear();
    }

    for (final venue in _filteredVenues) {
      final symbol = await controller.addSymbol(
        SymbolOptions(
          geometry: _venueLatLng(venue),
          iconImage: 'marker-15',
          iconSize: 1.1,
          iconColor: _colorToHex(_getMarkerColor(venue['type'])),
          textField: venue['name'],
          textOffset: const Offset(0, 1.8),
          textColor: '#333333',
          textSize: 11,
        ),
        {'name': venue['name']},
      );
      _symbols[venue['name']] = symbol;
    }

    if (_selectedVenueName != null) {
      await _highlightSelection();
    }
  }

  Future<void> _highlightSelection() async {
    final controller = _mapController;
    if (controller == null) return;
    for (final entry in _symbols.entries) {
      final isSelected = entry.key == _selectedVenueName;
      await controller.updateSymbol(
        entry.value,
        SymbolOptions(
          iconSize: isSelected ? 1.4 : 1.1,
          textColor: isSelected ? '#111111' : '#333333',
        ),
      );
    }
  }

  void _onSymbolTapped(Symbol symbol) {
    final name = symbol.data?['name'] as String?;
    if (name == null) return;
    Map<String, dynamic>? venue;
    for (final candidate in _allVenues) {
      if (candidate['name'] == name) {
        venue = candidate;
        break;
      }
    }
    if (venue == null) return;
    _selectVenue(venue, focusCamera: false);
  }

  Future<void> _selectVenue(Map<String, dynamic> venue,
      {bool focusCamera = true}) async {
    setState(() {
      _selectedVenueName = venue['name'];
    });
    await _highlightSelection();
    if (focusCamera) {
      _focusVenue(venue);
    }
  }

  Future<void> _focusVenue(Map<String, dynamic> venue) async {
    final controller = _mapController;
    if (controller == null) return;
    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(_venueLatLng(venue), 15),
    );
  }

  void _confirmSelection() {
    final l10n = AppLocalizations.of(context)!;
    final venueName = _selectedVenueName;

    if (venueName == null) {
      AppToast.warning(l10n.pleaseSelectVenue, title: l10n.noSelection);
      return;
    }

    final venue = _allVenues.firstWhere((v) => v['name'] == venueName);
    Get.back(result: {
      'name': venue['name'],
      'address': venue['address'],
      'type': venue['type'],
      'latitude': venue['latitude'],
      'longitude': venue['longitude'],
    });
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
          _buildFilterChips(),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMap(),
            ),
          ),
          Expanded(child: _buildVenueList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final l10n = AppLocalizations.of(context)!;
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

  Widget _buildMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          MapLibreMap(
            styleString: _mapStyleUrl,
            initialCameraPosition: _initialCameraPosition,
            myLocationEnabled: false,
            compassEnabled: true,
            onMapCreated: _onMapCreated,
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
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
                  Icon(
                    FontAwesomeIcons.city,
                    size: 16,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.cityName ?? 'Bangkok',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.layerGroup,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_filteredVenues.length} ${AppLocalizations.of(context)!.venues}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueList() {
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
                return _buildVenueCard(venue, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectVenue(venue),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFF4458).withValues(alpha: 0.05)
              : Colors.white,
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
                color: _getMarkerColor(venue['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getMarkerIcon(venue['type']),
                color: _getMarkerColor(venue['type']),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['address'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
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
                        venue['priceRange'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getMarkerColor(venue['type']).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                venue['type'],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _getMarkerColor(venue['type']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LatLng _venueLatLng(Map<String, dynamic> venue) {
    return LatLng(venue['latitude'] as double, venue['longitude'] as double);
  }

  IconData _getMarkerIcon(String type) {
    switch (type) {
      case 'Restaurants':
        return FontAwesomeIcons.utensils;
      case 'Coworking':
        return FontAwesomeIcons.building;
      case 'Hotels':
        return FontAwesomeIcons.hotel;
      default:
        return FontAwesomeIcons.locationPin;
    }
  }

  Color _getMarkerColor(String type) {
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

  String _colorToHex(Color color) {
    int asChannel(double component) =>
        (component * 255.0).round().clamp(0, 255).toInt();

    final r = asChannel(color.r).toRadixString(16).padLeft(2, '0');
    final g = asChannel(color.g).toRadixString(16).padLeft(2, '0');
    final b = asChannel(color.b).toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
