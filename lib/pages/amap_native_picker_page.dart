import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../services/amap_native_service.dart';

/// 高德地图位置选择器页面（原生实现�?
///
/// 使用方法�?
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
    // 页面加载后立即打开原生地图选择�?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openNativeMapPicker();
    });
  }

  Future<void> _openNativeMapPicker() async {
    print('🗺️ AmapNativePickerPage: 开始打开地图选择器');
    setState(() {
      _isLoading = true;
    });

    try {
      print('📍 调用 AmapNativeService.openMapPicker...');
      final result = await AmapNativeService.instance.openMapPicker(
        initialLatitude: widget.initialLatitude,
        initialLongitude: widget.initialLongitude,
      );

      print('📍 AmapNativeService 返回结果: $result');

      if (mounted) {
        if (result != null) {
          print('�?返回结果到上一�? $result');
          // 返回结果给上一个页�?
          Get.back(result: result);
        } else {
          print('⚠️ 结果�?null，用户可能取消了选择');
          // 用户取消或发生错�?
          Get.back();
        }
      }
    } catch (e) {
      print('❌打开地图选择器异常: $e');
      print('❌异常类型: ${e.runtimeType}');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        Get.snackbar(
          l10n.error,
          '${l10n.failedToOpenMapPicker}: $e',
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
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
          l10n.selectLocation,
          style: const TextStyle(
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
              Text(
                l10n.openingNativeMapPicker,
                style: const TextStyle(
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
              Text(
                l10n.mapPicker,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.usesNativeAMapSDK,
                style: const TextStyle(
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
                child: Text(
                  l10n.openMapPicker,
                  style: const TextStyle(
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
