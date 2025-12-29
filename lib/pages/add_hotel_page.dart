import 'dart:developer';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/config/supabase_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/hotel/domain/entities/hotel.dart';
import 'package:df_admin_mobile/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:df_admin_mobile/features/location/presentation/controllers/location_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/http_service.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/utils/image_upload_helper.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/location_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import 'flutter_map_picker_page.dart';

/// Add/Edit Hotel Page - 添加或编辑酒店页面
/// 为数字游民提供酒店信息录入功能
class AddHotelPage extends StatefulWidget {
  final String? cityName;
  final String? cityId;
  final String? countryName;

  /// 编辑模式：传入要编辑的 Hotel
  final Hotel? editingHotel;

  const AddHotelPage({
    super.key,
    this.cityName,
    this.cityId,
    this.countryName,
    this.editingHotel,
  });

  /// 是否是编辑模式
  bool get isEditMode => editingHotel != null;

  @override
  State<AddHotelPage> createState() => _AddHotelPageState();
}

class _AddHotelPageState extends State<AddHotelPage> {
  final _formKey = GlobalKey<FormState>();
  final RxBool _isSubmitting = false.obs;

  late final LocationStateController _locationController;
  final HotelRepository _hotelRepository = HotelRepository(HttpService());

  // ============ 基本信息 ============
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();

  // ============ 位置信息 ============
  String? _selectedCountry;
  String? _selectedCity;
  String? _selectedCountryId;
  String? _selectedCityId;
  double _latitude = 0.0;
  double _longitude = 0.0;

  // ============ 联系方式 ============
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();

  // ============ 价格信息 ============
  final _pricePerNightController = TextEditingController();
  String _currency = 'USD';

  // ============ 数字游民特性 ============
  final _wifiSpeedController = TextEditingController();
  bool _hasWifi = true;
  bool _hasWorkDesk = false;
  bool _hasAirConditioning = false;
  bool _hasKitchen = false;
  bool _hasLaundry = false;
  bool _hasParking = false;
  bool _hasPool = false;
  bool _hasGym = false;
  bool _has24HourReception = false;
  bool _hasLongStayDiscount = false;
  bool _isPetFriendly = false;
  bool _hasCoworkingSpace = false;

  // ============ 图片 ============
  static const int maxHotelImages = 5;
  final List<String> _hotelImageUrls = [];
  bool _isUploadingImages = false;
  String? _imageUploadStatus;
  final ImageUploadService _imageUploadService = ImageUploadService();

  // ============ 房型列表 ============
  final List<Map<String, dynamic>> _roomTypes = [];

  int get _remainingImageSlots => maxHotelImages - _hotelImageUrls.length;
  String get _imageUploadBucket => SupabaseConfig.buckets['hotelPhotos'] ?? SupabaseConfig.defaultBucket;
  String get _imageUploadFolder => 'hotels/${_selectedCityId ?? 'general'}';

  @override
  void initState() {
    super.initState();
    _locationController = Get.find<LocationStateController>();
    _initializeFromParams();

    // 如果是编辑模式，填充现有数据
    if (widget.isEditMode) {
      log('✏️ [AddHotel] 编辑模式 - 填充现有数据');
      _fillFormWithExistingData(widget.editingHotel!);
    }
  }

  void _initializeFromParams() {
    log('🏨 [AddHotel] _initializeFromParams:');
    log('   widget.cityId: "${widget.cityId}" (type: ${widget.cityId.runtimeType})');
    log('   widget.cityName: "${widget.cityName}"');
    log('   widget.countryName: "${widget.countryName}"');

    if (widget.cityId != null && widget.cityId!.isNotEmpty) {
      _selectedCityId = widget.cityId;
      _selectedCity = widget.cityName;
      _selectedCountry = widget.countryName;
      log('🏨 [AddHotel] ✅ 已设置城市: $_selectedCity (ID: $_selectedCityId), 国家: $_selectedCountry');
    } else {
      log('🏨 [AddHotel] ⚠️ cityId 为空，未设置城市');
    }
  }

  /// 编辑模式：用现有数据填充表单
  void _fillFormWithExistingData(Hotel hotel) {
    // 基本信息
    _nameController.text = hotel.name;
    _descriptionController.text = hotel.description;
    _addressController.text = hotel.address;

    // 位置信息
    _selectedCityId = hotel.cityId;
    _selectedCity = hotel.cityName;
    _selectedCountry = hotel.country;
    _latitude = hotel.latitude;
    _longitude = hotel.longitude;

    // 联系方式
    _phoneController.text = hotel.phone ?? '';
    _emailController.text = hotel.email ?? '';
    _websiteController.text = hotel.website ?? '';

    // 价格信息
    _pricePerNightController.text = hotel.pricePerNight.toString();
    _currency = hotel.currency;

    // 数字游民特性
    if (hotel.wifiSpeed != null) _wifiSpeedController.text = hotel.wifiSpeed.toString();
    _hasWifi = hotel.hasWifi;
    _hasWorkDesk = hotel.hasWorkDesk;
    _hasAirConditioning = hotel.hasAirConditioning;
    _hasKitchen = hotel.hasKitchen;
    _hasLaundry = hotel.hasLaundry;
    _hasParking = hotel.hasParking;
    _hasPool = hotel.hasPool;
    _hasGym = hotel.hasGym;
    _has24HourReception = hotel.has24HReception;
    _hasLongStayDiscount = hotel.hasLongStayDiscount;
    _isPetFriendly = hotel.isPetFriendly;
    _hasCoworkingSpace = hotel.hasCoworkingSpace;

    // 图片
    _hotelImageUrls.addAll(hotel.images);

    // 房型
    for (final room in hotel.roomTypes) {
      _roomTypes.add({
        'id': room.id, // 保存房型ID，用于更新时识别
        'name': room.name,
        'description': room.description,
        'pricePerNight': room.pricePerNight,
        'currency': room.currency,
        'roomSize': room.size, // 使用 roomSize 匹配后端
        'maxOccupancy': room.maxOccupancy,
        'bedType': room.bedType,
        'availableRooms': room.availableRooms,
        'isAvailable': room.isAvailable,
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _pricePerNightController.dispose();
    _wifiSpeedController.dispose();
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
        leading: const AppBackButton(),
        title: Text(
          widget.isEditMode ? l10n.editHotel : l10n.addHotel,
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
                padding: const EdgeInsets.all(16),
                children: [
                  _buildImageSection(l10n),
                  const SizedBox(height: 24),
                  _buildBasicInfoSection(l10n),
                  const SizedBox(height: 24),
                  _buildLocationSection(l10n),
                  const SizedBox(height: 24),
                  _buildContactSection(l10n),
                  const SizedBox(height: 24),
                  _buildPricingSection(l10n),
                  const SizedBox(height: 24),
                  _buildRoomTypesSection(l10n),
                  const SizedBox(height: 24),
                  _buildNomadFeaturesSection(l10n),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          _buildBottomBar(l10n),
        ],
      ),
    );
  }

  // ============ UI 构建方法将在后续任务中添加 ============

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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.isEmpty) return l10n.thisFieldIsRequired;
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

  // 占位方法，将在后续任务中实现
  Widget _buildImageSection(AppLocalizations l10n) {
    final canAddMore = _remainingImageSlots > 0;
    final hasImages = _hotelImageUrls.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.addCoverPhoto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('${_hotelImageUrls.length}/$maxHotelImages', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 12),
        if (hasImages)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ..._hotelImageUrls.asMap().entries.map((e) => _buildImageTile(e.value, e.key)),
              if (canAddMore) _buildAddImageTile(l10n),
            ],
          )
        else
          _buildAddImageTile(l10n, fullWidth: true),
        if (_isUploadingImages) ...[
          const SizedBox(height: 12),
          Row(children: [
            const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(_imageUploadStatus ?? 'Uploading...'),
          ]),
        ],
      ],
    );
  }

  Widget _buildImageTile(String url, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 120,
            height: 120,
            color: Colors.grey[200],
            child:
                Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(FontAwesomeIcons.image)),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: IconButton(
            onPressed: () => _removeImageAt(index),
            icon: const Icon(FontAwesomeIcons.xmark, size: 18, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: const EdgeInsets.all(4)),
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
            Text(l10n.tapToChoosePhoto,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageOptions() async {
    final l10n = AppLocalizations.of(context)!;
    if (_remainingImageSlots <= 0) {
      AppToast.info(l10n.maxPhotosReached(10));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
              leading: const Icon(FontAwesomeIcons.images),
              title: Text(l10n.photoLibrary),
              onTap: () {
                Navigator.pop(ctx);
                _addImagesFromGallery();
              }),
          ListTile(
              leading: const Icon(FontAwesomeIcons.camera),
              title: Text(l10n.camera),
              onTap: () {
                Navigator.pop(ctx);
                _addImageFromCamera();
              }),
          ListTile(
              leading: const Icon(FontAwesomeIcons.xmark), title: Text(l10n.cancel), onTap: () => Navigator.pop(ctx)),
        ]),
      ),
    );
  }

  Future<void> _addImagesFromGallery() async {
    setState(() {
      _isUploadingImages = true;
      _imageUploadStatus = null;
    });
    try {
      final urls = await ImageUploadHelper.pickMultipleAndUpload(
        bucket: _imageUploadBucket,
        folder: _imageUploadFolder,
        maxImages: _remainingImageSlots,
        onProgress: (c, t) => setState(() => _imageUploadStatus = 'Uploading $c / $t'),
      );
      if (urls.isNotEmpty) setState(() => _hotelImageUrls.addAll(urls));
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      setState(() {
        _isUploadingImages = false;
        _imageUploadStatus = null;
      });
    }
  }

  Future<void> _addImageFromCamera() async {
    setState(() {
      _isUploadingImages = true;
    });
    try {
      final url = await ImageUploadHelper.captureAndUpload(bucket: _imageUploadBucket, folder: _imageUploadFolder);
      if (url != null) setState(() => _hotelImageUrls.add(url));
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      setState(() {
        _isUploadingImages = false;
      });
    }
  }

  Future<void> _removeImageAt(int index) async {
    if (index < 0 || index >= _hotelImageUrls.length) return;
    final url = _hotelImageUrls[index];
    setState(() => _hotelImageUrls.removeAt(index));
    try {
      await _imageUploadService.deleteImage(imageUrl: url, bucket: _imageUploadBucket);
    } catch (e) {
      log('Failed to delete image: $e');
    }
  }

  Widget _buildBasicInfoSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nameController,
          label: l10n.hotelName,
          hint: l10n.hotelNameHint,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: l10n.description,
          hint: l10n.hotelDescriptionHint,
          maxLines: 4,
          required: true,
        ),
      ],
    );
  }

  Widget _buildLocationSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.location, FontAwesomeIcons.locationDot),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _addressController,
          label: l10n.address,
          hint: l10n.addressHint,
          required: true,
        ),
        const SizedBox(height: 16),
        LocationPickerField(
          locationController: _locationController,
          initialCountryId: _selectedCountryId,
          initialCountryName: _selectedCountry,
          initialCityId: _selectedCityId,
          initialCityName: _selectedCity,
          required: true,
          enabled: widget.cityId == null,
          label: l10n.city,
          onChanged: (result) {
            setState(() {
              _selectedCountryId = result.countryId;
              _selectedCountry = result.countryName;
              _selectedCityId = result.cityId;
              _selectedCity = result.cityName;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildLocationPicker(l10n),
      ],
    );
  }

  Widget _buildLocationPicker(AppLocalizations l10n) {
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
          final result = await Get.to(() => FlutterMapPickerPage(
                initialLatitude: _latitude != 0 ? _latitude : null,
                initialLongitude: _longitude != 0 ? _longitude : null,
                searchQuery: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
                country: _selectedCountry,
                city: _selectedCity,
              ));

          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              _latitude = result['latitude'] ?? 0.0;
              _longitude = result['longitude'] ?? 0.0;
            });
          }
        },
      ),
    );
  }

  Widget _buildContactSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildPricingSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.pricing, FontAwesomeIcons.dollarSign),
        const SizedBox(height: 16),
        _buildCurrencyDropdown(l10n),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _pricePerNightController,
          label: l10n.pricePerNight,
          hint: l10n.pricePerNightHint,
          keyboardType: TextInputType.number,
          required: true,
        ),
        const SizedBox(height: 16),
        _buildSwitchTile(
          l10n.longStayDiscount,
          _hasLongStayDiscount,
          (value) => setState(() => _hasLongStayDiscount = value),
        ),
      ],
    );
  }

  // ============ 房型管理区域 ============
  Widget _buildRoomTypesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('房型管理', FontAwesomeIcons.bed),
            TextButton.icon(
              onPressed: _showAddRoomTypeDialog,
              icon: const Icon(FontAwesomeIcons.plus, size: 14),
              label: const Text('添加房型'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '添加不同的房型及价格（可选）',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        if (_roomTypes.isEmpty)
          Card(
            elevation: 0,
            color: Colors.grey[50],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey[300]!),
            ),
            child: const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(FontAwesomeIcons.bed, size: 32, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('暂无房型', style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('点击上方按钮添加房型', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          )
        else
          ...List.generate(_roomTypes.length, (index) => _buildRoomTypeCard(index)),
      ],
    );
  }

  Widget _buildRoomTypeCard(int index) {
    final room = _roomTypes[index];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    room['name'] ?? '未命名房型',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.penToSquare, size: 16),
                      onPressed: () => _showEditRoomTypeDialog(index),
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: const Icon(FontAwesomeIcons.trash, size: 16),
                      onPressed: () => _removeRoomType(index),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                _buildRoomInfoChip(Icons.attach_money, '${room['currency']} ${room['pricePerNight']}/晚'),
                const SizedBox(width: 8),
                _buildRoomInfoChip(Icons.people, '最多${room['maxOccupancy']}人'),
                const SizedBox(width: 8),
                _buildRoomInfoChip(Icons.square_foot, '${room['size']}㎡'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoomInfoChip(Icons.bed, room['bedType'] ?? 'Double'),
                const SizedBox(width: 8),
                _buildRoomInfoChip(Icons.meeting_room, '${room['availableRooms']}间'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showAddRoomTypeDialog() {
    _showRoomTypeDialog();
  }

  void _showEditRoomTypeDialog(int index) {
    _showRoomTypeDialog(editIndex: index);
  }

  void _showRoomTypeDialog({int? editIndex}) {
    final isEdit = editIndex != null;
    final room = isEdit ? _roomTypes[editIndex] : <String, dynamic>{};

    final nameController = TextEditingController(text: room['name'] ?? '');
    final descController = TextEditingController(text: room['description'] ?? '');
    final priceController = TextEditingController(text: room['pricePerNight']?.toString() ?? '');
    final sizeController = TextEditingController(text: (room['roomSize'] ?? room['size'])?.toString() ?? '25');
    final maxOccupancyController = TextEditingController(text: room['maxOccupancy']?.toString() ?? '2');
    final availableRoomsController = TextEditingController(text: room['availableRooms']?.toString() ?? '1');
    String selectedBedType = room['bedType'] ?? 'Double';
    String selectedCurrency = room['currency'] ?? _currency;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? '编辑房型' : '添加房型'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '房型名称 *',
                    hintText: '例如：标准双人间',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: '房型描述',
                    hintText: '房间设施、特色等',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: '每晚价格 *',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCurrency,
                        decoration: const InputDecoration(labelText: '货币'),
                        items: ['USD', 'EUR', 'CNY', 'THB', 'VND', 'IDR']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedCurrency = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        decoration: const InputDecoration(
                          labelText: '面积(㎡)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: maxOccupancyController,
                        decoration: const InputDecoration(
                          labelText: '最大入住',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedBedType,
                        decoration: const InputDecoration(labelText: '床型'),
                        items: ['Single', 'Double', 'Queen', 'King', 'Twin', 'Bunk']
                            .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedBedType = v!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: availableRoomsController,
                        decoration: const InputDecoration(
                          labelText: '可用房间数',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  AppToast.error('请输入房型名称');
                  return;
                }
                if (priceController.text.trim().isEmpty) {
                  AppToast.error('请输入每晚价格');
                  return;
                }

                final roomData = <String, dynamic>{
                  'name': nameController.text.trim(),
                  'description': descController.text.trim(),
                  'pricePerNight': double.tryParse(priceController.text) ?? 0,
                  'currency': selectedCurrency,
                  'roomSize': double.tryParse(sizeController.text) ?? 25,
                  'maxOccupancy': int.tryParse(maxOccupancyController.text) ?? 2,
                  'bedType': selectedBedType,
                  'availableRooms': int.tryParse(availableRoomsController.text) ?? 1,
                  'isAvailable': true,
                };

                // 编辑模式下保留原有的id
                if (isEdit && room['id'] != null) {
                  roomData['id'] = room['id'];
                }

                setState(() {
                  if (isEdit) {
                    _roomTypes[editIndex] = roomData;
                  } else {
                    _roomTypes.add(roomData);
                  }
                });

                Navigator.pop(context);
                AppToast.success(isEdit ? '房型已更新' : '房型已添加');
              },
              child: Text(isEdit ? '保存' : '添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _removeRoomType(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除房型 "${_roomTypes[index]['name']}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _roomTypes.removeAt(index));
              Navigator.pop(context);
              AppToast.success('房型已删除');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<String>(
      initialValue: _currency,
      decoration: InputDecoration(
        labelText: l10n.currency,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'THB', 'VND', 'IDR', 'MYR', 'SGD']
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (value) => setState(() => _currency = value!),
    );
  }

  Widget _buildNomadFeaturesSection(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.nomadFeatures, FontAwesomeIcons.laptopCode),
        const SizedBox(height: 8),
        Text(
          l10n.nomadFeaturesSubtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _wifiSpeedController,
          label: l10n.wifiSpeed,
          hint: l10n.wifiSpeedHint,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        _buildSwitchTile(l10n.wifi, _hasWifi, (v) => setState(() => _hasWifi = v)),
        _buildSwitchTile(l10n.workDesk, _hasWorkDesk, (v) => setState(() => _hasWorkDesk = v)),
        _buildSwitchTile(l10n.hasCoworkingSpace, _hasCoworkingSpace, (v) => setState(() => _hasCoworkingSpace = v)),
        _buildSwitchTile(l10n.airConditioning, _hasAirConditioning, (v) => setState(() => _hasAirConditioning = v)),
        _buildSwitchTile(l10n.kitchen, _hasKitchen, (v) => setState(() => _hasKitchen = v)),
        _buildSwitchTile(l10n.laundry, _hasLaundry, (v) => setState(() => _hasLaundry = v)),
        _buildSwitchTile(l10n.parking, _hasParking, (v) => setState(() => _hasParking = v)),
        _buildSwitchTile(l10n.pool, _hasPool, (v) => setState(() => _hasPool = v)),
        _buildSwitchTile(l10n.gym, _hasGym, (v) => setState(() => _hasGym = v)),
        _buildSwitchTile(
            l10n.twentyFourHourReception, _has24HourReception, (v) => setState(() => _has24HourReception = v)),
        _buildSwitchTile(l10n.petFriendly, _isPetFriendly, (v) => setState(() => _isPetFriendly = v)),
      ],
    );
  }

  Widget _buildBottomBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
              onPressed: _isSubmitting.value ? null : _submitHotel,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _isSubmitting.value
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Icon(widget.isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.circleCheck, size: 20),
                  const SizedBox(width: 8),
                  Text(widget.isEditMode ? l10n.save : l10n.submitHotel,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            )),
      ),
    );
  }

  Future<void> _submitHotel() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    if (_selectedCityId == null || _selectedCityId!.isEmpty) {
      AppToast.error(l10n.selectCity);
      return;
    }

    _isSubmitting.value = true;

    try {
      // 构建酒店数据 - 使用 camelCase 匹配后端 API
      final hotelData = {
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'address': _addressController.text.trim(),
        'cityId': _selectedCityId,
        'cityName': _selectedCity ?? '',
        'country': _selectedCountry ?? '',
        'latitude': _latitude,
        'longitude': _longitude,
        'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        'website': _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        'pricePerNight': double.tryParse(_pricePerNightController.text) ?? 0,
        'currency': _currency,
        'wifiSpeed': int.tryParse(_wifiSpeedController.text),
        'hasWifi': _hasWifi,
        'hasWorkDesk': _hasWorkDesk,
        'hasCoworkingSpace': _hasCoworkingSpace,
        'hasAirConditioning': _hasAirConditioning,
        'hasKitchen': _hasKitchen,
        'hasLaundry': _hasLaundry,
        'hasParking': _hasParking,
        'hasPool': _hasPool,
        'hasGym': _hasGym,
        'has24HReception': _has24HourReception,
        'hasLongStayDiscount': _hasLongStayDiscount,
        'isPetFriendly': _isPetFriendly,
        'images': _hotelImageUrls,
        'roomTypes': _roomTypes,
      };

      log('📤 ${widget.isEditMode ? "Updating" : "Submitting"} hotel: $hotelData');

      // 调用后端 API 创建或更新酒店
      Result<Hotel> result;
      if (widget.isEditMode) {
        result = await _hotelRepository.updateHotel(widget.editingHotel!.id, hotelData);
      } else {
        result = await _hotelRepository.createHotel(hotelData);
      }

      result.onSuccess((hotel) {
        log('✅ 酒店${widget.isEditMode ? "更新" : "创建"}成功: ${hotel.id}');
        AppToast.success(widget.isEditMode ? l10n.updateSuccess : l10n.hotelSubmittedSuccess);
        Navigator.pop(context, true);
      }).onFailure((exception) {
        log('❌ 酒店${widget.isEditMode ? "更新" : "创建"}失败: ${exception.message}');
        AppToast.error('${l10n.failedToSubmitHotel}: ${exception.message}');
      });
    } catch (e) {
      log('❌ 酒店创建异常: $e');
      AppToast.error('${l10n.failedToSubmitHotel}: $e');
    } finally {
      _isSubmitting.value = false;
    }
  }
}
