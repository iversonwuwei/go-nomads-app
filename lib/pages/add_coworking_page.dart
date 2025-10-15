import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../generated/app_localizations.dart';
import '../models/coworking_space_model.dart';
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

  // Basic Info
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    if (widget.cityName != null) {
      _cityController.text = widget.cityName!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Add Coworking Space',
          style: TextStyle(
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
                  _buildSectionTitle('Basic Information', Icons.info_outline),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _nameController,
                    label: 'Space Name',
                    hint: 'e.g., WeWork Times Square',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _descriptionController,
                    label: 'Description',
                    hint: 'Describe the coworking space...',
                    maxLines: 4,
                    required: true,
                  ),

                  const SizedBox(height: 32),

                  // Location
                  _buildSectionTitle('Location', Icons.location_on),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    hint: '1460 Broadway',
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'New York',
                          required: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _countryController,
                          label: 'Country',
                          hint: 'USA',
                          required: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLocationPicker(),

                  const SizedBox(height: 32),

                  // Contact Information
                  _buildSectionTitle(
                      'Contact Information', Icons.contact_phone),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone',
                    hint: '+1 234 567 8900',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'contact@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _websiteController,
                    label: 'Website',
                    hint: 'https://example.com',
                    keyboardType: TextInputType.url,
                  ),

                  const SizedBox(height: 32),

                  // Pricing
                  _buildSectionTitle('Pricing', Icons.attach_money),
                  const SizedBox(height: 16),
                  _buildCurrencyDropdown(),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _hourlyRateController,
                          label: 'Hourly Rate',
                          hint: '10',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _dailyRateController,
                          label: 'Daily Rate',
                          hint: '50',
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
                          label: 'Weekly Rate',
                          hint: '200',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _monthlyRateController,
                          label: 'Monthly Rate',
                          hint: '500',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Free Trial Available',
                    _hasFreeTrial,
                    (value) => setState(() => _hasFreeTrial = value),
                  ),
                  if (_hasFreeTrial) ...[
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _trialDurationController,
                      label: 'Trial Duration',
                      hint: '1 day, 1 week, etc.',
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Specifications
                  _buildSectionTitle('Specifications', Icons.settings),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _wifiSpeedController,
                          label: 'WiFi Speed (Mbps)',
                          hint: '500',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _capacityController,
                          label: 'Capacity',
                          hint: '50',
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
                          label: 'Number of Desks',
                          hint: '30',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _numberOfMeetingRoomsController,
                          label: 'Meeting Rooms',
                          hint: '5',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Noise Level',
                    _noiseLevel,
                    ['Quiet', 'Moderate', 'Loud'],
                    (value) => setState(() => _noiseLevel = value),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    'Space Type',
                    _spaceType,
                    ['Open', 'Private', 'Mixed'],
                    (value) => setState(() => _spaceType = value),
                  ),
                  const SizedBox(height: 16),
                  _buildSwitchTile(
                    'Natural Light',
                    _hasNaturalLight,
                    (value) => setState(() => _hasNaturalLight = value),
                  ),

                  const SizedBox(height: 32),

                  // Amenities
                  _buildSectionTitle('Amenities', Icons.stars),
                  const SizedBox(height: 16),
                  _buildSwitchTile('WiFi', _hasWifi,
                      (value) => setState(() => _hasWifi = value)),
                  _buildSwitchTile('Free Coffee', _hasCoffee,
                      (value) => setState(() => _hasCoffee = value)),
                  _buildSwitchTile('Printer', _hasPrinter,
                      (value) => setState(() => _hasPrinter = value)),
                  _buildSwitchTile('Meeting Rooms', _hasMeetingRoom,
                      (value) => setState(() => _hasMeetingRoom = value)),
                  _buildSwitchTile('Phone Booth', _hasPhoneBooth,
                      (value) => setState(() => _hasPhoneBooth = value)),
                  _buildSwitchTile('Kitchen', _hasKitchen,
                      (value) => setState(() => _hasKitchen = value)),
                  _buildSwitchTile('Parking', _hasParking,
                      (value) => setState(() => _hasParking = value)),
                  _buildSwitchTile('Locker', _hasLocker,
                      (value) => setState(() => _hasLocker = value)),
                  _buildSwitchTile('24/7 Access', _has24HourAccess,
                      (value) => setState(() => _has24HourAccess = value)),
                  _buildSwitchTile('Air Conditioning', _hasAirConditioning,
                      (value) => setState(() => _hasAirConditioning = value)),
                  _buildSwitchTile('Standing Desk', _hasStandingDesk,
                      (value) => setState(() => _hasStandingDesk = value)),
                  _buildSwitchTile('Shower', _hasShower,
                      (value) => setState(() => _hasShower = value)),
                  _buildSwitchTile('Bike Storage', _hasBike,
                      (value) => setState(() => _hasBike = value)),
                  _buildSwitchTile('Event Space', _hasEventSpace,
                      (value) => setState(() => _hasEventSpace = value)),
                  _buildSwitchTile('Pet Friendly', _hasPetFriendly,
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
                return 'This field is required';
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

  Widget _buildCurrencyDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _currency,
      decoration: InputDecoration(
        labelText: 'Currency',
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
            ? Text(
                'Location: ${_latitude.toStringAsFixed(6)}, ${_longitude.toStringAsFixed(6)}')
            : const Text('Pick Location on Map'),
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
                    'Add Cover Photo',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to choose from gallery or camera',
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
                const Text(
                  'Choose Image Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.photo_library, color: AppColors.accent),
                  title: const Text(
                    'Photo Library',
                    style: TextStyle(fontSize: 16),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, color: AppColors.accent),
                  title: const Text(
                    'Camera',
                    style: TextStyle(fontSize: 16),
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
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
      );
    }
  }

  /// 底部提交按钮栏
  Widget _buildBottomBar() {
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
              onPressed: _isSubmitting.value ? null : _submitCoworking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor:
                    const Color(0xFFFF4458).withValues(alpha: 0.5),
              ),
              child: _isSubmitting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Submit Coworking Space',
                          style: TextStyle(
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      // Create CoworkingSpace object
      final coworkingSpace = CoworkingSpace(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        address: _addressController.text,
        city: _cityController.text,
        country: _countryController.text,
        latitude: _latitude,
        longitude: _longitude,
        imageUrl: _selectedImage?.path ?? '',
        description: _descriptionController.text,
        pricing: CoworkingPricing(
          hourlyRate: _hourlyRateController.text.isNotEmpty
              ? double.tryParse(_hourlyRateController.text)
              : null,
          dailyRate: _dailyRateController.text.isNotEmpty
              ? double.tryParse(_dailyRateController.text)
              : null,
          weeklyRate: _weeklyRateController.text.isNotEmpty
              ? double.tryParse(_weeklyRateController.text)
              : null,
          monthlyRate: _monthlyRateController.text.isNotEmpty
              ? double.tryParse(_monthlyRateController.text)
              : null,
          currency: _currency,
          hasFreeTrial: _hasFreeTrial,
          trialDuration: _hasFreeTrial ? _trialDurationController.text : null,
        ),
        amenities: CoworkingAmenities(
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
        specs: CoworkingSpecs(
          wifiSpeed: _wifiSpeedController.text.isNotEmpty
              ? double.tryParse(_wifiSpeedController.text)
              : null,
          numberOfDesks: _numberOfDesksController.text.isNotEmpty
              ? int.tryParse(_numberOfDesksController.text)
              : null,
          numberOfMeetingRooms: _numberOfMeetingRoomsController.text.isNotEmpty
              ? int.tryParse(_numberOfMeetingRoomsController.text)
              : null,
          capacity: _capacityController.text.isNotEmpty
              ? int.tryParse(_capacityController.text)
              : null,
          noiseLevel: _noiseLevel?.toLowerCase(),
          hasNaturalLight: _hasNaturalLight,
          spaceType: _spaceType?.toLowerCase(),
        ),
        phone: _phoneController.text,
        email: _emailController.text,
        website: _websiteController.text,
        openingHours: _openingHours,
        lastUpdated: DateTime.now(),
      );

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Show success message
      Get.back(result: coworkingSpace);
      Get.snackbar(
        'Success',
        'Coworking space has been submitted successfully!',
        backgroundColor: const Color(0xFFFF4458),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit coworking space: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }
}
