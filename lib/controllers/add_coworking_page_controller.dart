import 'dart:developer';
import 'dart:ui' as ui;

import 'package:df_admin_mobile/config/supabase_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart';
import 'package:df_admin_mobile/features/coworking/domain/entities/coworking_space.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_repository.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_cities_by_country_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_city_by_id_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/get_countries_use_case.dart';
import 'package:df_admin_mobile/features/location/application/use_cases/search_cities_use_case.dart';
import 'package:df_admin_mobile/features/location/presentation/controllers/location_state_controller.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/utils/image_upload_helper.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Add/Edit Coworking Space Controller
class AddCoworkingPageController extends GetxController {
  final String? cityName;
  final String? cityId;
  final String? countryName;
  final CoworkingSpace? editingSpace;

  AddCoworkingPageController({
    this.cityName,
    this.cityId,
    this.countryName,
    this.editingSpace,
  });

  bool get isEditMode => editingSpace != null;

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;

  late final LocationStateController locationController;

  // Basic Info
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final descriptionController = TextEditingController();

  // Location
  final Rx<String?> selectedCountry = Rx<String?>(null);
  final Rx<String?> selectedCity = Rx<String?>(null);
  final Rx<String?> selectedCountryId = Rx<String?>(null);
  final Rx<String?> selectedCityId = Rx<String?>(null);
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;

  // Contact
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();

  // Pricing
  final hourlyRateController = TextEditingController();
  final dailyRateController = TextEditingController();
  final weeklyRateController = TextEditingController();
  final monthlyRateController = TextEditingController();
  final RxString currency = 'USD'.obs;
  final RxBool hasFreeTrial = false.obs;
  final trialDurationController = TextEditingController();

  // Specs
  final wifiSpeedController = TextEditingController();
  final numberOfDesksController = TextEditingController();
  final numberOfMeetingRoomsController = TextEditingController();
  final capacityController = TextEditingController();
  final Rx<String?> noiseLevel = Rx<String?>(null);
  final RxBool hasNaturalLight = false.obs;
  final Rx<String?> spaceType = Rx<String?>(null);

  // Amenities
  final RxBool hasWifi = false.obs;
  final RxBool hasCoffee = false.obs;
  final RxBool hasPrinter = false.obs;
  final RxBool hasMeetingRoom = false.obs;
  final RxBool hasPhoneBooth = false.obs;
  final RxBool hasKitchen = false.obs;
  final RxBool hasParking = false.obs;
  final RxBool hasLocker = false.obs;
  final RxBool has24HourAccess = false.obs;
  final RxBool hasAirConditioning = false.obs;
  final RxBool hasStandingDesk = false.obs;
  final RxBool hasShower = false.obs;
  final RxBool hasBike = false.obs;
  final RxBool hasEventSpace = false.obs;
  final RxBool hasPetFriendly = false.obs;

  // Opening Hours
  final RxList<String> openingHours = <String>[].obs;

  // Images
  static const int maxCoworkingImages = 5;
  final RxList<String> coworkingImageUrls = <String>[].obs;
  final RxBool isUploadingImages = false.obs;
  final Rx<String?> imageUploadStatus = Rx<String?>(null);
  final ImageUploadService _imageUploadService = ImageUploadService();

  int get remainingImageSlots => maxCoworkingImages - coworkingImageUrls.length;
  String get imageUploadBucket => SupabaseConfig.buckets['coworkingPhotos'] ?? SupabaseConfig.defaultBucket;
  String get imageUploadFolder => 'coworking/${selectedCityId.value ?? 'general'}';

  String _resolveLocaleCode() {
    final locale = Get.locale ?? ui.PlatformDispatcher.instance.locale;
    return locale.languageCode.toLowerCase();
  }

  @override
  void onInit() {
    super.onInit();
    // Ensure LocationStateController is registered before use to avoid GetX lookup errors.
    if (!Get.isRegistered<LocationStateController>()) {
      Get.put(
        LocationStateController(
          getCountriesUseCase: Get.find<GetCountriesUseCase>(),
          getCitiesByCountryUseCase: Get.find<GetCitiesByCountryUseCase>(),
          getCityByIdUseCase: Get.find<GetCityByIdUseCase>(),
          searchCitiesUseCase: Get.find<SearchCitiesUseCase>(),
        ),
      );
    }
    locationController = Get.find<LocationStateController>();

    if (isEditMode) {
      log('✏️ [AddCoworking] 编辑模式 - 填充现有数据');
      _fillFormWithExistingData(editingSpace!);
      if (editingSpace!.location.cityId != null) {
        _initializeFromCityId(
          editingSpace!.location.cityId!,
          fallbackCityName: editingSpace!.location.city,
          fallbackCountryName: editingSpace!.location.country,
        );
      }
    } else if (cityId != null && cityId!.isNotEmpty) {
      log('🏙️ [AddCoworking] 从参数中读取 cityId: $cityId');
      _initializeFromCityId(cityId!, fallbackCityName: cityName, fallbackCountryName: countryName);
    }
  }

  void _fillFormWithExistingData(CoworkingSpace space) {
    nameController.text = space.name;
    addressController.text = space.location.address;
    descriptionController.text = space.spaceInfo.description;

    selectedCity.value = space.location.city;
    selectedCityId.value = space.location.cityId;
    selectedCountry.value = space.location.country;
    latitude.value = space.location.latitude;
    longitude.value = space.location.longitude;

    phoneController.text = space.contactInfo.phone;
    emailController.text = space.contactInfo.email;
    websiteController.text = space.contactInfo.website;

    if (space.pricing.hourlyRate != null) hourlyRateController.text = space.pricing.hourlyRate.toString();
    if (space.pricing.dailyRate != null) dailyRateController.text = space.pricing.dailyRate.toString();
    if (space.pricing.weeklyRate != null) weeklyRateController.text = space.pricing.weeklyRate.toString();
    if (space.pricing.monthlyRate != null) monthlyRateController.text = space.pricing.monthlyRate.toString();
    currency.value = space.pricing.currency;
    hasFreeTrial.value = space.pricing.hasFreeTrial;
    if (space.pricing.trialDuration != null) trialDurationController.text = space.pricing.trialDuration!;

    if (space.specs.wifiSpeed != null) wifiSpeedController.text = space.specs.wifiSpeed.toString();
    if (space.specs.numberOfDesks != null) numberOfDesksController.text = space.specs.numberOfDesks.toString();
    if (space.specs.numberOfMeetingRooms != null)
      numberOfMeetingRoomsController.text = space.specs.numberOfMeetingRooms.toString();
    if (space.specs.capacity != null) capacityController.text = space.specs.capacity.toString();
    noiseLevel.value = space.specs.noiseLevel?.name;
    hasNaturalLight.value = space.specs.hasNaturalLight;
    spaceType.value = space.specs.spaceType?.name;

    hasWifi.value = space.amenities.hasWifi;
    hasCoffee.value = space.amenities.hasCoffee;
    hasPrinter.value = space.amenities.hasPrinter;
    hasMeetingRoom.value = space.amenities.hasMeetingRoom;
    hasPhoneBooth.value = space.amenities.hasPhoneBooth;
    hasKitchen.value = space.amenities.hasKitchen;
    hasParking.value = space.amenities.hasParking;
    hasLocker.value = space.amenities.hasLocker;
    has24HourAccess.value = space.amenities.has24HourAccess;
    hasAirConditioning.value = space.amenities.hasAirConditioning;
    hasStandingDesk.value = space.amenities.hasStandingDesk;
    hasShower.value = space.amenities.hasShower;
    hasBike.value = space.amenities.hasBike;
    hasEventSpace.value = space.amenities.hasEventSpace;
    hasPetFriendly.value = space.amenities.hasPetFriendly;

    openingHours.addAll(space.operationHours.hours);
    coworkingImageUrls.addAll(space.spaceInfo.images);
  }

  Future<void> _initializeFromCityId(String cityIdParam,
      {String? fallbackCityName, String? fallbackCountryName}) async {
    try {
      if (locationController.countries.isEmpty) {
        await locationController.loadCountries();
      }

      final localeCode = _resolveLocaleCode();
      final cityResult = await locationController.getCityById(cityIdParam);

      String? foundCountryId;
      CityOption? foundCity;

      if (cityResult.isSuccess) {
        foundCity = cityResult.dataOrNull;
        foundCountryId = foundCity?.countryId;
        if (foundCity != null && foundCountryId != null) {
          await locationController.loadCitiesByCountry(foundCountryId);
        }
      }

      if (foundCountryId == null && fallbackCountryName != null && fallbackCountryName.isNotEmpty) {
        final country = locationController.countries.firstWhereOrNull((c) {
          final displayName = c.displayName(localeCode).toLowerCase().trim();
          final name = c.name.toLowerCase().trim();
          final nameZh = (c.nameZh ?? '').toLowerCase().trim();
          final searchName = fallbackCountryName.toLowerCase().trim();
          return displayName == searchName ||
              name == searchName ||
              nameZh == searchName ||
              displayName.contains(searchName) ||
              name.contains(searchName);
        });
        if (country != null) {
          foundCountryId = country.id;
          await locationController.loadCitiesByCountry(country.id);
          final cities = locationController.citiesByCountry[country.id] ?? [];
          foundCity = cities.firstWhereOrNull((c) => c.id == cityIdParam);
        }
      }

      if (foundCountryId != null && foundCity != null) {
        final country = locationController.countries.firstWhereOrNull((c) => c.id == foundCountryId);
        if (country != null) {
          selectedCountryId.value = country.id;
          selectedCountry.value = country.displayName(localeCode);
          selectedCityId.value = foundCity.id;
          selectedCity.value = foundCity.name;
        }
      } else if (fallbackCityName != null && fallbackCountryName != null) {
        selectedCountry.value = fallbackCountryName;
        selectedCity.value = fallbackCityName;
        selectedCityId.value = cityIdParam;
      }
    } catch (e) {
      log('❌ [AddCoworking] 初始化失败: $e');
      if (fallbackCityName != null && fallbackCountryName != null) {
        selectedCountry.value = fallbackCountryName;
        selectedCity.value = fallbackCityName;
        selectedCityId.value = cityIdParam;
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    addressController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    hourlyRateController.dispose();
    dailyRateController.dispose();
    weeklyRateController.dispose();
    monthlyRateController.dispose();
    trialDurationController.dispose();
    wifiSpeedController.dispose();
    numberOfDesksController.dispose();
    numberOfMeetingRoomsController.dispose();
    capacityController.dispose();
    super.onClose();
  }

  void updateLocation({String? countryId, String? countryNameValue, String? cityIdValue, String? cityNameValue}) {
    selectedCountryId.value = countryId;
    selectedCountry.value = countryNameValue;
    selectedCityId.value = cityIdValue;
    selectedCity.value = cityNameValue;
  }

  void updateCoordinates(double lat, double lng) {
    latitude.value = lat;
    longitude.value = lng;
  }

  // Image Management
  Future<void> addImagesFromGallery() async {
    isUploadingImages.value = true;
    imageUploadStatus.value = null;
    try {
      final urls = await ImageUploadHelper.pickMultipleAndUpload(
        bucket: imageUploadBucket,
        folder: imageUploadFolder,
        maxImages: remainingImageSlots,
        onProgress: (c, t) => imageUploadStatus.value = '上传进度 $c / $t',
      );
      if (urls.isNotEmpty) coworkingImageUrls.addAll(urls);
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
      if (url != null) coworkingImageUrls.add(url);
    } catch (e) {
      AppToast.error(e.toString());
    } finally {
      isUploadingImages.value = false;
    }
  }

  Future<void> removeImageAt(int index) async {
    if (index < 0 || index >= coworkingImageUrls.length) return;
    final url = coworkingImageUrls[index];
    coworkingImageUrls.removeAt(index);
    try {
      await _imageUploadService.deleteImage(imageUrl: url, bucket: imageUploadBucket);
    } catch (e) {
      log('Failed to delete image: $e');
    }
  }

  // Submit
  Future<bool> submitCoworking(String selectCityError, String updateSuccessMsg, String submitSuccessMsg,
      String Function(String) failedMsg) async {
    if (!formKey.currentState!.validate()) return false;

    if (selectedCityId.value == null || selectedCityId.value!.isEmpty) {
      AppToast.error(selectCityError);
      return false;
    }

    isSubmitting.value = true;

    try {
      final repository = Get.find<ICoworkingRepository>();
      final hours = openingHours.isNotEmpty ? openingHours.toList() : ['Monday-Friday: 9:00-18:00'];

      final coworkingSpace = CoworkingSpace(
        id: '',
        name: nameController.text,
        location: Location(
          cityId: selectedCityId.value,
          address: addressController.text,
          city: selectedCity.value ?? '',
          country: selectedCountry.value ?? '',
          latitude: latitude.value,
          longitude: longitude.value,
        ),
        contactInfo: ContactInfo(
          phone: phoneController.text,
          email: emailController.text,
          website: websiteController.text,
        ),
        spaceInfo: SpaceInfo(
          imageUrl: coworkingImageUrls.isNotEmpty ? coworkingImageUrls.first : '',
          images: coworkingImageUrls.toList(),
          rating: 0.0,
          reviewCount: 0,
          description: descriptionController.text,
        ),
        pricing: Pricing(
          hourlyRate: hourlyRateController.text.isNotEmpty ? double.tryParse(hourlyRateController.text) : null,
          dailyRate: dailyRateController.text.isNotEmpty ? double.tryParse(dailyRateController.text) : null,
          weeklyRate: weeklyRateController.text.isNotEmpty ? double.tryParse(weeklyRateController.text) : null,
          monthlyRate: monthlyRateController.text.isNotEmpty ? double.tryParse(monthlyRateController.text) : null,
          currency: currency.value,
          hasFreeTrial: hasFreeTrial.value,
          trialDuration: hasFreeTrial.value ? trialDurationController.text : null,
        ),
        amenities: Amenities(
          hasWifi: hasWifi.value,
          hasCoffee: hasCoffee.value,
          hasPrinter: hasPrinter.value,
          hasMeetingRoom: hasMeetingRoom.value,
          hasPhoneBooth: hasPhoneBooth.value,
          hasKitchen: hasKitchen.value,
          hasParking: hasParking.value,
          hasLocker: hasLocker.value,
          has24HourAccess: has24HourAccess.value,
          hasAirConditioning: hasAirConditioning.value,
          hasStandingDesk: hasStandingDesk.value,
          hasShower: hasShower.value,
          hasBike: hasBike.value,
          hasEventSpace: hasEventSpace.value,
          hasPetFriendly: hasPetFriendly.value,
        ),
        specs: Specifications(
          wifiSpeed: wifiSpeedController.text.isNotEmpty ? double.tryParse(wifiSpeedController.text) : null,
          numberOfDesks: numberOfDesksController.text.isNotEmpty ? int.tryParse(numberOfDesksController.text) : null,
          numberOfMeetingRooms:
              numberOfMeetingRoomsController.text.isNotEmpty ? int.tryParse(numberOfMeetingRoomsController.text) : null,
          capacity: capacityController.text.isNotEmpty ? int.tryParse(capacityController.text) : null,
          noiseLevel: NoiseLevel.fromString(noiseLevel.value),
          hasNaturalLight: hasNaturalLight.value,
          spaceType: SpaceType.fromString(spaceType.value),
        ),
        operationHours: OperationHours(hours: hours),
        isVerified: isEditMode ? editingSpace!.isVerified : false,
        lastUpdated: DateTime.now(),
      );

      final Result<CoworkingSpace> result;
      if (isEditMode) {
        final updatedSpace = coworkingSpace.copyWith(id: editingSpace!.id);
        result = await repository.updateCoworkingSpace(editingSpace!.id, updatedSpace);
      } else {
        result = await repository.createCoworkingSpace(coworkingSpace);
      }

      bool success = false;
      result.fold(
        onSuccess: (savedSpace) {
          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'coworking',
            entityId: savedSpace.id,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: isEditMode ? DataChangeType.updated : DataChangeType.created,
          ));
          AppToast.success(isEditMode ? updateSuccessMsg : submitSuccessMsg);
          success = true;
        },
        onFailure: (exception) {
          AppToast.error(failedMsg(exception.message));
        },
      );

      // 只在失败时重置状态，成功时页面会关闭，无需重置
      if (!success) {
        isSubmitting.value = false;
      }
      return success;
    } catch (e) {
      AppToast.error(failedMsg(e.toString()));
      isSubmitting.value = false;
      return false;
    }
  }
}
