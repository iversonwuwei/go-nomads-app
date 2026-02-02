import 'dart:developer';

import 'package:go_nomads_app/config/supabase_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/core/sync/sync.dart';
import 'package:go_nomads_app/features/hotel/domain/entities/hotel.dart';
import 'package:go_nomads_app/features/hotel/infrastructure/repositories/hotel_repository.dart';
import 'package:go_nomads_app/features/location/presentation/controllers/location_state_controller.dart';
import 'package:go_nomads_app/services/http_service.dart';
import 'package:go_nomads_app/services/image_upload_service.dart';
import 'package:go_nomads_app/utils/image_upload_helper.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Add/Edit Hotel Page Controller
class AddHotelPageController extends GetxController {
  final String? cityName;
  final String? cityId;
  final String? countryName;
  final Hotel? editingHotel;

  AddHotelPageController({
    this.cityName,
    this.cityId,
    this.countryName,
    this.editingHotel,
  });

  bool get isEditMode => editingHotel != null;

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;

  late final LocationStateController locationController;
  final HotelRepository _hotelRepository = HotelRepository(HttpService());

  // ============ 基本信息 ============
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final addressController = TextEditingController();

  // ============ 位置信息 ============
  final Rx<String?> selectedCountry = Rx<String?>(null);
  final Rx<String?> selectedCity = Rx<String?>(null);
  final Rx<String?> selectedCountryId = Rx<String?>(null);
  final Rx<String?> selectedCityId = Rx<String?>(null);
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // ============ 联系方式 ============
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  // ============ 价格信息 ============
  final pricePerNightController = TextEditingController();
  final RxString currency = 'USD'.obs;

  // ============ 数字游民特性 ============
  final wifiSpeedController = TextEditingController();
  final RxBool hasWifi = true.obs;
  final RxBool hasWorkDesk = false.obs;
  final RxBool hasAirConditioning = false.obs;
  final RxBool hasKitchen = false.obs;
  final RxBool hasLaundry = false.obs;
  final RxBool hasParking = false.obs;
  final RxBool hasPool = false.obs;
  final RxBool hasGym = false.obs;
  final RxBool has24HourReception = false.obs;
  final RxBool hasLongStayDiscount = false.obs;
  final RxBool isPetFriendly = false.obs;
  final RxBool hasCoworkingSpace = false.obs;

  // ============ 图片 ============
  static const int maxHotelImages = 5;
  final RxList<String> hotelImageUrls = <String>[].obs;
  final RxBool isUploadingImages = false.obs;
  final Rx<String?> imageUploadStatus = Rx<String?>(null);
  final ImageUploadService _imageUploadService = ImageUploadService();

  // ============ 房型列表 ============
  final RxList<Map<String, dynamic>> roomTypes = <Map<String, dynamic>>[].obs;

  int get remainingImageSlots => maxHotelImages - hotelImageUrls.length;
  String get imageUploadBucket => SupabaseConfig.buckets['hotelPhotos'] ?? SupabaseConfig.defaultBucket;
  String get imageUploadFolder => 'hotels/${selectedCityId.value ?? 'general'}';

  @override
  void onInit() {
    super.onInit();
    locationController = Get.find<LocationStateController>();
    _initializeFromParams();

    if (isEditMode) {
      log('✏️ [AddHotel] 编辑模式 - 填充现有数据');
      _fillFormWithExistingData(editingHotel!);
    }
  }

  void _initializeFromParams() {
    log('🏨 [AddHotel] _initializeFromParams:');
    log('   cityId: "$cityId" (type: ${cityId.runtimeType})');
    log('   cityName: "$cityName"');
    log('   countryName: "$countryName"');

    if (cityId != null && cityId!.isNotEmpty) {
      selectedCityId.value = cityId;
      selectedCity.value = cityName;
      selectedCountry.value = countryName;
      log('🏨 [AddHotel] ✅ 已设置城市: ${selectedCity.value} (ID: ${selectedCityId.value}), 国家: ${selectedCountry.value}');
    } else {
      log('🏨 [AddHotel] ⚠️ cityId 为空，未设置城市');
    }
  }

  void _fillFormWithExistingData(Hotel hotel) {
    // 基本信息
    nameController.text = hotel.name;
    descriptionController.text = hotel.description;
    addressController.text = hotel.address;

    // 位置信息
    selectedCityId.value = hotel.cityId;
    selectedCity.value = hotel.cityName;
    selectedCountry.value = hotel.country;
    latitude.value = hotel.latitude;
    longitude.value = hotel.longitude;

    // 联系方式
    phoneController.text = hotel.phone ?? '';
    emailController.text = hotel.email ?? '';
    websiteController.text = hotel.website ?? '';

    // 价格信息
    pricePerNightController.text = hotel.pricePerNight.toString();
    currency.value = hotel.currency;

    // 数字游民特性
    if (hotel.wifiSpeed != null) wifiSpeedController.text = hotel.wifiSpeed.toString();
    hasWifi.value = hotel.hasWifi;
    hasWorkDesk.value = hotel.hasWorkDesk;
    hasAirConditioning.value = hotel.hasAirConditioning;
    hasKitchen.value = hotel.hasKitchen;
    hasLaundry.value = hotel.hasLaundry;
    hasParking.value = hotel.hasParking;
    hasPool.value = hotel.hasPool;
    hasGym.value = hotel.hasGym;
    has24HourReception.value = hotel.has24HReception;
    hasLongStayDiscount.value = hotel.hasLongStayDiscount;
    isPetFriendly.value = hotel.isPetFriendly;
    hasCoworkingSpace.value = hotel.hasCoworkingSpace;

    // 图片
    hotelImageUrls.addAll(hotel.images);

    // 房型
    for (final room in hotel.roomTypes) {
      roomTypes.add({
        'id': room.id,
        'name': room.name,
        'description': room.description,
        'pricePerNight': room.pricePerNight,
        'currency': room.currency,
        'roomSize': room.size,
        'maxOccupancy': room.maxOccupancy,
        'bedType': room.bedType,
        'availableRooms': room.availableRooms,
        'isAvailable': room.isAvailable,
      });
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    addressController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    pricePerNightController.dispose();
    wifiSpeedController.dispose();
    super.onClose();
  }

  // ============ 位置更新 ============
  void updateLocation({
    String? countryId,
    String? countryName,
    String? cityIdValue,
    String? cityNameValue,
  }) {
    selectedCountryId.value = countryId;
    selectedCountry.value = countryName;
    selectedCityId.value = cityIdValue;
    selectedCity.value = cityNameValue;
  }

  void updateCoordinates(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
  }

  // ============ 图片管理 ============
  Future<void> addImagesFromGallery() async {
    isUploadingImages.value = true;
    imageUploadStatus.value = null;
    try {
      final urls = await ImageUploadHelper.pickMultipleAndUpload(
        bucket: imageUploadBucket,
        folder: imageUploadFolder,
        maxImages: remainingImageSlots,
        onProgress: (c, t) => imageUploadStatus.value = 'Uploading $c / $t',
      );
      if (urls.isNotEmpty) hotelImageUrls.addAll(urls);
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isUploadingImages.value = false;
      imageUploadStatus.value = null;
    }
  }

  Future<void> addImageFromCamera() async {
    isUploadingImages.value = true;
    try {
      final url = await ImageUploadHelper.captureAndUpload(bucket: imageUploadBucket, folder: imageUploadFolder);
      if (url != null) hotelImageUrls.add(url);
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isUploadingImages.value = false;
    }
  }

  Future<void> removeImageAt(int index) async {
    if (index < 0 || index >= hotelImageUrls.length) return;
    final url = hotelImageUrls[index];
    hotelImageUrls.removeAt(index);
    try {
      await _imageUploadService.deleteImage(imageUrl: url, bucket: imageUploadBucket);
    } catch (e) {
      log('Failed to delete image: $e');
    }
  }

  // ============ 房型管理 ============
  void addRoomType(Map<String, dynamic> roomData) {
    roomTypes.add(roomData);
  }

  void updateRoomType(int index, Map<String, dynamic> roomData) {
    roomTypes[index] = roomData;
  }

  void removeRoomType(int index) {
    roomTypes.removeAt(index);
  }

  // ============ 提交 ============
  Future<bool> submitHotel(String selectCityError, String updateSuccessMsg, String submitSuccessMsg, String failedMsg) async {
    if (!formKey.currentState!.validate()) return false;

    if (selectedCityId.value == null || selectedCityId.value!.isEmpty) {
      AppToast.error(selectCityError);
      return false;
    }

    isSubmitting.value = true;

    try {
      final hotelData = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'address': addressController.text.trim(),
        'cityId': selectedCityId.value,
        'cityName': selectedCity.value ?? '',
        'country': selectedCountry.value ?? '',
        'latitude': latitude.value,
        'longitude': longitude.value,
        'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
        'email': emailController.text.trim().isEmpty ? null : emailController.text.trim(),
        'website': websiteController.text.trim().isEmpty ? null : websiteController.text.trim(),
        'pricePerNight': double.tryParse(pricePerNightController.text) ?? 0,
        'currency': currency.value,
        'wifiSpeed': int.tryParse(wifiSpeedController.text),
        'hasWifi': hasWifi.value,
        'hasWorkDesk': hasWorkDesk.value,
        'hasCoworkingSpace': hasCoworkingSpace.value,
        'hasAirConditioning': hasAirConditioning.value,
        'hasKitchen': hasKitchen.value,
        'hasLaundry': hasLaundry.value,
        'hasParking': hasParking.value,
        'hasPool': hasPool.value,
        'hasGym': hasGym.value,
        'has24HReception': has24HourReception.value,
        'hasLongStayDiscount': hasLongStayDiscount.value,
        'isPetFriendly': isPetFriendly.value,
        'images': hotelImageUrls.toList(),
        'roomTypes': roomTypes.toList(),
      };

      log('📤 ${isEditMode ? "Updating" : "Submitting"} hotel: $hotelData');

      Result<Hotel> result;
      if (isEditMode) {
        result = await _hotelRepository.updateHotel(editingHotel!.id, hotelData);
      } else {
        result = await _hotelRepository.createHotel(hotelData);
      }

      bool success = false;
      result.onSuccess((hotel) {
        log('✅ 酒店${isEditMode ? "更新" : "创建"}成功: ${hotel.id}');

        DataEventBus.instance.emit(DataChangedEvent(
          entityType: 'hotel',
          entityId: hotel.id,
          version: DateTime.now().millisecondsSinceEpoch,
          changeType: isEditMode ? DataChangeType.updated : DataChangeType.created,
        ));
        log('✅ [Hotel] 已发送数据变更事件: ${hotel.id}');

        AppToast.success(isEditMode ? updateSuccessMsg : submitSuccessMsg);
        success = true;
      }).onFailure((exception) {
        log('❌ 酒店${isEditMode ? "更新" : "创建"}失败: ${exception.message}');
        AppToast.error('$failedMsg: ${exception.message}');
      });

      // 只在失败时重置状态，成功时页面会关闭，无需重置
      if (!success) {
        isSubmitting.value = false;
      }
      return success;
    } catch (e) {
      log('❌ 酒店创建异常: $e');
      AppToast.error('$failedMsg: $e');
      isSubmitting.value = false;
      return false;
    }
  }
}
