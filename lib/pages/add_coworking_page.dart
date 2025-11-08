import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../features/city/domain/entities/city_option.dart';
import '../features/location/presentation/controllers/location_state_controller.dart';
import '../generated/app_localizations.dart';
import '../services/coworking_api_service.dart';
import '../widgets/app_toast.dart';
import 'amap_native_picker_page.dart';

/// Add Coworking Space Page
/// 添加共享办公空间页面
class AddCoworkingPage extends StatefulWidget {
  final String? cityName;
  final String? cityId;

  const AddCoworkingPage({
    super.key,
    this.cityName,
    this.cityId,
  });

  @override
  State<AddCoworkingPage> createState() => _AddCoworkingPageState();
}

class _AddCoworkingPageState extends State<AddCoworkingPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  final LocationStateController _locationController =
      Get.find<LocationStateController>();

  // Basic Info
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Selected country and city
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedCountryId;
  String? _selectedCityId;
  final GlobalKey<FormFieldState<String>> _cityFieldKey =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _countryFieldKey =
      GlobalKey<FormFieldState<String>>();

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
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // 如果从城市详情页传入了城市名称，设置为选中
    if (widget.cityName != null) {
      _selectedCity = widget.cityName;
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
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 16),
                children: [
                  // Image Upload
                  _buildImageSection(),
                  const SizedBox(height: 24),

                  // Basic Information
                  _buildSectionTitle(l10n.basicInformation, Icons.info_outline),
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
                  _buildSectionTitle(l10n.location, Icons.location_on),
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
                  _buildSectionTitle(
                      l10n.contactInformation, Icons.contact_phone),
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
                  _buildSectionTitle(l10n.pricing, Icons.attach_money),
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
                  _buildSectionTitle(l10n.specifications, Icons.settings),
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
                    [
                      l10n.noiseLevelQuiet,
                      l10n.noiseLevelModerate,
                      l10n.noiseLevelLoud
                    ],
                    (value) => setState(() => _noiseLevel = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    l10n.spaceType,
                    _spaceType,
                    [
                      l10n.spaceTypeOpen,
                      l10n.spaceTypePrivate,
                      l10n.spaceTypeMixed
                    ],
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
                  _buildSectionTitle(l10n.amenities, Icons.stars),
                  const SizedBox(height: 16),
                  _buildSwitchTile(l10n.wifi, _hasWifi,
                      (value) => setState(() => _hasWifi = value)),
                  _buildSwitchTile(l10n.freeCoffee, _hasCoffee,
                      (value) => setState(() => _hasCoffee = value)),
                  _buildSwitchTile(l10n.printer, _hasPrinter,
                      (value) => setState(() => _hasPrinter = value)),
                  _buildSwitchTile(l10n.meetingRooms, _hasMeetingRoom,
                      (value) => setState(() => _hasMeetingRoom = value)),
                  _buildSwitchTile(l10n.phoneBooth, _hasPhoneBooth,
                      (value) => setState(() => _hasPhoneBooth = value)),
                  _buildSwitchTile(l10n.kitchen, _hasKitchen,
                      (value) => setState(() => _hasKitchen = value)),
                  _buildSwitchTile(l10n.parking, _hasParking,
                      (value) => setState(() => _hasParking = value)),
                  _buildSwitchTile(l10n.locker, _hasLocker,
                      (value) => setState(() => _hasLocker = value)),
                  _buildSwitchTile(l10n.twentyFourSevenAccess, _has24HourAccess,
                      (value) => setState(() => _has24HourAccess = value)),
                  _buildSwitchTile(l10n.airConditioning, _hasAirConditioning,
                      (value) => setState(() => _hasAirConditioning = value)),
                  _buildSwitchTile(l10n.standingDesk, _hasStandingDesk,
                      (value) => setState(() => _hasStandingDesk = value)),
                  _buildSwitchTile(l10n.shower, _hasShower,
                      (value) => setState(() => _hasShower = value)),
                  _buildSwitchTile(l10n.bikeStorage, _hasBike,
                      (value) => setState(() => _hasBike = value)),
                  _buildSwitchTile(l10n.eventSpace, _hasEventSpace,
                      (value) => setState(() => _hasEventSpace = value)),
                  _buildSwitchTile(l10n.petFriendly, _hasPetFriendly,
                      (value) => setState(() => _hasPetFriendly = value)),

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
        leading: const Icon(Icons.map, color: Color(0xFFFF4458)),
        title: _latitude != 0 && _longitude != 0
            ? Text(l10n.locationCoordinates(
                _latitude.toStringAsFixed(6),
                _longitude.toStringAsFixed(6),
              ))
            : Text(l10n.pickLocationOnMap),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          final result = await Get.to(() => const AmapNativePickerPage());
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _latitude = result['latitude'] ?? 0.0;
              _longitude = result['longitude'] ?? 0.0;
              if (result['address'] != null) {
                _addressController.text = result['address'];
              }
            });
          }
        },
      ),
    );
  }

  Widget _buildImageSection() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: _selectedImage != null
            ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black54,
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  Text(
                    l10n.addCoverPhoto,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.tapToChoosePhoto,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _showImageSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.chooseImageSource,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.accent),
                  title: Text(
                    l10n.photoLibrary,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.accent),
                  title: Text(
                    l10n.camera,
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      AppToast.error(
        l10n.failedToPickImage(e.toString()),
        title: l10n.error,
      );
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
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 20),
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
      // 构建 amenities 列表
      final amenities = <String>[];
      if (_hasWifi) amenities.add('wifi');
      if (_hasCoffee) amenities.add('coffee');
      if (_hasPrinter) amenities.add('printer');
      if (_hasMeetingRoom) amenities.add('meeting_room');
      if (_hasPhoneBooth) amenities.add('phone_booth');
      if (_hasKitchen) amenities.add('kitchen');
      if (_hasParking) amenities.add('parking');
      if (_hasLocker) amenities.add('locker');
      if (_has24HourAccess) amenities.add('24h_access');
      if (_hasAirConditioning) amenities.add('air_conditioning');
      if (_hasStandingDesk) amenities.add('standing_desk');
      if (_hasShower) amenities.add('shower');
      if (_hasBike) amenities.add('bike');
      if (_hasEventSpace) amenities.add('event_space');
      if (_hasPetFriendly) amenities.add('pet_friendly');

      // 创建请求对象(使用 Map,因为拦截器会自动解包)
      final request = <String, dynamic>{
        'name': _nameController.text,
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text,
        'address': _addressController.text,
        'cityId': _selectedCityId,
        // 只有在用户真正设置了位置时才发送坐标(非 0 值)
        if (_latitude != 0.0) 'latitude': _latitude,
        if (_longitude != 0.0) 'longitude': _longitude,
        if (_dailyRateController.text.isNotEmpty)
          'pricePerDay': double.tryParse(_dailyRateController.text),
        if (_monthlyRateController.text.isNotEmpty)
          'pricePerMonth': double.tryParse(_monthlyRateController.text),
        if (_hourlyRateController.text.isNotEmpty)
          'pricePerHour': double.tryParse(_hourlyRateController.text),
        'currency': _currency,
        if (_wifiSpeedController.text.isNotEmpty)
          'wifiSpeed': double.tryParse(_wifiSpeedController.text),
        'hasMeetingRoom': _hasMeetingRoom,
        'hasCoffee': _hasCoffee,
        'hasParking': _hasParking,
        'has247Access': _has24HourAccess,
        if (amenities.isNotEmpty) 'amenities': amenities,
        if (_capacityController.text.isNotEmpty)
          'capacity': int.tryParse(_capacityController.text),
        if (_selectedImage != null)
          'imageUrl': _selectedImage!.path, // TODO: 上传图片到 Supabase Storage
        if (_phoneController.text.isNotEmpty) 'phone': _phoneController.text,
        if (_emailController.text.isNotEmpty) 'email': _emailController.text,
        if (_websiteController.text.isNotEmpty)
          'website': _websiteController.text,
        if (_openingHours.isNotEmpty) 'openingHours': _openingHours.join(', '),
      };

      // 调用真实 API(拦截器已自动解包 ApiResponse)
      final apiService = CoworkingApiService();
      await apiService.createCoworkingSpace(request);

      // 返回结果,传递 true 表示需要刷新数据
      Navigator.pop(context, true);
      AppToast.success(
        l10n.coworkingSubmittedSuccess,
        title: l10n.success,
      );
    } catch (e) {
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
          final isLoadingCountries =
              _locationController.isLoadingCountries.value;
          final localeCode =
              Localizations.localeOf(context).languageCode.toLowerCase();

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
                      final selectedEntry = countryEntries
                          .firstWhereOrNull((entry) => entry.value == value);
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

                      _locationController
                          .loadCitiesByCountry(selectedEntry.key.id);
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
                        : const Icon(Icons.keyboard_arrow_down),
                    errorText: field.errorText,
                  ),
                  isEmpty: displayCountry == null || displayCountry.isEmpty,
                  child: Text(
                    displayCountry ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: displayCountry == null ||
                                  displayCountry.isEmpty
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
          final cachedCities = selectedCountryId == null
              ? const <CityOption>[]
              : (cityMap[selectedCountryId] ?? const <CityOption>[]);

          final cachedCityNames = cachedCities
              .map((city) => city.name)
              .where((name) => name.isNotEmpty)
              .toSet()
              .toList()
            ..sort();

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
              final isLoadingCities =
                  _locationController.isLoadingCities.value;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (_selectedCountryId == null) {
                    AppToast.info(
                      l10n.selectCountryFirst,
                      title: l10n.notice,
                    );
                    return;
                  }

                  if (isLoadingCities) {
                    AppToast.info(l10n.loading, title: l10n.notice);
                    return;
                  }

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
                      final selectedCity = cachedCities
                          .firstWhereOrNull((city) => city.name == value);

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
                    hintText: l10n.selectCity,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: isLoadingCities
                        ? const Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.keyboard_arrow_down),
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
                      Get.back();
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
                        color: isSelected
                            ? const Color(0xFFFF4458)
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Color(0xFFFF4458),
                          )
                        : null,
                    onTap: () {
                      onSelected(option);
                      Get.back();
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
