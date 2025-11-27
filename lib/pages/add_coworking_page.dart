import 'dart:ui' as ui;

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/config/supabase_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_repository.dart';
import 'package:df_admin_mobile/features/location/presentation/controllers/location_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/utils/image_upload_helper.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'maplibre_picker_page.dart';

/// Add Coworking Space Page
/// 添加共享办公空间页面
class AddCoworkingPage extends StatefulWidget {
  final String? cityName;
  final String? cityId;
  final String? countryName;

  const AddCoworkingPage({
    super.key,
    this.cityName,
    this.cityId,
    this.countryName,
  });

  @override
  State<AddCoworkingPage> createState() => _AddCoworkingPageState();
}

class _AddCoworkingPageState extends State<AddCoworkingPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  // 延迟获取 LocationStateController，如果不存在则初始化
  late final LocationStateController _locationController;

  // Basic Info
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selected country and city
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedCountryId;
  String? _selectedCityId;
  final GlobalKey<FormFieldState<String>> _cityFieldKey = GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _countryFieldKey = GlobalKey<FormFieldState<String>>();

  // Location
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Contact
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  // Pricing
  final _hourlyRateController = TextEditingController();
  final _dailyRateController = TextEditingController();
  final _weeklyRateController = TextEditingController();
  final _monthlyRateController = TextEditingController();
  String _currency = 'USD';
  bool _hasFreeTrial = false;
  final _trialDurationController = TextEditingController();

  // Specs
  final _wifiSpeedController = TextEditingController();
  final _numberOfDesksController = TextEditingController();
  final _numberOfMeetingRoomsController = TextEditingController();
  final _capacityController = TextEditingController();
  String? _noiseLevel;
  bool _hasNaturalLight = false;
  String? _spaceType;

  // Amenities
  bool _hasWifi = false;
  bool _hasCoffee = false;
  bool _hasPrinter = false;
  bool _hasMeetingRoom = false;
  bool _hasPhoneBooth = false;
  bool _hasKitchen = false;
  bool _hasParking = false;
  bool _hasLocker = false;
  bool _has24HourAccess = false;
  bool _hasAirConditioning = false;
  bool _hasStandingDesk = false;
  bool _hasShower = false;
  bool _hasBike = false;
  bool _hasEventSpace = false;
  bool _hasPetFriendly = false;

  // Opening Hours
  final List<String> _openingHours = [];

  // Images
  static const int maxCoworkingImages = 5;
  final List<String> _coworkingImageUrls = [];
  bool _isUploadingImages = false;
  String? _imageUploadStatus;
  final ImageUploadService _imageUploadService = ImageUploadService();

  String? _normalizeInput(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  String _resolveLocaleCode() {
    final locale = Get.locale ?? ui.PlatformDispatcher.instance.locale;
    return locale.languageCode.toLowerCase();
  }

  String? _getRouteValue(String key) {
    final args = Get.arguments;
    if (args is Map) {
      final dynamic value = args[key];
      if (value != null) {
        final normalized = value.toString().trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }

    final parameters = Get.parameters;
    if (parameters.containsKey(key)) {
      final value = parameters[key];
      if (value != null) {
        final normalized = value.trim();
        if (normalized.isNotEmpty) {
          return normalized;
        }
      }
    }

    return null;
  }

  int get _remainingImageSlots => maxCoworkingImages - _coworkingImageUrls.length;

  String get _imageUploadBucket => SupabaseConfig.buckets['coworkingPhotos'] ?? SupabaseConfig.defaultBucket;

  String get _imageUploadFolder => 'coworking/${_selectedCityId ?? 'general'}';

  @override
  void initState() {
    super.initState();

    // 获取 LocationStateController (已在 DI 中注册)
    _locationController = Get.find<LocationStateController>();

    final paramCityId = _normalizeInput(widget.cityId) ?? _getRouteValue('cityId');
    final paramCityName = _normalizeInput(widget.cityName) ?? _getRouteValue('cityName');
    final paramCountryName = _normalizeInput(widget.countryName) ?? _getRouteValue('countryName');

    // 仅当参数中包含 cityId 时才进行国家和城市的初始化
    if (paramCityId != null) {
      print('🏙️ [AddCoworking] 从参数中读取 cityId: $paramCityId');
      _initializeFromCityId(
        paramCityId,
        fallbackCityName: paramCityName,
        fallbackCountryName: paramCountryName,
      );
    } else {
      print('📝 [AddCoworking] 未提供 cityId，跳过国家/城市预填充');
    }
  }

  /// 根据 cityId 初始化国家和城市信息
  Future<void> _initializeFromCityId(
    String cityId, {
    String? fallbackCityName,
    String? fallbackCountryName,
  }) async {
    try {
      print('🔍 [AddCoworking] _initializeFromCityId 开始');
      print('   cityId: $cityId');

      // 1. 加载所有国家（如果还没有加载）
      if (_locationController.countries.isEmpty) {
        print('📥 [AddCoworking] 加载国家列表...');
        await _locationController.loadCountries();
      }

      final localeCode = _resolveLocaleCode();

      // 2. 直接通过 cityId 获取城市信息（包含 countryId）
      print('🔍 [AddCoworking] 通过 API 获取城市信息（包含 countryId）...');
      final cityResult = await _locationController.getCityById(cityId);

      String? foundCountryId;
      CityOption? foundCity;

      if (cityResult.isSuccess) {
        foundCity = cityResult.dataOrNull;
        foundCountryId = foundCity?.countryId;

        if (foundCity != null) {
          print('✅ [AddCoworking] 获取到城市: ${foundCity.name}');
          print('✅ [AddCoworking] 获取到 countryId: $foundCountryId');
        }
      } else {
        print('❌ [AddCoworking] 获取城市信息失败: ${cityResult.exceptionOrNull?.message}');
      }

      // 3. 如果通过 API 没获取到 countryId，则使用传入的 countryName 来查找（fallback）
      if (foundCountryId == null && fallbackCountryName != null && fallbackCountryName.isNotEmpty) {
        final trimmedCountryName = fallbackCountryName.trim();
        print('🔍 [AddCoworking] fallback: 使用传入的 countryName: "$trimmedCountryName"');

        // 根据 countryName 查找对应的国家
        final country = _locationController.countries.firstWhereOrNull((c) {
          final displayName = c.displayName(localeCode).toLowerCase().trim();
          final name = c.name.toLowerCase().trim();
          final nameZh = (c.nameZh ?? '').toLowerCase().trim();
          final searchName = trimmedCountryName.toLowerCase();

          // 尝试完全匹配（优先级最高）
          var match = displayName == searchName || name == searchName || nameZh == searchName;

          // 如果完全匹配失败，尝试包含匹配
          if (!match && searchName.length >= 3) {
            match = displayName.contains(searchName) ||
                searchName.contains(displayName) ||
                name.contains(searchName) ||
                searchName.contains(name) ||
                (nameZh.isNotEmpty && (nameZh.contains(searchName) || searchName.contains(nameZh)));
          }

          return match;
        });

        if (country != null) {
          foundCountryId = country.id;
          print('✅ [AddCoworking] 通过 countryName 找到匹配的国家: ${country.name} (ID: ${country.id})');

          // 加载该国家的城市列表
          await _locationController.loadCitiesByCountry(country.id);
          final cities = _locationController.citiesByCountry[country.id] ?? [];

          // 在该国家的城市列表中查找目标城市
          foundCity = cities.firstWhereOrNull((c) => c.id == cityId);

          if (foundCity != null) {
            print('✅ [AddCoworking] 在 ${country.name} 中找到城市: ${foundCity.name}');
          }
        } else {
          print('⚠️ [AddCoworking] 未找到匹配的国家: "$trimmedCountryName"');
        }
      }

      // 4. 最后的兜底方案：遍历所有国家查找

      if (fallbackCountryName != null && fallbackCountryName.isNotEmpty) {
        final trimmedCountryName = fallbackCountryName.trim();
        print('🔍 [AddCoworking] 使用传入的 countryName: "$trimmedCountryName"');
        print('🔍 [AddCoworking] countryName长度: ${trimmedCountryName.length}, 编码: ${trimmedCountryName.codeUnits}');

        // 打印所有国家名称用于调试
        print('📋 [AddCoworking] 可用的国家列表 (前10个):');
        for (var c in _locationController.countries.take(10)) {
          final displayName = c.displayName(localeCode);
          print('   - ${c.name} / ${c.nameZh} / $displayName');
        }

        // 根据 countryName 查找对应的国家
        final country = _locationController.countries.firstWhereOrNull((c) {
          final displayName = c.displayName(localeCode).toLowerCase().trim();
          final name = c.name.toLowerCase().trim();
          final nameZh = (c.nameZh ?? '').toLowerCase().trim();
          final searchName = trimmedCountryName.toLowerCase();

          // 尝试完全匹配（优先级最高）
          var match = displayName == searchName || name == searchName || nameZh == searchName;

          // 如果完全匹配失败，尝试包含匹配（但只有在搜索词足够长时）
          if (!match && searchName.length >= 3) {
            match = displayName.contains(searchName) ||
                searchName.contains(displayName) ||
                name.contains(searchName) ||
                searchName.contains(name) ||
                (nameZh.isNotEmpty && (nameZh.contains(searchName) || searchName.contains(nameZh)));
          }

          if (match) {
            print('✅ [AddCoworking] 找到匹配: ${c.name} (${c.nameZh}) - displayName: $displayName');
          }

          return match;
        });

        if (country != null) {
          foundCountryId = country.id;
          print('✅ [AddCoworking] 找到匹配的国家: ${country.name} (ID: ${country.id})');

          // 加载该国家的城市列表
          await _locationController.loadCitiesByCountry(country.id);
          final cities = _locationController.citiesByCountry[country.id] ?? [];

          // 在该国家的城市列表中查找目标城市
          foundCity = cities.firstWhereOrNull((c) => c.id == cityId);

          if (foundCity != null) {
            print('✅ [AddCoworking] 在 ${country.name} 中找到城市: ${foundCity.name}');
          } else {
            print('⚠️ [AddCoworking] 在 ${country.name} 中未找到 cityId=$cityId');
          }
        } else {
          print('⚠️ [AddCoworking] 未找到匹配的国家: "$fallbackCountryName"');
          print('⚠️ [AddCoworking] 尝试过的匹配方式: displayName, name, nameZh');
          print('⚠️ [AddCoworking] 将fallback到遍历所有国家');
        }
      }

      // 3. 如果通过 countryName 没找到，则遍历所有国家查找（兜底方案）
      if (foundCountryId == null || foundCity == null) {
        print('🔍 [AddCoworking] 遍历所有国家查找 cityId=$cityId...');
        print('📋 [AddCoworking] 国家总数: ${_locationController.countries.length}');

        for (final country in _locationController.countries) {
          print('   检查国家: ${country.name} (${country.nameZh})...');

          // 加载该国家的城市列表
          await _locationController.loadCitiesByCountry(country.id);

          // 查找是否包含目标城市
          final cities = _locationController.citiesByCountry[country.id] ?? [];
          final city = cities.firstWhereOrNull((c) => c.id == cityId);

          if (city != null) {
            foundCountryId = country.id;
            foundCity = city;
            print('✅ [AddCoworking] 找到城市: ${city.name}, 国家: ${country.name}');
            break;
          }
        }

        if (foundCity == null) {
          print('❌ [AddCoworking] 遍历所有国家后仍未找到 cityId=$cityId');
        }
      }

      // 4. 如果找到了，设置选中状态
      if (foundCountryId != null && foundCity != null) {
        final country = _locationController.countries.firstWhereOrNull((c) => c.id == foundCountryId);

        if (country != null && mounted) {
          setState(() {
            _selectedCountryId = country.id;
            _selectedCountry = country.displayName(localeCode);
            _selectedCityId = foundCity!.id;
            _selectedCity = foundCity.name;
          });

          // 更新表单字段
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _countryFieldKey.currentState?.didChange(_selectedCountry);
            _cityFieldKey.currentState?.didChange(_selectedCity);
          });

          print('🎯 [AddCoworking] 初始化完成: $_selectedCountry > $_selectedCity');
        }
      } else {
        print('⚠️ [AddCoworking] 未找到 cityId=$cityId 对应的城市');

        // 如果传入了 cityName 和 countryName，直接使用（即使在列表中找不到）
        if (fallbackCityName != null && fallbackCountryName != null) {
          setState(() {
            _selectedCountry = fallbackCountryName;
            _selectedCity = fallbackCityName;
            _selectedCityId = cityId;
          });
          print('📝 [AddCoworking] 直接使用传入的参数: $fallbackCountryName > $fallbackCityName');
        }
      }
    } catch (e) {
      print('❌ [AddCoworking] 初始化失败: $e');

      // 降级处理：使用传入的参数
      if (fallbackCityName != null && fallbackCountryName != null) {
        setState(() {
          _selectedCountry = fallbackCountryName;
          _selectedCity = fallbackCityName;
          _selectedCityId = cityId;
        });
        print('🔄 [AddCoworking] 降级处理，使用传入参数: $fallbackCountryName > $fallbackCityName');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _hourlyRateController.dispose();
    _dailyRateController.dispose();
    _weeklyRateController.dispose();
    _monthlyRateController.dispose();
    _trialDurationController.dispose();
    _wifiSpeedController.dispose();
    _numberOfDesksController.dispose();
    _numberOfMeetingRoomsController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l10n.addCoworkingSpace,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                children: [
                  // Image Upload
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: l10n.spaceName,
                    hint: l10n.spaceNameHint,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: l10n.description,
                    hint: l10n.descriptionHint,
                    maxLines: 4,
                    required: true,
                  ),

                  const SizedBox(height: 32),

                  // Location
                  _buildSectionTitle(l10n.location, FontAwesomeIcons.locationDot),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: l10n.address,
                    hint: l10n.addressHint,
                    required: true,
                  ),
                  const SizedBox(height: 16),

                  // Country Dropdown
                  _buildCountryDropdown(l10n),

                  const SizedBox(height: 16),

                  // City Dropdown
                  _buildCityDropdown(l10n),

                  const SizedBox(height: 16),
                  _buildLocationPicker(),

                  const SizedBox(height: 32),

                  // Contact Information
                  _buildSectionTitle(l10n.contactInformation, FontAwesomeIcons.addressBook),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: l10n.phone,
                    hint: l10n.phoneHint,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: l10n.email,
                    hint: l10n.emailHint,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _websiteController,
                    label: l10n.website,
                    hint: l10n.websiteHint,
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 32),

                  // Pricing
                  _buildSectionTitle(l10n.pricing, FontAwesomeIcons.dollarSign),
                  const SizedBox(height: 16),
                  _buildCurrencyDropdown(l10n),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _hourlyRateController,
                          label: l10n.hourlyRate,
                          hint: l10n.hourlyRateHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _dailyRateController,
                          label: l10n.dailyRate,
                          hint: l10n.dailyRateHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _weeklyRateController,
                          label: l10n.weeklyRate,
                          hint: l10n.weeklyRateHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _monthlyRateController,
                          label: l10n.monthlyRate,
                          hint: l10n.monthlyRateHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    l10n.freeTrialAvailable,
                    _hasFreeTrial,
                    (value) => setState(() => _hasFreeTrial = value),
                  ),
                  if (_hasFreeTrial) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _trialDurationController,
                      label: l10n.trialDuration,
                      hint: l10n.trialDurationHint,
                    ),
                  ],

                  const SizedBox(height: 32), // Specifications
                  _buildSectionTitle(l10n.specifications, FontAwesomeIcons.gear),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _wifiSpeedController,
                          label: l10n.wifiSpeed,
                          hint: l10n.wifiSpeedHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _capacityController,
                          label: l10n.capacity,
                          hint: l10n.capacityHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _numberOfDesksController,
                          label: l10n.numberOfDesks,
                          hint: l10n.numberOfDesksHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _numberOfMeetingRoomsController,
                          label: l10n.meetingRooms,
                          hint: l10n.meetingRoomsHint,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    l10n.noiseLevel,
                    _noiseLevel,
                    [l10n.noiseLevelQuiet, l10n.noiseLevelModerate, l10n.noiseLevelLoud],
                    (value) => setState(() => _noiseLevel = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    l10n.spaceType,
                    _spaceType,
                    [l10n.spaceTypeOpen, l10n.spaceTypePrivate, l10n.spaceTypeMixed],
                    (value) => setState(() => _spaceType = value),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    l10n.naturalLight,
                    _hasNaturalLight,
                    (value) => setState(() => _hasNaturalLight = value),
                  ),

                  const SizedBox(height: 32),

                  // Amenities
                  _buildSectionTitle(l10n.amenities, FontAwesomeIcons.star),
                  const SizedBox(height: 16),
                  _buildSwitchTile(l10n.wifi, _hasWifi, (value) => setState(() => _hasWifi = value)),
                  _buildSwitchTile(l10n.freeCoffee, _hasCoffee, (value) => setState(() => _hasCoffee = value)),
                  _buildSwitchTile(l10n.printer, _hasPrinter, (value) => setState(() => _hasPrinter = value)),
                  _buildSwitchTile(
                      l10n.meetingRooms, _hasMeetingRoom, (value) => setState(() => _hasMeetingRoom = value)),
                  _buildSwitchTile(l10n.phoneBooth, _hasPhoneBooth, (value) => setState(() => _hasPhoneBooth = value)),
                  _buildSwitchTile(l10n.kitchen, _hasKitchen, (value) => setState(() => _hasKitchen = value)),
                  _buildSwitchTile(l10n.parking, _hasParking, (value) => setState(() => _hasParking = value)),
                  _buildSwitchTile(l10n.locker, _hasLocker, (value) => setState(() => _hasLocker = value)),
                  _buildSwitchTile(l10n.twentyFourSevenAccess, _has24HourAccess,
                      (value) => setState(() => _has24HourAccess = value)),
                  _buildSwitchTile(l10n.airConditioning, _hasAirConditioning,
                      (value) => setState(() => _hasAirConditioning = value)),
                  _buildSwitchTile(
                      l10n.standingDesk, _hasStandingDesk, (value) => setState(() => _hasStandingDesk = value)),
                  _buildSwitchTile(l10n.shower, _hasShower, (value) => setState(() => _hasShower = value)),
                  _buildSwitchTile(l10n.bikeStorage, _hasBike, (value) => setState(() => _hasBike = value)),
                  _buildSwitchTile(l10n.eventSpace, _hasEventSpace, (value) => setState(() => _hasEventSpace = value)),
                  _buildSwitchTile(
                      l10n.petFriendly, _hasPetFriendly, (value) => setState(() => _hasPetFriendly = value)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Bottom Submit Button
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    final l10n = AppLocalizations.of(context)!;

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) {
                return l10n.thisFieldIsRequired;
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: onChanged,
      activeThumbColor: const Color(0xFFFF4458),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildCurrencyDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _currency,
      decoration: InputDecoration(
        labelText: l10n.currency,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD'].map((currency) {
        return DropdownMenuItem(
          value: currency,
          child: Text(currency),
        );
      }).toList(),
      onChanged: (value) => setState(() => _currency = value!),
    );
  }

  Widget _buildLocationPicker() {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: const Icon(FontAwesomeIcons.map, color: Color(0xFFFF4458)),
        title: _latitude != 0 && _longitude != 0
            ? Text(l10n.locationCoordinates(
                _latitude.toStringAsFixed(6),
                _longitude.toStringAsFixed(6),
              ))
            : Text(l10n.pickLocationOnMap),
        trailing: const Icon(FontAwesomeIcons.arrowRight, size: 16),
        onTap: () async {
          // 获取当前地址字段的内容作为搜索关键词
          final addressQuery = _addressController.text.trim();

          print('🗺️ [AddCoworking] 打开地图选择器');
          print('   地址参数: "$addressQuery"');
          print('   当前经纬度: $_latitude, $_longitude');

          final result = await Get.to(() => MapLibrePickerPage(
                initialLatitude: _latitude != 0 ? _latitude : null,
                initialLongitude: _longitude != 0 ? _longitude : null,
                searchQuery: addressQuery.isNotEmpty ? addressQuery : null,
              ));

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              // 更新经纬度
              _latitude = result['latitude'] ?? 0.0;
              _longitude = result['longitude'] ?? 0.0;

              // 只更新名称字段（如果有POI名称的话）
              if (result['name'] != null && result['name'].toString().isNotEmpty) {
                _nameController.text = result['name'];
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildImageSection() {
    final l10n = AppLocalizations.of(context)!;
    final canAddMore = _remainingImageSlots > 0;
    final hasImages = _coworkingImageUrls.isNotEmpty;

    final tiles = List<Widget>.generate(
      _coworkingImageUrls.length,
      (index) => _buildImagePreviewTile(_coworkingImageUrls[index], index),
    );

    if (canAddMore) {
      tiles.add(_buildAddImageTile(l10n, fullWidth: !hasImages));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.addCoverPhoto,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_coworkingImageUrls.length}/$maxCoworkingImages',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasImages)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: tiles,
          )
        else
          tiles.first,
        if (_isUploadingImages) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 8),
              Text(_imageUploadStatus ?? 'Uploading...'),
            ],
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'You can upload up to $maxCoworkingImages photos',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreviewTile(String imageUrl, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(FontAwesomeIcons.image),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: IconButton(
            onPressed: () => _removeImageAt(index),
            icon: const Icon(FontAwesomeIcons.xmark, size: 18, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              padding: const EdgeInsets.all(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageTile(AppLocalizations l10n, {bool fullWidth = false}) {
    return GestureDetector(
      onTap: _showImageOptions,
      child: Container(
        width: fullWidth ? double.infinity : 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 32, color: Colors.grey[500]),
            const SizedBox(height: 8),
            Text(
              l10n.tapToChoosePhoto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageOptions() async {
    final l10n = AppLocalizations.of(context)!;

    if (_remainingImageSlots <= 0) {
      AppToast.info('You can upload up to $maxCoworkingImages photos');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(FontAwesomeIcons.images),
                title: Text('${l10n.photoLibrary} (multi-select)'),
                onTap: () {
                  Navigator.pop(context);
                  _addImagesFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.camera),
                title: Text(l10n.camera),
                onTap: () {
                  Navigator.pop(context);
                  _addImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(FontAwesomeIcons.xmark),
                title: Text(l10n.cancel),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _addImagesFromGallery() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isUploadingImages = true;
      _imageUploadStatus = null;
    });

    try {
      final newUrls = await ImageUploadHelper.pickMultipleAndUpload(
        bucket: _imageUploadBucket,
        folder: _imageUploadFolder,
        maxImages: _remainingImageSlots,
        onProgress: (current, total) {
          setState(() {
            _imageUploadStatus = '上传进度 $current / $total';
          });
        },
      );

      if (newUrls.isNotEmpty) {
        setState(() {
          _coworkingImageUrls.addAll(newUrls);
        });
      }
    } catch (e) {
      AppToast.error(
        l10n.failedToPickImage(e.toString()),
        title: l10n.error,
      );
    } finally {
      setState(() {
        _isUploadingImages = false;
        _imageUploadStatus = null;
      });
    }
  }

  Future<void> _addImageFromCamera() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isUploadingImages = true;
      _imageUploadStatus = null;
    });

    try {
      final url = await ImageUploadHelper.captureAndUpload(
        bucket: _imageUploadBucket,
        folder: _imageUploadFolder,
      );

      if (url != null) {
        setState(() {
          _coworkingImageUrls.add(url);
        });
      }
    } catch (e) {
      AppToast.error(
        l10n.failedToPickImage(e.toString()),
        title: l10n.error,
      );
    } finally {
      setState(() {
        _isUploadingImages = false;
        _imageUploadStatus = null;
      });
    }
  }

  Future<void> _removeImageAt(int index) async {
    if (index < 0 || index >= _coworkingImageUrls.length) {
      return;
    }

    final url = _coworkingImageUrls[index];

    setState(() {
      _coworkingImageUrls.removeAt(index);
    });

    try {
      await _imageUploadService.deleteImage(
        imageUrl: url,
        bucket: _imageUploadBucket,
      );
    } catch (e) {
      print('Failed to delete image: $e');
    }
  }

  /// 底部提交按钮栏
  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
              onPressed: _isSubmitting.value ? () {} : _submitCoworking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(FontAwesomeIcons.circleCheck, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.submitCoworkingSpace,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> _submitCoworking() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 验证必填字段
    if (_selectedCityId == null || _selectedCityId!.isEmpty) {
      AppToast.error(
        l10n.selectCity,
        title: l10n.error,
      );
      return;
    }

    // 地图位置暂时设置为可选，不做强制检查
    // if (_latitude == 0.0 || _longitude == 0.0) {
    //   AppToast.error(
    //     l10n.pickLocationOnMap,
    //     title: l10n.error,
    //   );
    //   return;
    // }

    _isSubmitting.value = true;

    try {
      // 获取 Repository
      final repository = Get.find<ICoworkingRepository>();

      // 构建 opening hours 列表
      final openingHours = _openingHours.isNotEmpty ? _openingHours : ['Monday-Friday: 9:00-18:00']; // 默认营业时间

      // 构建领域实体
      final coworkingSpace = CoworkingSpace(
        id: '', // 新创建时 ID 为空，由后端生成
        name: _nameController.text,
        location: Location(
          cityId: _selectedCityId, // 添加 cityId
          address: _addressController.text,
          city: _selectedCity ?? '',
          country: _selectedCountry ?? '',
          latitude: _latitude,
          longitude: _longitude,
        ),
        contactInfo: ContactInfo(
          phone: _phoneController.text,
          email: _emailController.text,
          website: _websiteController.text,
        ),
        spaceInfo: SpaceInfo(
          imageUrl: _coworkingImageUrls.isNotEmpty ? _coworkingImageUrls.first : '',
          images: _coworkingImageUrls,
          rating: 0.0,
          reviewCount: 0,
          description: _descriptionController.text,
        ),
        pricing: Pricing(
          hourlyRate: _hourlyRateController.text.isNotEmpty ? double.tryParse(_hourlyRateController.text) : null,
          dailyRate: _dailyRateController.text.isNotEmpty ? double.tryParse(_dailyRateController.text) : null,
          weeklyRate: _weeklyRateController.text.isNotEmpty ? double.tryParse(_weeklyRateController.text) : null,
          monthlyRate: _monthlyRateController.text.isNotEmpty ? double.tryParse(_monthlyRateController.text) : null,
          currency: _currency,
          hasFreeTrial: _hasFreeTrial,
          trialDuration: _hasFreeTrial ? _trialDurationController.text : null,
        ),
        amenities: Amenities(
          hasWifi: _hasWifi,
          hasCoffee: _hasCoffee,
          hasPrinter: _hasPrinter,
          hasMeetingRoom: _hasMeetingRoom,
          hasPhoneBooth: _hasPhoneBooth,
          hasKitchen: _hasKitchen,
          hasParking: _hasParking,
          hasLocker: _hasLocker,
          has24HourAccess: _has24HourAccess,
          hasAirConditioning: _hasAirConditioning,
          hasStandingDesk: _hasStandingDesk,
          hasShower: _hasShower,
          hasBike: _hasBike,
          hasEventSpace: _hasEventSpace,
          hasPetFriendly: _hasPetFriendly,
        ),
        specs: Specifications(
          wifiSpeed: _wifiSpeedController.text.isNotEmpty ? double.tryParse(_wifiSpeedController.text) : null,
          numberOfDesks: _numberOfDesksController.text.isNotEmpty ? int.tryParse(_numberOfDesksController.text) : null,
          numberOfMeetingRooms: _numberOfMeetingRoomsController.text.isNotEmpty
              ? int.tryParse(_numberOfMeetingRoomsController.text)
              : null,
          capacity: _capacityController.text.isNotEmpty ? int.tryParse(_capacityController.text) : null,
          noiseLevel: NoiseLevel.fromString(_noiseLevel),
          hasNaturalLight: _hasNaturalLight,
          spaceType: SpaceType.fromString(_spaceType),
        ),
        operationHours: OperationHours(hours: openingHours),
        isVerified: false,
        lastUpdated: DateTime.now(),
      );

      // 调用 Repository 创建共享办公空间
      final result = await repository.createCoworkingSpace(coworkingSpace);

      // 处理结果
      result.fold(
        onSuccess: (createdSpace) {
          // 返回结果,传递 true 表示需要刷新数据
          Navigator.pop(context, true);
          AppToast.success(
            l10n.coworkingSubmittedSuccess,
            title: l10n.success,
          );
        },
        onFailure: (exception) {
          AppToast.error(
            l10n.failedToSubmitCoworking(exception.message),
            title: l10n.error,
          );
        },
      );
    } catch (e) {
      // 捕获未预期的异常
      AppToast.error(
        l10n.failedToSubmitCoworking(e.toString()),
        title: l10n.error,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 构建国家下拉选择器
  Widget _buildCountryDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.country} *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final countryList = _locationController.countries;
          final isLoadingCountries = _locationController.isLoadingCountries.value;
          final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();

          final countryEntries = countryList
              .where((country) => country.isActive)
              .map((country) => MapEntry(
                    country,
                    country.displayName(localeCode),
                  ))
              .where((entry) => entry.value.isNotEmpty)
              .toList()
            ..sort((a, b) => a.value.compareTo(b.value));

          final countries = countryEntries.map((entry) => entry.value).toList();

          return FormField<String>(
            key: _countryFieldKey,
            initialValue: _selectedCountry,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.selectCountry;
              }
              return null;
            },
            builder: (field) {
              final displayCountry = field.value ?? _selectedCountry;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (isLoadingCountries) {
                    AppToast.info(l10n.loading, title: l10n.notice);
                    return;
                  }

                  if (countries.isEmpty) {
                    AppToast.info(l10n.noData, title: l10n.notice);
                    _locationController.loadCountries(forceRefresh: true);
                    return;
                  }

                  FocusScope.of(context).unfocus();
                  _showOptionPicker(
                    options: countries,
                    title: l10n.selectCountry,
                    initialValue: _selectedCountry,
                    onSelected: (value) {
                      final selectedEntry = countryEntries.firstWhereOrNull((entry) => entry.value == value);
                      if (selectedEntry == null) {
                        return;
                      }

                      setState(() {
                        _selectedCountry = value;
                        _selectedCountryId = selectedEntry.key.id;
                        _selectedCity = null;
                        _selectedCityId = null;
                      });
                      field.didChange(value);

                      final cityFieldState = _cityFieldKey.currentState;
                      cityFieldState?.didChange(null);

                      _locationController.loadCitiesByCountry(selectedEntry.key.id);
                    },
                  );
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: l10n.selectCountry,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: isLoadingCountries
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(FontAwesomeIcons.chevronDown),
                    errorText: field.errorText,
                  ),
                  isEmpty: displayCountry == null || displayCountry.isEmpty,
                  child: Text(
                    displayCountry ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: displayCountry == null || displayCountry.isEmpty
                              ? Theme.of(context).hintColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  /// 构建城市下拉选择器
  Widget _buildCityDropdown(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${l10n.city} *',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final selectedCountryId = _selectedCountryId;
          final cityMap = _locationController.citiesByCountry;
          final _ = cityMap.length; // 触发 Obx 监听
          final cachedCities =
              selectedCountryId == null ? const <CityOption>[] : (cityMap[selectedCountryId] ?? const <CityOption>[]);

          final cachedCityNames =
              cachedCities.map((city) => city.name).where((name) => name.isNotEmpty).toSet().toList()..sort();

          return FormField<String>(
            key: _cityFieldKey,
            initialValue: _selectedCity,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.selectCity;
              }
              return null;
            },
            builder: (field) {
              final displayCity = field.value ?? _selectedCity;
              final isLoadingCities = _locationController.isLoadingCities.value;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: (_selectedCountryId == null || isLoadingCities)
                    ? null
                    : () async {
                        FocusScope.of(context).unfocus();

                        // 使用缓存的城市列表
                        List<String> options = List<String>.from(cachedCityNames);

                        if (options.isEmpty) {
                          AppToast.info(l10n.noData, title: l10n.notice);
                          return;
                        }

                        _showOptionPicker(
                          options: options,
                          title: l10n.selectCity,
                          initialValue: _selectedCity,
                          onSelected: (value) {
                            final selectedCity = cachedCities.firstWhereOrNull((city) => city.name == value);

                            setState(() {
                              _selectedCity = value;
                              _selectedCityId = selectedCity?.id;
                            });
                            field.didChange(value);
                          },
                        );
                      },
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: _selectedCountryId == null
                        ? l10n.selectCountryFirst
                        : (isLoadingCities ? l10n.loading : l10n.selectCity),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: (_selectedCountryId == null || isLoadingCities) ? Colors.grey[200] : Colors.grey[50],
                    suffixIcon: isLoadingCities
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(FontAwesomeIcons.chevronDown),
                    errorText: field.errorText,
                  ),
                  isEmpty: displayCity == null || displayCity.isEmpty,
                  child: Text(
                    displayCity ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: displayCity == null || displayCity.isEmpty
                              ? Theme.of(context).hintColor
                              : Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }

  /// 显示选项选择器（iOS风格）
  void _showOptionPicker({
    required List<String> options,
    required String title,
    String? initialValue,
    required Function(String) onSelected,
  }) {
    Get.bottomSheet(
      Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (Get.isBottomSheetOpen == true) {
                        Get.back();
                      }
                    },
                    child: Text(
                      AppLocalizations.of(context)!.done,
                      style: const TextStyle(color: Color(0xFFFF4458)),
                    ),
                  ),
                ],
              ),
            ),
            // Picker
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  final isSelected = option == initialValue;
                  return ListTile(
                    title: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? const Color(0xFFFF4458) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            FontAwesomeIcons.check,
                            color: Color(0xFFFF4458),
                          )
                        : null,
                    onTap: () {
                      onSelected(option);
                      if (Get.isBottomSheetOpen == true) {
                        Get.back();
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
