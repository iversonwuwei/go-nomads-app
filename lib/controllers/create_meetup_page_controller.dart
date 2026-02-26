import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_nomads_app/config/supabase_config.dart';
import 'package:go_nomads_app/core/domain/result.dart';
import 'package:go_nomads_app/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:go_nomads_app/features/location/presentation/controllers/location_state_controller.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/event_type.dart';
import 'package:go_nomads_app/features/meetup/domain/entities/meetup.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/event_type_controller.dart';
import 'package:go_nomads_app/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:go_nomads_app/generated/app_localizations.dart';
import 'package:go_nomads_app/services/calendar_service.dart';
import 'package:go_nomads_app/services/image_upload_service.dart';
import 'package:go_nomads_app/widgets/app_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateMeetupPageController extends GetxController {
  final Meetup? editingMeetup;

  CreateMeetupPageController({this.editingMeetup});

  bool get isEditMode => editingMeetup != null;

  final formKey = GlobalKey<FormState>();

  // Controllers
  final titleController = TextEditingController();
  final typeController = TextEditingController();
  final venueController = TextEditingController();
  final descriptionController = TextEditingController();

  // State
  final Rx<String?> venueErrorText = Rx<String?>(null);
  final Rx<String?> selectedCity = Rx<String?>(null);
  final Rx<String?> selectedCountry = Rx<String?>(null);
  final Rx<String?> selectedCityId = Rx<String?>(null);
  final Rx<String?> selectedCountryId = Rx<String?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxDouble maxAttendees = 10.0.obs;

  // Type related
  final RxList<EventType> meetupTypes = <EventType>[].obs;
  final RxBool isLoadingTypes = false.obs;
  final RxBool showCustomTypeInput = false.obs;
  final Rx<String?> selectedType = Rx<String?>(null);
  final Rx<String?> selectedTypeId = Rx<String?>(null);

  // Image related
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<String> existingImageUrls = <String>[].obs;
  final RxBool isUploadingImages = false.obs;
  final RxDouble uploadProgress = 0.0.obs;

  // Location coordinates
  final Rx<double?> venueLatitude = Rx<double?>(null);
  final Rx<double?> venueLongitude = Rx<double?>(null);
  final RxBool isSubmitting = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final ImageUploadService imageUploadService = ImageUploadService();

  late final LocationStateController locationController;
  late final MeetupStateController meetupController;
  late final EventTypeController eventTypeController;

  @override
  void onInit() {
    super.onInit();
    locationController = Get.find<LocationStateController>();
    meetupController = Get.find<MeetupStateController>();
    eventTypeController = Get.put(EventTypeController());

    locationController.loadCountries();
    _loadMeetupTypes();

    if (isEditMode) {
      _fillFormWithExistingData(editingMeetup!);
    }
  }

  void _fillFormWithExistingData(Meetup meetup) {
    log('✏️ [CreateMeetup] 编辑模式 - 填充现有数据');

    titleController.text = meetup.title;
    descriptionController.text = meetup.description;
    venueController.text = meetup.venue.name;

    selectedDate.value = meetup.schedule.startTime;
    selectedTime.value = TimeOfDay.fromDateTime(meetup.schedule.startTime);
    maxAttendees.value = meetup.capacity.maxAttendees.toDouble();

    selectedCity.value = meetup.location.city;
    selectedCountry.value = meetup.location.country;

    if (meetup.eventType != null) {
      selectedTypeId.value = meetup.eventType!.id;
      selectedType.value = meetup.eventType!.name;
    }

    existingImageUrls.addAll(meetup.images);
  }

  Future<void> _loadMeetupTypes() async {
    isLoadingTypes.value = true;
    try {
      await eventTypeController.loadEventTypes();
      meetupTypes.value = eventTypeController.eventTypes;
      log('✅ 成功加载 ${meetupTypes.length} 个事件类型');
    } catch (e) {
      log('❌ 加载聚会类型失败: $e');
      meetupTypes.value = eventTypeController.eventTypes;
    } finally {
      isLoadingTypes.value = false;
    }
  }

  @override
  void onClose() {
    titleController.dispose();
    typeController.dispose();
    venueController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF4458),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  void selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime.value ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF4458),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      selectedTime.value = picked;
    }
  }

  void setVenueFromMap(Map<String, dynamic> result) {
    venueController.text = '${result['name']} - ${result['address']}';
    venueErrorText.value = null;
    if (result['latitude'] != null) venueLatitude.value = result['latitude'];
    if (result['longitude'] != null) venueLongitude.value = result['longitude'];
  }

  Future<void> pickImages(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final List<XFile> images = await imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        if (selectedImages.length + images.length <= 10) {
          selectedImages.addAll(images);
        } else {
          final remaining = 10 - selectedImages.length;
          if (remaining > 0) {
            selectedImages.addAll(images.take(remaining));
          }
          AppToast.warning(l10n.maximumImagesAllowed, title: l10n.notice);
        }
      }
    } catch (e) {
      AppToast.error(l10n.failedToPickImages(e.toString()), title: l10n.error);
    }
  }

  Future<void> takePhoto(BuildContext context) async {
    try {
      final XFile? image = await imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        if (selectedImages.length < 10) {
          selectedImages.add(image);
        } else {
          AppToast.warning('Maximum 10 images allowed', title: 'Notice');
        }
      }
    } catch (e) {
      AppToast.error('Failed to take photo: ${e.toString()}', title: 'Error');
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  void removeExistingImage(int index) {
    existingImageUrls.removeAt(index);
  }

  Future<List<String>> uploadVenueImages(BuildContext context) async {
    if (selectedImages.isEmpty) return [];

    final l10n = AppLocalizations.of(context)!;

    if (!SupabaseConfig.isConfigured) {
      AppToast.error('Image upload service is not configured. Please contact support.', title: l10n.error);
      throw Exception('Supabase not configured');
    }

    isUploadingImages.value = true;
    uploadProgress.value = 0.0;

    final imageFiles = selectedImages.map((image) => File(image.path)).toList();
    final sanitizedFolderSegment =
        (selectedCityId.value?.isNotEmpty == true ? selectedCityId.value! : (selectedCity.value ?? 'general'))
            .replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
    final folderPath = 'meetups/$sanitizedFolderSegment/venues';

    AppToast.info('Uploading ${imageFiles.length} venue photo${imageFiles.length > 1 ? 's' : ''}...',
        title: l10n.notice);

    try {
      final uploadedUrls = await imageUploadService.uploadMultipleImages(
        imageFiles: imageFiles,
        bucket: SupabaseConfig.defaultBucket,
        folder: folderPath,
        onProgress: (current, total) {
          uploadProgress.value = total == 0 ? 0 : current / total;
        },
      );

      if (uploadedUrls.isEmpty) {
        throw Exception('No venue photos were uploaded');
      }

      AppToast.success('Uploaded ${uploadedUrls.length} venue photo${uploadedUrls.length > 1 ? 's' : ''}',
          title: l10n.success);
      return uploadedUrls;
    } catch (e) {
      AppToast.error('Failed to upload venue photos: $e', title: l10n.error);
      rethrow;
    } finally {
      isUploadingImages.value = false;
      uploadProgress.value = 0.0;
    }
  }

  void selectType(String value, String localeCode, FormFieldState<String>? field) {
    if (value == '+ 自定义类型') {
      showCustomTypeInput.value = true;
      selectedType.value = null;
      selectedTypeId.value = null;
      typeController.clear();
      field?.didChange(null);
    } else {
      final selectedEventType = meetupTypes.firstWhereOrNull((type) => type.getDisplayName(localeCode) == value);
      if (selectedEventType != null) {
        selectedType.value = value;
        selectedTypeId.value = selectedEventType.id;
        typeController.text = value;
        showCustomTypeInput.value = false;
        field?.didChange(value);
        log('✅ 选择类型: ${selectedEventType.name} (ID: ${selectedEventType.id})');
      }
    }
  }

  void cancelCustomType() {
    showCustomTypeInput.value = false;
    typeController.clear();
  }

  Future<bool> createMeetup(BuildContext context) async {
    // 立即检查并设置 isSubmitting，防止重复提交
    if (isUploadingImages.value || isSubmitting.value) {
      log('⚠️ [CreateMeetup] 已在提交中，忽略重复请求');
      return false;
    }

    // 立即设置 isSubmitting 为 true，防止竞态条件
    isSubmitting.value = true;

    if (!formKey.currentState!.validate()) {
      isSubmitting.value = false;
      return false;
    }

    final l10n = AppLocalizations.of(context)!;

    if (selectedCity.value == null || selectedDate.value == null || selectedTime.value == null) {
      AppToast.error(l10n.pleaseFillAllFields, title: l10n.error);
      isSubmitting.value = false;
      return false;
    }

    try {
      final startDateTime = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );

      MeetupType meetupType;
      String? eventTypeId;
      if (showCustomTypeInput.value || selectedTypeId.value == null) {
        meetupType = MeetupType.fromString(typeController.text.isEmpty ? 'social' : typeController.text.toLowerCase());
      } else {
        final selectedEventType = eventTypeController.getEventTypeById(selectedTypeId.value!);
        if (selectedEventType != null) {
          eventTypeId = selectedEventType.id;
          meetupType = MeetupType.fromString(selectedEventType.enName.toLowerCase());
          log('✅ 使用事件类型: ${selectedEventType.name} (ID: $eventTypeId)');
        } else {
          meetupType =
              MeetupType.fromString(typeController.text.isEmpty ? 'social' : typeController.text.toLowerCase());
        }
      }

      List<String> uploadedImageUrls = [];
      if (selectedImages.isNotEmpty) {
        uploadedImageUrls = await uploadVenueImages(context);
      }

      final allImages = [...existingImageUrls, ...uploadedImageUrls];

      if (isEditMode) {
        final updatedMeetup = await meetupController.updateMeetup(
          meetupId: editingMeetup!.id,
          title: titleController.text,
          description: descriptionController.text,
          cityId: selectedCityId.value,
          venue: venueController.text,
          venueAddress: venueController.text,
          category: eventTypeId ?? meetupType.value,
          startTime: startDateTime,
          maxAttendees: maxAttendees.value.toInt(),
          imageUrl: allImages.isNotEmpty ? allImages.first : null,
          images: allImages.isEmpty ? null : allImages,
          latitude: venueLatitude.value,
          longitude: venueLongitude.value,
        );

        if (updatedMeetup == null) return false;

        AppToast.success(l10n.updateSuccess, title: l10n.success);
      } else {
        final createdMeetup = await meetupController.createMeetup(
          title: titleController.text,
          type: meetupType,
          eventTypeId: eventTypeId,
          description: descriptionController.text,
          cityId: selectedCityId.value ?? '',
          venue: venueController.text,
          venueAddress: venueController.text,
          startTime: startDateTime,
          maxAttendees: maxAttendees.value.toInt(),
          imageUrl: allImages.isNotEmpty ? allImages.first : null,
          images: allImages.isEmpty ? null : allImages,
        );

        if (createdMeetup == null) return false;

        await _createMeetupChatRoom(
          meetupId: createdMeetup.id,
          meetupTitle: createdMeetup.title,
          meetupType: meetupType.value,
        );

        AppToast.success(l10n.meetupCreatedSuccess, title: l10n.success);

        // 提示用户添加到日历（在返回之前等待用户操作完成）
        if (context.mounted) {
          await CalendarService().showAddToCalendarDialog(
            context: context,
            title: titleController.text,
            description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
            location: venueController.text,
            startTime: startDateTime,
          );
        }
      }

      selectedImages.clear();
      isSubmitting.value = false;
      return true;
    } catch (e) {
      log('❌ 创建 meetup 失败: $e');
      isSubmitting.value = false;
      return false;
    }
  }

  Future<void> _createMeetupChatRoom(
      {required String meetupId, required String meetupTitle, String? meetupType}) async {
    try {
      final chatRepository = Get.find<IChatRepository>();
      final result = await chatRepository.getOrCreateMeetupChatRoom(
          meetupId: meetupId, meetupTitle: meetupTitle, meetupType: meetupType);
      switch (result) {
        case Success(:final data):
          log('✅ Meetup 聊天室创建成功: ${data.id}');
        case Failure(:final exception):
          log('⚠️ 创建 Meetup 聊天室失败: $exception');
      }
    } catch (e) {
      log('⚠️ 创建 Meetup 聊天室异常: $e');
    }
  }
}
