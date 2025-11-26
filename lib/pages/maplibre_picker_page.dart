import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:maplibre_gl/maplibre_gl.dart';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';

class MapLibrePickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? searchQuery;

  const MapLibrePickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.searchQuery,
  });

  @override
  State<MapLibrePickerPage> createState() => _MapLibrePickerPageState();
}

class _MapLibrePickerPageState extends State<MapLibrePickerPage> {
  static const _styleUrl = 'https://demotiles.maplibre.org/style.json';
  static const _defaultTarget =
      LatLng(39.909187, 116.397451); // Beijing fallback
  static const _userAgent = 'df-admin-mobile/1.0 (map picker)';

  MapLibreMapController? _mapController;
  late CameraPosition _cameraPosition;

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  bool _isReverseGeocoding = false;
  bool _isSearching = false;
  bool _cameraMovedByUser = false;

  String? _currentAddress;
  String? _currentCity;
  String? _currentProvince;
  String? _currentName;

  List<_SearchResult> _searchResults = const [];

  @override
  void initState() {
    super.initState();

    final lat = widget.initialLatitude ?? _defaultTarget.latitude;
    final lng = widget.initialLongitude ?? _defaultTarget.longitude;
    final zoom = widget.initialLatitude != null ? 15.5 : 4.5;

    _cameraPosition = CameraPosition(
      target: LatLng(lat, lng),
      zoom: zoom,
    );

    if ((widget.searchQuery ?? '').trim().isNotEmpty) {
      final query = widget.searchQuery!.trim();
      _searchController.text = query;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchPlaces(query, autoSelectFirst: true);
      });
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onMapCreated(MapLibreMapController controller) async {
    _mapController = controller;
    await _reverseGeocode(_cameraPosition.target);
  }

  void _onCameraMove(CameraPosition position) {
    _cameraPosition = position;
    _cameraMovedByUser = true;
  }

  void _onCameraIdle() {
    if (!_cameraMovedByUser) return;
    _cameraMovedByUser = false;
    _reverseGeocode(_cameraPosition.target);
  }

  Future<void> _reverseGeocode(LatLng target) async {
    if (!mounted) return;

    setState(() {
      _isReverseGeocoding = true;
    });

    final locale = Localizations.maybeLocaleOf(context);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
        'format': 'jsonv2',
        'lat': target.latitude.toString(),
        'lon': target.longitude.toString(),
        'zoom': '18',
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          if (locale != null) 'Accept-Language': locale.languageCode,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Reverse geocoding failed (${response.statusCode})');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>?;

      setState(() {
        _currentAddress = data['display_name'] as String? ?? '';
        _currentName = (data['name'] as String?) ??
            (address?['amenity'] as String?) ??
            _currentAddress;
        final cityCandidate =
            (address?['city'] ?? address?['town'] ?? address?['state'])
                ?.toString();
        final provinceCandidate =
            (address?['state'] ?? address?['region'] ?? address?['country'])
                ?.toString();
        _currentCity = cityCandidate?.isNotEmpty == true ? cityCandidate : null;
        _currentProvince =
            provinceCandidate?.isNotEmpty == true ? provinceCandidate : null;
      });
    } catch (e) {
      if (!mounted) return;
      AppToast.warning(
        e.toString(),
        title: AppLocalizations.of(context)?.notice,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isReverseGeocoding = false;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _searchPlaces(value);
    });
  }

  Future<void> _searchPlaces(String rawQuery,
      {bool autoSelectFirst = false}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      setState(() => _searchResults = const []);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final locale = Localizations.maybeLocaleOf(context);

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'format': 'jsonv2',
        'limit': '8',
        'q': query,
        'addressdetails': '1',
      });

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': _userAgent,
          if (locale != null) 'Accept-Language': locale.languageCode,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Search failed (${response.statusCode})');
      }

      final list = (jsonDecode(response.body) as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(_SearchResult.fromJson)
          .toList();

      if (!mounted) return;

      setState(() {
        _searchResults = list;
      });

      if (autoSelectFirst && list.isNotEmpty) {
        _moveCameraTo(list.first.location);
      }
    } catch (e) {
      if (!mounted) return;
      AppToast.error(
        e.toString(),
        title: AppLocalizations.of(context)?.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _moveCameraTo(LatLng target) async {
    setState(() {
      _searchResults = const [];
    });
    await _mapController
        ?.animateCamera(CameraUpdate.newLatLngZoom(target, 15.5));
    await _reverseGeocode(target);
  }

  void _confirmSelection() {
    final latitude = _cameraPosition.target.latitude;
    final longitude = _cameraPosition.target.longitude;

    Get.back(result: {
      'latitude': latitude,
      'longitude': longitude,
      'address': _currentAddress ?? '',
      'name': _currentName ?? '',
      'city': _currentCity ?? '',
      'province': _currentProvince ?? '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final canConfirm =
        (_currentAddress ?? '').isNotEmpty && !_isReverseGeocoding;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft,
              color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.selectLocation,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.searchCityOrCountry,
                prefixIcon: const Icon(FontAwesomeIcons.magnifyingGlass),
                suffixIcon: _isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : (_searchController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(FontAwesomeIcons.xmark),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchResults = const []);
                            },
                          )),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (value) =>
                  _searchPlaces(value, autoSelectFirst: true),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                MapLibreMap(
                  styleString: _styleUrl,
                  initialCameraPosition: _cameraPosition,
                  compassEnabled: true,
                  myLocationEnabled: false,
                  trackCameraPosition: true,
                  onMapCreated: _onMapCreated,
                  onCameraMove: _onCameraMove,
                  onCameraIdle: _onCameraIdle,
                ),
                const IgnorePointer(
                  child: Center(
                    child: Icon(
                      FontAwesomeIcons.locationDot,
                      size: 50,
                      color: Color(0xFFFF4458),
                    ),
                  ),
                ),
                if (_searchResults.isNotEmpty)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 90,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final result = _searchResults[index];
                            return ListTile(
                              dense: true,
                              title: Text(
                                result.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                result.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _moveCameraTo(result.location),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.selectedLocation,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_isReverseGeocoding)
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.loading),
                                  ],
                                )
                              else
                                Text(
                                  (_currentAddress ?? '').isNotEmpty
                                      ? _currentAddress!
                                      : l10n.pickLocationOnMap,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              if ((_currentCity ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    [
                                      if ((_currentCity ?? '').isNotEmpty)
                                        _currentCity,
                                      if ((_currentProvince ?? '').isNotEmpty)
                                        _currentProvince,
                                    ].join(' · '),
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: canConfirm ? _confirmSelection : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: const Color(0xFFFF4458),
                              disabledBackgroundColor: Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              l10n.confirm,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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

class _SearchResult {
  final LatLng location;
  final String title;
  final String subtitle;

  const _SearchResult({
    required this.location,
    required this.title,
    required this.subtitle,
  });

  factory _SearchResult.fromJson(Map<String, dynamic> json) {
    final lat = double.tryParse(json['lat']?.toString() ?? '') ?? 0;
    final lon = double.tryParse(json['lon']?.toString() ?? '') ?? 0;
    final address = json['display_name'] as String? ?? '';
    final structured = json['address'] as Map<String, dynamic>?;

    final String title = (json['name'] as String?) ??
        (structured?['road'] as String?) ??
        address;
    final subtitle = structured != null
        ? [
            structured['city'] ?? structured['town'] ?? structured['state'],
            structured['country']
          ].whereType<String>().where((value) => value.isNotEmpty).join(' · ')
        : address;

    return _SearchResult(
      location: LatLng(lat, lon),
      title: title,
      subtitle: subtitle.isNotEmpty ? subtitle : address,
    );
  }
}
