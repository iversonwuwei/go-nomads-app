import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../services/amap_native_service.dart';
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
  String _testResult = 'Not tested';
  bool _isLoading = false;
  Map<String, dynamic>? _selectedLocation;

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _testResult = 'Testing...';
    });

    try {
      final isConnected = await AmapNativeService.instance.testConnection();
      setState(() {
        _testResult = isConnected 
            ? '✅ Platform Channel Connected!' 
            : '❌ Connection Failed';
      });
    } catch (e) {
      setState(() {
        _testResult = '❌ Error: $e';
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

        Get.snackbar(
          'Success',
          'Location selected!',
          backgroundColor: Colors.green.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to open map: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
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

      Get.snackbar(
        'Success',
        'Got current location!',
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to get location: $e',
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined, color: AppColors.backButtonDark),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Amap Native Test',
          style: TextStyle(
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
            title: '1. Test Platform Channel',
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
                      : const Text(
                          'Test Connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Text(
                  _testResult,
                  style: TextStyle(
                    fontSize: 14,
                    color: _testResult.contains('✅') 
                        ? Colors.green 
                        : _testResult.contains('❌')
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
            title: '2. Open Map Picker',
            child: ElevatedButton(
              onPressed: _isLoading ? null : _openMapPicker,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Open Native Map Picker',
                style: TextStyle(
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
            title: '3. Get Current Location',
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getCurrentLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text(
                'Get Current Location',
                style: TextStyle(
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
              title: '📍 Selected Location',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationInfo('Latitude', _selectedLocation!['latitude'].toString()),
                  _buildLocationInfo('Longitude', _selectedLocation!['longitude'].toString()),
                  _buildLocationInfo('Address', _selectedLocation!['address'] ?? 'N/A'),
                  _buildLocationInfo('City', _selectedLocation!['city'] ?? 'N/A'),
                  _buildLocationInfo('Province', _selectedLocation!['province'] ?? 'N/A'),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Instructions
          _buildSection(
            title: '📖 Instructions',
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1. First test the Platform Channel connection',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  '2. If connected, open the native map picker',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  '3. Drag the map to select a location',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 8),
                Text(
                  '4. Tap "Confirm Location" to return',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 16),
                Text(
                  'Note: Map tiles may not load in iOS Simulator. Use a real device for full testing.',
                  style: TextStyle(
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
