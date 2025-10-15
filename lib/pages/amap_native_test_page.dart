import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../services/amap_native_service.dart';
import '../widgets/app_toast.dart';
import 'amap_native_picker_page.dart';

/// 高德原生地图测试页面
///
/// 用于测试 Platform Channel 连接和地图选择功能
class AmapNativeTestPage extends StatefulWidget {
  const AmapNativeTestPage({super.key});

  @override
  State<AmapNativeTestPage> createState() => _AmapNativeTestPageState();
}

class _AmapNativeTestPageState extends State<AmapNativeTestPage> {
  String _testResult = '';
  bool _isLoading = false;
  Map<String, dynamic>? _selectedLocation;

  Future<void> _testConnection() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _isLoading = true;
      _testResult = l10n.testing;
    });

    try {
      final isConnected = await AmapNativeService.instance.testConnection();
      setState(() {
        _testResult =
            isConnected ? l10n.platformChannelConnected : l10n.connectionFailed;
      });
    } catch (e) {
      setState(() {
        _testResult = '✗ ${l10n.error}: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openMapPicker() async {
    try {
      final result = await Get.to(() => const AmapNativePickerPage(
            initialLatitude: 39.909187,
            initialLongitude: 116.397451,
          ));

      if (result != null) {
        setState(() {
          _selectedLocation = result;
        });
        final l10n = AppLocalizations.of(context)!;
        AppToast.success(
          l10n.locationSelected,
          title: l10n.success,
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        '${l10n.openMapPicker}: $e',
        title: l10n.error,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AmapNativeService.instance.getCurrentLocation();
      setState(() {
        _selectedLocation = result;
      });
      final l10n = AppLocalizations.of(context)!;
      AppToast.success(
        l10n.gotCurrentLocation,
        title: l10n.success,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        '${l10n.getCurrentLocation}: $e',
        title: l10n.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined,
              color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.amapNativeTest,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Test Connection Section
          _buildSection(
            title: '1. ${l10n.testPlatformChannel}',
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          l10n.testConnection,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  _testResult.isEmpty ? l10n.notTested : _testResult,
                  style: TextStyle(
                    fontSize: 14,
                    color: _testResult.contains('✓')
                        ? Colors.green
                        : _testResult.contains('✗')
                            ? Colors.red
                            : Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Open Map Picker Section
          _buildSection(
            title: '2. ${l10n.openMapPicker}',
            child: ElevatedButton(
              onPressed: _isLoading ? null : _openMapPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                l10n.openNativeMapPicker,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Get Current Location Section
          _buildSection(
            title: '3. ${l10n.getCurrentLocation}',
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: Text(
                l10n.getCurrentLocation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Selected Location Display
          if (_selectedLocation != null) ...[
            _buildSection(
              title: l10n.selectedLocation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationInfo(
                      l10n.latitude, _selectedLocation!['latitude'].toString()),
                  _buildLocationInfo(l10n.longitude,
                      _selectedLocation!['longitude'].toString()),
                  _buildLocationInfo(
                      l10n.address, _selectedLocation!['address'] ?? 'N/A'),
                  _buildLocationInfo(
                      l10n.city, _selectedLocation!['city'] ?? 'N/A'),
                  _buildLocationInfo(
                      l10n.province, _selectedLocation!['province'] ?? 'N/A'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Instructions
          _buildSection(
            title: l10n.instructions,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.instructionStep1,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.instructionStep2,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.instructionStep3,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.instructionStep4,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.mapTilesNote,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildLocationInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
