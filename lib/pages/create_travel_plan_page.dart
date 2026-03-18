import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_page.dart';
import 'package:go_nomads_app/services/amap_poi_service.dart';
import 'package:go_nomads_app/services/location_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';

import 'travel_plan/travel_plan_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 创建旅行计划页面 - 完整页面版本
class CreateTravelPlanPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const CreateTravelPlanPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<CreateTravelPlanPage> createState() => _CreateTravelPlanPageState();
}

class _CreateTravelPlanPageState extends State<CreateTravelPlanPage> {
  int duration = 7;
  String budget = 'medium';
  String travelStyle = 'culture';
  List<String> interests = [];
  String departureLocation = ''; // 默认为空，等待获取实时位置
  bool _isLoadingLocation = true; // 是否正在加载位置
  DateTime? departureDate;
  final TextEditingController _customBudgetController = TextEditingController();
  String selectedCurrency = 'USD';
  List<String> selectedAttractions = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  /// 获取当前位置并逆向解析地址
  Future<void> _loadCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      final locationService = Get.find<LocationService>();

      // 添加超时机制，防止无限等待
      final position =
          await locationService.getCurrentLocation().timeout(const Duration(seconds: 10), onTimeout: () => null);

      if (!mounted) return;

      if (position == null) {
        debugPrint('❌ 无法获取位置或超时，使用默认值');
        setState(() {
          departureLocation = '';
          _isLoadingLocation = false;
        });
        return;
      }

      debugPrint('📍 获取到位置: ${position.latitude}, ${position.longitude}');

      // 使用高德逆地理编码获取地址，同样添加超时
      final geoResult = await AmapPoiService.instance
          .reverseGeocode(
            latitude: position.latitude,
            longitude: position.longitude,
          )
          .timeout(const Duration(seconds: 5), onTimeout: () => null);

      if (!mounted) return;

      if (geoResult != null) {
        setState(() {
          // 使用简短地址（市+区）或完整地址
          departureLocation = geoResult.shortAddress.isNotEmpty ? geoResult.shortAddress : geoResult.formattedAddress;
          _isLoadingLocation = false;
        });
        debugPrint('✅ 逆地理编码成功: $departureLocation');
      } else {
        setState(() {
          departureLocation = '';
          _isLoadingLocation = false;
        });
        debugPrint('❌ 逆地理编码失败或超时');
      }
    } catch (e) {
      debugPrint('❌ 获取位置异常: $e');
      if (mounted) {
        setState(() {
          departureLocation = '';
          _isLoadingLocation = false;
        });
      }
    }
  }

  // 根据城市名称获取景点列表
  List<Map<String, dynamic>> get cityAttractions {
    // 这里可以根据 widget.cityName 返回不同城市的景点
    // 目前提供一个通用的景点列表示例
    return [
      {'name': '历史古迹', 'icon': FontAwesomeIcons.landmark, 'id': 'historic'},
      {'name': '博物馆', 'icon': FontAwesomeIcons.landmark, 'id': 'museum'},
      {'name': '公园绿地', 'icon': FontAwesomeIcons.tree, 'id': 'park'},
      {'name': '美食街区', 'icon': FontAwesomeIcons.utensils, 'id': 'food_district'},
      {'name': '购物中心', 'icon': FontAwesomeIcons.cartShopping, 'id': 'shopping_mall'},
      {'name': '艺术画廊', 'icon': FontAwesomeIcons.palette, 'id': 'art_gallery'},
      {'name': '观景台', 'icon': FontAwesomeIcons.mountain, 'id': 'viewpoint'},
      {'name': '海滩', 'icon': FontAwesomeIcons.umbrellaBeach, 'id': 'beach'},
      {'name': '寺庙教堂', 'icon': FontAwesomeIcons.placeOfWorship, 'id': 'temple'},
      {'name': '夜市', 'icon': FontAwesomeIcons.moon, 'id': 'night_market'},
      {'name': '主题乐园', 'icon': FontAwesomeIcons.cameraRetro, 'id': 'theme_park'},
      {'name': '水族馆', 'icon': FontAwesomeIcons.water, 'id': 'aquarium'},
    ];
  }

  @override
  void dispose() {
    _customBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(color: AppColors.backButtonDark),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    FontAwesomeIcons.wandMagicSparkles,
                    color: Color(0xFFFF4458),
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiTravelPlanner,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      l10n.planYourTrip(widget.cityName),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  width: double.infinity,
                  margin: EdgeInsets.all(16.w),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                        blurRadius: 12.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.wandMagicSparkles, color: Colors.white, size: 24.r),
                          SizedBox(width: 8.w),
                          Text(
                            l10n.aiPoweredPlanning,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.tellPreferences(widget.cityName),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Form Section
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10.r,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Departure Location
                      _buildSectionTitle(l10n.departureLocation, FontAwesomeIcons.locationDot),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _isLoadingLocation
                                ? Container(
                                    height: 56.h,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20.w,
                                          height: 20.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Color(0xFFFF4458),
                                          ),
                                        ),
                                        SizedBox(width: 12.w),
                                        Text(
                                          '正在获取当前位置...',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : TextField(
                                    controller: TextEditingController(text: departureLocation),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: l10n.selectDeparture,
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(color: Colors.grey.shade200),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: Color(0xFFFF4458),
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                      prefixIcon: Icon(
                                        FontAwesomeIcons.locationCrosshairs,
                                        color: Color(0xFFFF4458),
                                        size: 18.r,
                                      ),
                                      suffixIcon: departureLocation.isNotEmpty
                                          ? IconButton(
                                              icon: Icon(FontAwesomeIcons.xmark, size: 20.r),
                                              onPressed: () {
                                                setState(() {
                                                  departureLocation = '';
                                                });
                                              },
                                            )
                                          : null,
                                    ),
                                  ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            height: 56.h,
                            width: 56.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: const Icon(
                                FontAwesomeIcons.map,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                try {
                                  final result = await Get.to(
                                    () => const MapPickerPage(),
                                    binding: MapPickerBinding(),
                                  );
                                  if (result != null && result is Map) {
                                    final address = result['address'] as String? ?? '';
                                    setState(() {
                                      departureLocation = address;
                                      _isLoadingLocation = false; // 用户手动选择后停止加载状态
                                    });
                                  }
                                } catch (e) {
                                  AppToast.error(
                                    '${l10n.failedToOpenMap}: $e',
                                    title: l10n.error,
                                  );
                                }
                              },
                              tooltip: l10n.selectOnMap,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10n.tapMapIcon,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Departure Date
                      _buildSectionTitle('Departure Date', FontAwesomeIcons.calendarDays),
                      SizedBox(height: 12.h),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: departureDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFFF4458),
                                    onPrimary: Colors.white,
                                    surface: Colors.white,
                                    onSurface: Colors.black87,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              departureDate = picked;
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                FontAwesomeIcons.calendar,
                                color: departureDate != null ? const Color(0xFFFF4458) : Colors.grey[400],
                                size: 20.r,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  departureDate != null
                                      ? '${departureDate!.year}-${departureDate!.month.toString().padLeft(2, '0')}-${departureDate!.day.toString().padLeft(2, '0')}'
                                      : 'Select departure date',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    color: departureDate != null ? Colors.black87 : Colors.grey[400],
                                  ),
                                ),
                              ),
                              if (departureDate != null)
                                IconButton(
                                  icon: Icon(FontAwesomeIcons.xmark, size: 20.r),
                                  onPressed: () {
                                    setState(() {
                                      departureDate = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Trip Duration
                      _buildSectionTitle(l10n.tripDuration, FontAwesomeIcons.calendar),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Slider(
                                    value: duration.toDouble(),
                                    min: 1,
                                    max: 30,
                                    divisions: 29,
                                    label: l10n.days(duration),
                                    activeColor: const Color(0xFFFF4458),
                                    inactiveColor: Colors.grey[300],
                                    onChanged: (value) {
                                      setState(() => duration = value.toInt());
                                    },
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  width: 60.w,
                                  height: 40.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF4458),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    duration.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              duration == 1 ? l10n.day(1) : l10n.days(duration),
                              style: TextStyle(
                                color: Color(0xFFFF4458),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Budget Level
                      _buildSectionTitle(l10n.budget, FontAwesomeIcons.dollarSign),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBudgetChip(l10n.low, budget == 'low', () {
                              setState(() {
                                budget = 'low';
                                _customBudgetController.clear();
                              });
                            }),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildBudgetChip(l10n.medium, budget == 'medium', () {
                              setState(() {
                                budget = 'medium';
                                _customBudgetController.clear();
                              });
                            }),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildBudgetChip(l10n.high, budget == 'high', () {
                              setState(() {
                                budget = 'high';
                                _customBudgetController.clear();
                              });
                            }),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.enterBudget,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Container(
                            width: 100.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCurrency,
                                isExpanded: true,
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                borderRadius: BorderRadius.circular(12.r),
                                icon: const Icon(
                                  FontAwesomeIcons.chevronDown,
                                  color: Color(0xFFFF4458),
                                ),
                                items: [
                                  DropdownMenuItem(
                                    value: 'USD',
                                    child: Row(
                                      children: [
                                        Text(
                                          '\$ ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'USD',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'CNY',
                                    child: Row(
                                      children: [
                                        Text(
                                          '¥ ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'CNY',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'EUR',
                                    child: Row(
                                      children: [
                                        Text(
                                          '€ ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'EUR',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'GBP',
                                    child: Row(
                                      children: [
                                        Text(
                                          '£ ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'GBP',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'JPY',
                                    child: Row(
                                      children: [
                                        Text(
                                          '¥ ',
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          'JPY',
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      selectedCurrency = newValue;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: TextFormField(
                              controller: _customBudgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 0.toStringAsFixed(2),
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[50],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: Colors.grey.shade200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(
                                    color: Color(0xFFFF4458),
                                    width: 2,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {
                                    budget = 'custom';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 28.h),

                      // Preferred Attractions (新增景点选择模块)
                      _buildSectionTitle('想去的景点', FontAwesomeIcons.city),
                      SizedBox(height: 8.h),
                      Text(
                        '选择您在${widget.cityName}想要游览的景点类型',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: cityAttractions.map((attraction) {
                          return _buildAttractionChip(
                            attraction['name'] as String,
                            attraction['id'] as String,
                            attraction['icon'] as IconData,
                          );
                        }).toList(),
                      ),

                      SizedBox(height: 28.h),

                      // Travel Style
                      _buildSectionTitle(l10n.travelStyle, FontAwesomeIcons.paintbrush),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: [
                          _buildStyleChip(l10n.culture, 'culture', FontAwesomeIcons.landmark),
                          _buildStyleChip(l10n.adventure, 'adventure', FontAwesomeIcons.mountain),
                          _buildStyleChip(l10n.relaxation, 'relaxation', FontAwesomeIcons.spa),
                          _buildStyleChip(l10n.nightlife, 'nightlife', FontAwesomeIcons.champagneGlasses),
                        ],
                      ),

                      SizedBox(height: 28.h),

                      // Interests
                      _buildSectionTitle(l10n.interests, FontAwesomeIcons.heart),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.w,
                        children: [
                          _buildInterestChip(l10n.photography),
                          _buildInterestChip(l10n.history),
                          _buildInterestChip('Art'),
                          _buildInterestChip(l10n.nature),
                          _buildInterestChip('Beach'),
                          _buildInterestChip('Temples'),
                          _buildInterestChip('Markets'),
                          _buildInterestChip('Coffee'),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10.r,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: () => _generatePlan(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4458),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.wandMagicSparkles, size: 20.r),
                    SizedBox(width: 8.w),
                    Text(
                      l10n.generatePlan,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.r, color: const Color(0xFFFF4458)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.3),
                    blurRadius: 8.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleChip(String label, String value, IconData icon) {
    final isSelected = travelStyle == value;
    return GestureDetector(
      onTap: () {
        setState(() => travelStyle = value);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? Colors.white : Colors.black54,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestChip(String label) {
    final isSelected = interests.contains(label);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            interests.remove(label);
          } else {
            interests.add(label);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAttractionChip(String label, String id, IconData icon) {
    final isSelected = selectedAttractions.contains(id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedAttractions.remove(id);
          } else {
            selectedAttractions.add(id);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFFF4458), Color(0xFFFF6B7A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[50],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF4458) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.2),
                    blurRadius: 6.r,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16.r,
              color: isSelected ? Colors.white : const Color(0xFFFF4458),
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _generatePlan() {
    // Use custom budget if provided, otherwise use selected budget level
    String finalBudget = budget;
    if (_customBudgetController.text.isNotEmpty) {
      // Format: "CURRENCY:AMOUNT" (e.g., "USD:5000" or "CNY:30000")
      finalBudget = '$selectedCurrency:${_customBudgetController.text}';
    }

    // Combine interests and selected attractions
    List<String> allInterests = [...interests];
    // Add selected attractions with "attraction:" prefix to distinguish them
    for (var attractionId in selectedAttractions) {
      allInterests.add('attraction:$attractionId');
    }

    // Navigate to TravelPlanPage with all parameters
    Get.to(
      () => TravelPlanPage(
        cityId: widget.cityId,
        cityName: widget.cityName,
        duration: duration,
        budget: finalBudget,
        travelStyle: travelStyle,
        interests: allInterests,
        departureLocation: departureLocation,
        departureDate: departureDate,
      ),
    );
  }
}
