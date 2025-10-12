import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../services/amap_native_service.dart';

/// 高德地图位置选择器页面（原生实现）
/// 
/// 使用方法：
/// ```dart
/// final result = await Get.to(() => AmapNativePickerPage());
/// if (result != null) {
///   double latitude = result['latitude'];
///   double longitude = result['longitude'];
///   String address = result['address'];
/// }
/// ```
class AmapNativePickerPage extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const AmapNativePickerPage({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<AmapNativePickerPage> createState() => _AmapNativePickerPageState();
}

class _AmapNativePickerPageState extends State<AmapNativePickerPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 页面加载后立即打开原生地图选择器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNativeMapPicker();
    });
  }

  Future<void> _openNativeMapPicker() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AmapNativeService.instance.openMapPicker(
        initialLatitude: widget.initialLatitude,
        initialLongitude: widget.initialLongitude,
      );

      if (mounted) {
        if (result != null) {
          // 返回结果给上一个页面
          Get.back(result: result);
        } else {
          // 用户取消或发生错误
          Get.back();
        }
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to open map picker: $e',
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
        Get.back();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          'Select Location',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4458)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Opening native map picker...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ] else ...[
              const Icon(
                Icons.location_on_outlined,
                size: 64,
                color: Color(0xFFFF4458),
              ),
              const SizedBox(height: 16),
              const Text(
                'Map Picker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Uses native iOS AMap SDK',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _openNativeMapPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Open Map Picker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
