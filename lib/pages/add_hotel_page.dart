import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/app_colors.dart';
import 'package:go_nomads_app/controllers/add_hotel_page_controller.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/pages/map_picker/map_picker_page.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:go_nomads_app/widgets/back_button.dart';
import 'package:go_nomads_app/widgets/location_picker_field.dart';

class AddHotelPage extends StatelessWidget {
  final String? cityName;
  final String? cityId;
  final String? countryName;
  final Hotel? editingHotel;

  const AddHotelPage({
    super.key,
    this.cityName,
    this.cityId,
    this.countryName,
    this.editingHotel,
  });

  bool get isEditMode => editingHotel != null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = _useController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          isEditMode ? l10n.editHotel : l10n.addHotel,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: controller.formKey,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildImageSection(controller, l10n),
                  SizedBox(height: 24.h),
                  _buildBasicInfoSection(controller, l10n),
                  SizedBox(height: 24.h),
                  _buildLocationSection(controller, l10n),
                  SizedBox(height: 24.h),
                  _buildContactSection(controller, l10n),
                  SizedBox(height: 24.h),
                  _buildPricingSection(controller, l10n),
                  SizedBox(height: 24.h),
                  _buildRoomTypesSection(controller),
                  SizedBox(height: 24.h),
                  _buildNomadFeaturesSection(controller, l10n),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          _buildBottomBar(controller, l10n),
        ],
      ),
    );
  }

  AddHotelPageController _useController() {
    final tag = 'AddHotelPage_${editingHotel?.id ?? cityId ?? cityName ?? 'new'}';
    return Get.put(
      AddHotelPageController(
        cityId: cityId,
        cityName: cityName,
        countryName: countryName,
        editingHotel: editingHotel,
      ),
      tag: tag,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFF4458), size: 24.r),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
    final l10n = AppLocalizations.of(Get.context!)!;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
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

  Widget _buildSwitchTile(String title, RxBool value, void Function(bool) onChanged) {
    return Obx(() {
      return SwitchListTile(
        title: Text(title),
        value: value.value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFFF4458),
        contentPadding: EdgeInsets.zero,
      );
    });
  }

  // ============ 图片 ============
  Widget _buildImageSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Obx(() {
      final canAddMore = controller.remainingImageSlots > 0;
      final hasImages = controller.hotelImageUrls.isNotEmpty;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.addCoverPhoto, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              Text([controller.hotelImageUrls.length, AddHotelPageController.maxHotelImages].join('/'),
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
            ],
          ),
          SizedBox(height: 12.h),
          if (hasImages)
            Wrap(
              spacing: 12.w,
              runSpacing: 12.w,
              children: [
                ...controller.hotelImageUrls.asMap().entries.map((e) => _buildImageTile(controller, e.value, e.key)),
                if (canAddMore) _buildAddImageTile(controller, l10n),
              ],
            )
          else
            _buildAddImageTile(controller, l10n, fullWidth: true),
          if (controller.isUploadingImages.value) ...[
            SizedBox(height: 12.h),
            Row(children: [
              SizedBox(height: 18.h, width: 18.w, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 8.w),
              Text(controller.imageUploadStatus.value ?? l10n.uploading),
            ]),
          ],
        ],
      );
    });
  }

  Widget _buildImageTile(AddHotelPageController controller, String url, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            width: 120.w,
            height: 120.h,
            color: Colors.grey[200],
            child: Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(FontAwesomeIcons.image)),
          ),
        ),
        Positioned(
          top: 6.h,
          right: 6.w,
          child: IconButton(
            onPressed: () => controller.removeImageAt(index),
            icon: Icon(FontAwesomeIcons.xmark, size: 18.r, color: Colors.white),
            style: IconButton.styleFrom(backgroundColor: Colors.black45, padding: EdgeInsets.all(4.w)),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageTile(AddHotelPageController controller, AppLocalizations l10n, {bool fullWidth = false}) {
    return GestureDetector(
      onTap: () => _showImageOptions(controller, l10n),
      child: Container(
        width: fullWidth ? double.infinity : 120,
        height: 120.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(FontAwesomeIcons.photoFilm, size: 32.r, color: Colors.grey[500]),
            SizedBox(height: 8.h),
            Text(l10n.tapToChoosePhoto, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageOptions(AddHotelPageController controller, AppLocalizations l10n) async {
    if (controller.remainingImageSlots <= 0) {
      AppToast.info(l10n.maxPhotosReached(AddHotelPageController.maxHotelImages));
      return;
    }
    await showModalBottomSheet<void>(
      context: Get.context!,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(FontAwesomeIcons.images),
            title: Text(l10n.photoLibrary),
            onTap: () {
              Navigator.pop(ctx);
              controller.addImagesFromGallery();
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.camera),
            title: Text(l10n.camera),
            onTap: () {
              Navigator.pop(ctx);
              controller.addImageFromCamera();
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.xmark),
            title: Text(l10n.cancel),
            onTap: () => Navigator.pop(ctx),
          ),
        ]),
      ),
    );
  }

  // ============ 基本信息 ============
  Widget _buildBasicInfoSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.basicInformation, FontAwesomeIcons.circleInfo),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.nameController,
          label: l10n.hotelName,
          hint: l10n.hotelNameHint,
          required: true,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.descriptionController,
          label: l10n.description,
          hint: l10n.hotelDescriptionHint,
          maxLines: 4,
          required: true,
        ),
      ],
    );
  }

  // ============ 位置 ============
  Widget _buildLocationSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.location, FontAwesomeIcons.locationDot),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.addressController,
          label: l10n.address,
          hint: l10n.addressHint,
          required: true,
        ),
        SizedBox(height: 16.h),
        Obx(() {
          return LocationPickerField(
            locationController: controller.locationController,
            initialCountryId: controller.selectedCountryId.value,
            initialCountryName: controller.selectedCountry.value,
            initialCityId: controller.selectedCityId.value,
            initialCityName: controller.selectedCity.value,
            required: true,
            enabled: cityId == null,
            label: l10n.city,
            onChanged: (result) {
              controller.updateLocation(
                countryId: result.countryId,
                countryName: result.countryName,
                cityIdValue: result.cityId,
                cityNameValue: result.cityName,
              );
            },
          );
        }),
        SizedBox(height: 16.h),
        _buildLocationPicker(controller, l10n),
      ],
    );
  }

  Widget _buildLocationPicker(AddHotelPageController controller, AppLocalizations l10n) {
    return Obx(() {
      final lat = controller.latitude.value;
      final lng = controller.longitude.value;
      return Card(
        elevation: 0,
        color: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(color: Colors.grey[300]!),
        ),
        child: ListTile(
          leading: const Icon(FontAwesomeIcons.map, color: Color(0xFFFF4458)),
          title: (lat != 0 && lng != 0)
              ? Text(l10n.locationCoordinates(lat.toStringAsFixed(6), lng.toStringAsFixed(6)))
              : Text(l10n.pickLocationOnMap),
          trailing: Icon(FontAwesomeIcons.arrowRight, size: 16.r),
          onTap: () async {
            final result = await Get.to(
              () => const MapPickerPage(),
              binding: MapPickerBinding(),
              arguments: {
                'initialLatitude': lat != 0 ? lat : null,
                'initialLongitude': lng != 0 ? lng : null,
                'searchQuery': controller.addressController.text.trim().isNotEmpty
                    ? controller.addressController.text.trim()
                    : null,
                    'country': controller.selectedCountry.value,
                    'city': controller.selectedCity.value,
                  },
                );

            if (result != null && result is Map<String, dynamic>) {
              controller.updateCoordinates(result['latitude'] ?? 0.0, result['longitude'] ?? 0.0);
            }
          },
        ),
      );
    });
  }

  // ============ 联系方式 ============
  Widget _buildContactSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.contactInformation, FontAwesomeIcons.addressBook),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.phoneController,
          label: l10n.phone,
          hint: l10n.phoneHint,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.emailController,
          label: l10n.email,
          hint: l10n.emailHint,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.websiteController,
          label: l10n.website,
          hint: l10n.websiteHint,
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  // ============ 价格 ============
  Widget _buildPricingSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.pricing, FontAwesomeIcons.dollarSign),
        SizedBox(height: 16.h),
        _buildCurrencyDropdown(controller, l10n),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.pricePerNightController,
          label: l10n.pricePerNight,
          hint: l10n.pricePerNightHint,
          keyboardType: TextInputType.number,
          required: true,
        ),
        SizedBox(height: 16.h),
        _buildSwitchTile(
          l10n.longStayDiscount,
          controller.hasLongStayDiscount,
          (value) => controller.hasLongStayDiscount.value = value,
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(AddHotelPageController controller, AppLocalizations l10n) {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.currency.value,
        decoration: InputDecoration(
          labelText: l10n.currency,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: const ['USD', 'EUR', 'GBP', 'JPY', 'CNY', 'THB', 'VND', 'IDR', 'MYR', 'SGD']
            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
            .toList(),
        onChanged: (value) => controller.currency.value = value!,
      );
    });
  }

  // ============ 房型 ============
  Widget _buildRoomTypesSection(AddHotelPageController controller) {
    final l10n = AppLocalizations.of(Get.context!)!;
    return Obx(() {
      final rooms = controller.roomTypes;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle(l10n.addHotelRoomTypesTitle, FontAwesomeIcons.bed),
              TextButton.icon(
                onPressed: () => _showRoomTypeDialog(controller),
                icon: Icon(FontAwesomeIcons.plus, size: 14.r),
                label: Text(l10n.addHotelAddRoomType),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(l10n.addHotelRoomTypesHint, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
          SizedBox(height: 16.h),
          if (rooms.isEmpty)
            Card(
              elevation: 0,
              color: Colors.grey[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Column(
                    children: [
                      Icon(FontAwesomeIcons.bed, size: 32.r, color: Colors.grey),
                      SizedBox(height: 12.h),
                      Text(l10n.addHotelNoRoomTypes, style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 4.h),
                      Text(l10n.addHotelTapToAddRoomType, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            )
          else
            ...List.generate(rooms.length, (index) => _buildRoomTypeCard(controller, index)),
        ],
      );
    });
  }

  Widget _buildRoomTypeCard(AddHotelPageController controller, int index) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final room = controller.roomTypes[index];
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    room['name'] ?? l10n.addHotelUnnamedRoomType,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(FontAwesomeIcons.penToSquare, size: 16.r),
                      onPressed: () => _showRoomTypeDialog(controller, editIndex: index),
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.trash, size: 16.r),
                      onPressed: () => _confirmRemoveRoomType(controller, index),
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                _buildRoomInfoChip(
                    Icons.attach_money, l10n.addHotelPricePerNightChip(room['currency'], room['pricePerNight'])),
                SizedBox(width: 8.w),
                _buildRoomInfoChip(Icons.people, l10n.addHotelMaxOccupancyChip(room['maxOccupancy'])),
                SizedBox(width: 8.w),
                _buildRoomInfoChip(Icons.square_foot, '${room['size'] ?? room['roomSize']}㎡'),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                _buildRoomInfoChip(Icons.bed, room['bedType'] ?? l10n.addHotelBedTypeDouble),
                SizedBox(width: 8.w),
                _buildRoomInfoChip(Icons.meeting_room, l10n.addHotelAvailableRoomsChip(room['availableRooms'])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showRoomTypeDialog(AddHotelPageController controller, {int? editIndex}) {
    final l10n = AppLocalizations.of(Get.context!)!;
    final isEdit = editIndex != null;
    final room = isEdit ? controller.roomTypes[editIndex] : <String, dynamic>{};

    final nameController = TextEditingController(text: room['name'] ?? '');
    final descController = TextEditingController(text: room['description'] ?? '');
    final priceController = TextEditingController(text: room['pricePerNight']?.toString() ?? '');
    final sizeController = TextEditingController(text: (room['roomSize'] ?? room['size'])?.toString() ?? '25');
    final maxOccupancyController = TextEditingController(text: room['maxOccupancy']?.toString() ?? '2');
    final availableRoomsController = TextEditingController(text: room['availableRooms']?.toString() ?? '1');
    String selectedBedType = room['bedType'] ?? 'Double';
    String selectedCurrency = room['currency'] ?? controller.currency.value;

    showDialog(
      context: Get.context!,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? l10n.addHotelEditRoomType : l10n.addHotelAddRoomType),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: '${l10n.addHotelRoomTypeName} *', hintText: l10n.addHotelRoomTypeNameHint),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                      labelText: l10n.addHotelRoomTypeDescription, hintText: l10n.addHotelRoomTypeDescriptionHint),
                  maxLines: 2,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: '${l10n.pricePerNight} *'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCurrency,
                        decoration: InputDecoration(labelText: l10n.currency),
                        items: const ['USD', 'EUR', 'CNY', 'THB', 'VND', 'IDR']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedCurrency = v!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sizeController,
                        decoration: InputDecoration(labelText: l10n.addHotelRoomSize),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: maxOccupancyController,
                        decoration: InputDecoration(labelText: l10n.addHotelMaxOccupancy),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedBedType,
                        decoration: InputDecoration(labelText: l10n.addHotelBedType),
                        items: [
                          DropdownMenuItem(value: 'Single', child: Text(l10n.addHotelBedTypeSingle)),
                          DropdownMenuItem(value: 'Double', child: Text(l10n.addHotelBedTypeDouble)),
                          DropdownMenuItem(value: 'Queen', child: Text(l10n.addHotelBedTypeQueen)),
                          DropdownMenuItem(value: 'King', child: Text(l10n.addHotelBedTypeKing)),
                          DropdownMenuItem(value: 'Twin', child: Text(l10n.addHotelBedTypeTwin)),
                          DropdownMenuItem(value: 'Bunk', child: Text(l10n.addHotelBedTypeBunk)),
                        ]
                            .toList(),
                        onChanged: (v) => setDialogState(() => selectedBedType = v!),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        controller: availableRoomsController,
                        decoration: InputDecoration(labelText: l10n.addHotelAvailableRooms),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  AppToast.error(l10n.addHotelEnterRoomTypeName);
                  return;
                }
                if (priceController.text.trim().isEmpty) {
                  AppToast.error(l10n.addHotelEnterPricePerNight);
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

                if (isEdit && room['id'] != null) {
                  roomData['id'] = room['id'];
                }

                if (isEdit) {
                  controller.updateRoomType(editIndex, roomData);
                } else {
                  controller.addRoomType(roomData);
                }

                Navigator.pop(context);
                AppToast.success(isEdit ? l10n.addHotelRoomTypeUpdated : l10n.addHotelRoomTypeAdded);
              },
              child: Text(isEdit ? l10n.save : l10n.add),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRemoveRoomType(AddHotelPageController controller, int index) {
    final l10n = AppLocalizations.of(Get.context!)!;
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.addHotelDeleteRoomTypeConfirm(controller.roomTypes[index]['name'] ?? '')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              controller.removeRoomType(index);
              Navigator.pop(context);
              AppToast.success(l10n.addHotelRoomTypeDeleted);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  // ============ 数字游民特性 ============
  Widget _buildNomadFeaturesSection(AddHotelPageController controller, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.nomadFeatures, FontAwesomeIcons.laptopCode),
        SizedBox(height: 8.h),
        Text(l10n.nomadFeaturesSubtitle, style: TextStyle(fontSize: 13.sp, color: Colors.grey[600])),
        SizedBox(height: 16.h),
        _buildTextField(
          controller: controller.wifiSpeedController,
          label: l10n.wifiSpeed,
          hint: l10n.wifiSpeedHint,
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 8.h),
        _buildSwitchTile(l10n.wifi, controller.hasWifi, (v) => controller.hasWifi.value = v),
        _buildSwitchTile(l10n.workDesk, controller.hasWorkDesk, (v) => controller.hasWorkDesk.value = v),
        _buildSwitchTile(l10n.hasCoworkingSpace, controller.hasCoworkingSpace, (v) => controller.hasCoworkingSpace.value = v),
        _buildSwitchTile(l10n.airConditioning, controller.hasAirConditioning, (v) => controller.hasAirConditioning.value = v),
        _buildSwitchTile(l10n.kitchen, controller.hasKitchen, (v) => controller.hasKitchen.value = v),
        _buildSwitchTile(l10n.laundry, controller.hasLaundry, (v) => controller.hasLaundry.value = v),
        _buildSwitchTile(l10n.parking, controller.hasParking, (v) => controller.hasParking.value = v),
        _buildSwitchTile(l10n.pool, controller.hasPool, (v) => controller.hasPool.value = v),
        _buildSwitchTile(l10n.gym, controller.hasGym, (v) => controller.hasGym.value = v),
        _buildSwitchTile(l10n.twentyFourHourReception, controller.has24HourReception,
            (v) => controller.has24HourReception.value = v),
        _buildSwitchTile(l10n.petFriendly, controller.isPetFriendly, (v) => controller.isPetFriendly.value = v),
      ],
    );
  }

  // ============ 底部按钮 ============
  Widget _buildBottomBar(AddHotelPageController controller, AppLocalizations l10n) {
    return Builder(
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          child: Obx(() {
            return ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : () async {
                      final success = await controller.submitHotel(
                        l10n.selectCity,
                        l10n.updateSuccess,
                        l10n.hotelSubmittedSuccess,
                        l10n.failedToSubmitHotel,
                      );
                      if (success && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4458),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                controller.isSubmitting.value
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isEditMode ? FontAwesomeIcons.penToSquare : FontAwesomeIcons.circleCheck, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  isEditMode ? l10n.save : l10n.submitHotel,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }),
        ),
      ),
    );
  }
}
