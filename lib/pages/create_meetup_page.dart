import 'dart:developer';
import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/config/supabase_config.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/chat/domain/repositories/i_chat_repository.dart';
import 'package:df_admin_mobile/features/location/presentation/controllers/location_state_controller.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/event_type.dart';
import 'package:df_admin_mobile/features/meetup/domain/entities/meetup.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/event_type_controller.dart';
import 'package:df_admin_mobile/features/meetup/presentation/controllers/meetup_state_controller.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:df_admin_mobile/widgets/back_button.dart';
import 'package:df_admin_mobile/widgets/location_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'venue_map_picker/venue_map_picker_page.dart';

class CreateMeetupPage extends StatefulWidget {
  /// 编辑模式：传入要编辑的 Meetup
  final Meetup? editingMeetup;

  const CreateMeetupPage({super.key, this.editingMeetup});

  /// 是否是编辑模式
  bool get isEditMode => editingMeetup != null;

  @override
  State<CreateMeetupPage> createState() => _CreateMeetupPageState();
}

class _CreateMeetupPageState extends State<CreateMeetupPage> {
  /// 是否是编辑模式（便捷访问）
  bool get isEditMode => widget.isEditMode;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _venueController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _venueErrorText;
  String? _selectedCity;
  String? _selectedCountry;
  String? _selectedCityId;
  String? _selectedCountryId;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double _maxAttendees = 10;

  // 类型相关
  List<EventType> _meetupTypes = [];
  bool _isLoadingTypes = false;
  bool _showCustomTypeInput = false;
  String? _selectedType; // 显示用的名称
  String? _selectedTypeId; // 后端需要的 type ID

  // 图片相关
  final List<XFile> _selectedImages = [];
  final List<String> _existingImageUrls = []; // 编辑模式: 已上传的图片URL
  final ImagePicker _imagePicker = ImagePicker();
  final ImageUploadService _imageUploadService = ImageUploadService();
  bool _isUploadingImages = false;
  double _uploadProgress = 0.0;

  // 地点坐标
  double? _venueLatitude;
  double? _venueLongitude;
  bool _isSubmitting = false;

  final LocationStateController _locationController = Get.find<LocationStateController>();
  final MeetupStateController meetupController = Get.find<MeetupStateController>();
  final EventTypeController _eventTypeController = Get.put(EventTypeController());

  @override
  void initState() {
    super.initState();
    _locationController.loadCountries();
    _loadMeetupTypes();

    // 如果是编辑模式，填充现有数据
    if (widget.isEditMode) {
      _fillFormWithExistingData(widget.editingMeetup!);
    }
  }

  /// 编辑模式：用现有数据填充表单
  void _fillFormWithExistingData(Meetup meetup) {
    log('✏️ [CreateMeetup] 编辑模式 - 填充现有数据');

    _titleController.text = meetup.title;
    _descriptionController.text = meetup.description;
    _venueController.text = meetup.venue.name;

    // 日期时间
    _selectedDate = meetup.schedule.startTime;
    _selectedTime = TimeOfDay.fromDateTime(meetup.schedule.startTime);

    // 人数上限
    _maxAttendees = meetup.capacity.maxAttendees.toDouble();

    // 地点
    _selectedCity = meetup.location.city;
    _selectedCountry = meetup.location.country;
    // 注意：Venue 实体目前没有 latitude/longitude 字段
    // 如需要可以后续扩展 Venue 实体或从后端 EventResponse 获取

    // 类型
    if (meetup.eventType != null) {
      _selectedTypeId = meetup.eventType!.id;
      _selectedType = meetup.eventType!.name;
    }

    // 图片
    _existingImageUrls.addAll(meetup.images);
  }

  Future<void> _loadMeetupTypes() async {
    setState(() {
      _isLoadingTypes = true;
    });

    try {
      // 从 EventTypeController 加载类型列表（自动使用缓存）
      await _eventTypeController.loadEventTypes();

      setState(() {
        _meetupTypes = _eventTypeController.eventTypes;
      });

      log('✅ 成功加载 ${_meetupTypes.length} 个事件类型');
    } catch (e) {
      log('❌ 加载聚会类型失败: $e');
      // EventTypeController 已有后备方案，直接使用
      setState(() {
        _meetupTypes = _eventTypeController.eventTypes;
      });
    } finally {
      setState(() {
        _isLoadingTypes = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _venueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
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
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _selectVenueFromMap() async {
    log('🗺️ 打开地图选择器...');
    final result = await Get.to<Map<String, dynamic>>(
      () => VenueMapPickerPage(
        cityName: _selectedCity ?? 'Bangkok',
      ),
    );

    if (result != null) {
      log('✅ 选择了venue: ${result['name']}');
      setState(() {
        _venueController.text = '${result['name']} - ${result['address']}';
        _venueErrorText = null;
      });
    } else {
      log('⚠️ 用户取消了选择');
    }
  }

  // 选择图片
  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        setState(() {
          // 限制最多上传 10 张图片
          if (_selectedImages.length + images.length <= 10) {
            _selectedImages.addAll(images);
          } else {
            final remaining = 10 - _selectedImages.length;
            if (remaining > 0) {
              _selectedImages.addAll(images.take(remaining));
              final l10n = AppLocalizations.of(context)!;
              AppToast.warning(
                l10n.maximumImagesAllowed,
                title: l10n.notice,
              );
            } else {
              final l10n = AppLocalizations.of(context)!;
              AppToast.warning(
                l10n.maximumImagesAllowed,
                title: l10n.notice,
              );
            }
          }
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        l10n.failedToPickImages(e.toString()),
        title: l10n.error,
      );
    }
  }

  // 从相机拍照
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (_selectedImages.length < 10) {
            _selectedImages.add(image);
          } else {
            AppToast.warning(
              'Maximum 10 images allowed',
              title: 'Notice',
            );
          }
        });
      }
    } catch (e) {
      AppToast.error(
        'Failed to take photo: ${e.toString()}',
        title: 'Error',
      );
    }
  }

  // 删除图片
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  // 删除已上传的图片
  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  // 显示图片选择选项
  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
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
              // 顶部指示器
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // 标题
              Text(
                AppLocalizations.of(context)!.addVenuePhotos,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              // 从相册选择
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.images,
                    color: Color(0xFFFF4458),
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context)!.chooseFromGallery,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.selectMultiplePhotos(_selectedImages.length),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _pickImages();
                },
              ),
              // 拍照
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.camera,
                    color: Color(0xFFFF4458),
                  ),
                ),
                title: Text(
                  AppLocalizations.of(context)!.takePhoto,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  AppLocalizations.of(context)!.useCameraToTakePhoto,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                onTap: () {
                  Get.back();
                  _takePhoto();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Future<List<String>> _uploadVenueImages() async {
    if (_selectedImages.isEmpty) {
      return [];
    }

    if (!SupabaseConfig.isConfigured) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        'Image upload service is not configured. Please contact support.',
        title: l10n.error,
      );
      throw Exception('Supabase not configured');
    }

    if (mounted) {
      setState(() {
        _isUploadingImages = true;
        _uploadProgress = 0.0;
      });
    }

    final l10n = AppLocalizations.of(context)!;
    final imageFiles = _selectedImages.map((image) => File(image.path)).toList();
    final sanitizedFolderSegment =
        (_selectedCityId?.isNotEmpty == true ? _selectedCityId! : (_selectedCity ?? 'general'))
            .replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
    final folderPath = 'meetups/$sanitizedFolderSegment/venues';

    AppToast.info(
      'Uploading ${imageFiles.length} venue photo${imageFiles.length > 1 ? 's' : ''}...',
      title: l10n.notice,
    );

    try {
      final uploadedUrls = await _imageUploadService.uploadMultipleImages(
        imageFiles: imageFiles,
        bucket: SupabaseConfig.defaultBucket,
        folder: folderPath,
        onProgress: (current, total) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = total == 0 ? 0 : current / total;
          });
        },
      );

      if (uploadedUrls.isEmpty) {
        throw Exception('No venue photos were uploaded');
      }

      AppToast.success(
        'Uploaded ${uploadedUrls.length} venue photo${uploadedUrls.length > 1 ? 's' : ''}',
        title: l10n.success,
      );

      return uploadedUrls;
    } catch (e) {
      AppToast.error(
        'Failed to upload venue photos: $e',
        title: l10n.error,
      );
      rethrow;
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }

  void _showOptionPicker({
    required List<String> options,
    required String title,
    String? initialValue,
    required ValueChanged<String> onSelected,
  }) {
    if (options.isEmpty) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.info(l10n.noData, title: l10n.notice);
      return;
    }

    final l10n = AppLocalizations.of(context)!;

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
                      l10n.cancel,
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
                      l10n.confirm,
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

  void _createMeetup() async {
    if (_isUploadingImages || _isSubmitting) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCity == null || _selectedDate == null || _selectedTime == null) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        l10n.pleaseFillAllFields,
        title: l10n.error,
      );
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isSubmitting = true;
        });
      }

      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // 获取选中的 EventType（用于传递给后端）
      MeetupType meetupType;
      String? eventTypeId; // EventType 的 UUID
      if (_showCustomTypeInput || _selectedTypeId == null) {
        // 自定义类型或未选择类型时，使用输入的文本
        meetupType =
            MeetupType.fromString(_typeController.text.isEmpty ? 'social' : _typeController.text.toLowerCase());
      } else {
        // 从 EventTypeController 获取选中的 EventType
        final selectedEventType = _eventTypeController.getEventTypeById(_selectedTypeId!);
        if (selectedEventType != null) {
          // 使用 EventType 的 ID 和 enName
          eventTypeId = selectedEventType.id;
          meetupType = MeetupType.fromString(selectedEventType.enName.toLowerCase());
          log('✅ 使用事件类型: ${selectedEventType.name} (ID: $eventTypeId)');
        } else {
          // 如果找不到（不应该发生），回退到文本
          meetupType =
              MeetupType.fromString(_typeController.text.isEmpty ? 'social' : _typeController.text.toLowerCase());
        }
      }

      List<String> uploadedImageUrls = [];
      if (_selectedImages.isNotEmpty) {
        uploadedImageUrls = await _uploadVenueImages();
      }

      // 合并现有图片和新上传的图片
      final allImages = [..._existingImageUrls, ...uploadedImageUrls];

      if (isEditMode) {
        // 编辑模式：更新活动
        final updatedMeetup = await meetupController.updateMeetup(
          meetupId: widget.editingMeetup!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          cityId: _selectedCityId,
          venue: _venueController.text,
          venueAddress: _venueController.text,
          category: eventTypeId ?? meetupType.value,
          startTime: startDateTime,
          maxAttendees: _maxAttendees.toInt(),
          imageUrl: allImages.isNotEmpty ? allImages.first : null,
          images: allImages.isEmpty ? null : allImages,
          latitude: _venueLatitude,
          longitude: _venueLongitude,
        );

        if (updatedMeetup == null) {
          return;
        }

        final l10n = AppLocalizations.of(context)!;
        AppToast.success(
          l10n.updateSuccess,
          title: l10n.success,
        );
      } else {
        // 创建模式：创建新活动
        final createdMeetup = await meetupController.createMeetup(
          title: _titleController.text,
          type: meetupType,
          eventTypeId: eventTypeId, // 传递 UUID
          description: _descriptionController.text,
          cityId: _selectedCityId ?? '',
          venue: _venueController.text,
          venueAddress: _venueController.text,
          startTime: startDateTime,
          maxAttendees: _maxAttendees.toInt(),
          imageUrl: allImages.isNotEmpty ? allImages.first : null,
          images: allImages.isEmpty ? null : allImages,
        );

        if (createdMeetup == null) {
          return;
        }

        // 🔧 创建 Meetup 聊天室并自动将创建者加入
        await _createMeetupChatRoom(
          meetupId: createdMeetup.id,
          meetupTitle: createdMeetup.title,
          meetupType: meetupType.value,
        );

        final l10n = AppLocalizations.of(context)!;
        AppToast.success(
          l10n.meetupCreatedSuccess,
          title: l10n.success,
        );

        await _showAddToCalendarDialog();
      }

      if (mounted) {
        setState(() {
          _selectedImages.clear();
        });
      }

      // 延迟导航以避免 widget 树重建时的状态问题
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.back(result: true);
      });
    } catch (e) {
      log('❌ 创建 meetup 失败: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// 创建 Meetup 聊天室（创建者自动加入群聊）
  Future<void> _createMeetupChatRoom({
    required String meetupId,
    required String meetupTitle,
    String? meetupType,
  }) async {
    try {
      final chatRepository = Get.find<IChatRepository>();
      final result = await chatRepository.getOrCreateMeetupChatRoom(
        meetupId: meetupId,
        meetupTitle: meetupTitle,
        meetupType: meetupType,
      );

      switch (result) {
        case Success(:final data):
          log('✅ Meetup 聊天室创建成功: ${data.id}');
        case Failure(:final exception):
          log('⚠️ 创建 Meetup 聊天室失败: $exception');
        // 不阻止 Meetup 创建流程，只记录错误
      }
    } catch (e) {
      log('⚠️ 创建 Meetup 聊天室异常: $e');
      // 不阻止 Meetup 创建流程
    }
  }

  Future<void> _showAddToCalendarDialog() async {
    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 日历图标
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4458).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  FontAwesomeIcons.calendar,
                  color: Color(0xFFFF4458),
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              // 标题
              Text(
                AppLocalizations.of(context)!.addToCalendar,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              // 描述
              Text(
                AppLocalizations.of(context)!.addToCalendarMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              // 按钮
              Row(
                children: [
                  // 取消按钮
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[300]!),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.notNow,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 确认按钮
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _addToCalendar();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4458),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.addToCalendarButton,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _addToCalendar() async {
    // 组合日期和时间
    final DateTime eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // 创建日历事件 (默认持续2小时)
    final Event event = Event(
      title: _titleController.text,
      description:
          _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Meetup organized via Nomads.com',
      location: _venueController.text,
      startDate: eventDateTime,
      endDate: eventDateTime.add(const Duration(hours: 2)),
      iosParams: const IOSParams(
        reminder: Duration(minutes: 30), // 提前30分钟提醒
      ),
      androidParams: const AndroidParams(
        emailInvites: [], // 可以添加邮件邀请
      ),
    );

    try {
      // 添加到系统日历
      final result = await Add2Calendar.addEvent2Cal(event);

      final l10n = AppLocalizations.of(context)!;
      if (result) {
        AppToast.success(
          l10n.eventAddedToCalendar,
          title: l10n.success,
        );
      } else {
        AppToast.warning(
          'Calendar operation was cancelled',
          title: l10n.notice,
        );
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      AppToast.error(
        l10n.failedToAddEvent(e.toString()),
        title: l10n.error,
      );
      // Calendar error logged
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          isEditMode ? l10n.editMeetup : l10n.createMeetup,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          children: [
            // Title
            Text(
              AppLocalizations.of(context)!.meetupTitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterMeetupTitle,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context)!.pleaseEnterTitle;
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Type
            Text(
              AppLocalizations.of(context)!.meetupType,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (!_showCustomTypeInput)
              FormField<String>(
                initialValue: _selectedType,
                validator: (value) {
                  if ((value == null || value.isEmpty) && _typeController.text.isEmpty) {
                    return AppLocalizations.of(context)!.pleaseEnterType;
                  }
                  return null;
                },
                builder: (field) {
                  final displayType = field.value ?? _selectedType;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      final l10n = AppLocalizations.of(context)!;

                      if (_isLoadingTypes) {
                        AppToast.info(l10n.loading, title: l10n.notice);
                        return;
                      }

                      if (_meetupTypes.isEmpty) {
                        AppToast.info(l10n.noData, title: l10n.notice);
                        return;
                      }

                      FocusScope.of(context).unfocus();

                      // 获取当前语言环境
                      final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();

                      // 构建显示选项（本地化名称）
                      final displayOptions = _meetupTypes.map((type) => type.getDisplayName(localeCode)).toList();
                      final optionsWithCustom = [...displayOptions, '+ 自定义类型'];

                      _showOptionPicker(
                        options: optionsWithCustom,
                        title: l10n.meetupType,
                        initialValue: _selectedType,
                        onSelected: (value) {
                          if (value == '+ 自定义类型') {
                            setState(() {
                              _showCustomTypeInput = true;
                              _selectedType = null;
                              _selectedTypeId = null;
                              _typeController.clear();
                            });
                            field.didChange(null);
                          } else {
                            // 根据显示名称找到对应的 EventType
                            final selectedEventType = _meetupTypes.firstWhereOrNull(
                              (type) => type.getDisplayName(localeCode) == value,
                            );

                            if (selectedEventType != null) {
                              setState(() {
                                _selectedType = value;
                                _selectedTypeId = selectedEventType.id;
                                _typeController.text = value;
                              });
                              field.didChange(value);
                              log('✅ 选择类型: ${selectedEventType.name} (ID: ${selectedEventType.id})');
                            }
                          }
                        },
                      );
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.meetupTypeHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        suffixIcon: _isLoadingTypes
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : const Icon(FontAwesomeIcons.chevronDown),
                        errorText: field.errorText,
                      ),
                      isEmpty: displayType == null || displayType.isEmpty,
                      child: Text(
                        displayType ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: displayType == null || displayType.isEmpty
                                  ? Theme.of(context).hintColor
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                      ),
                    ),
                  );
                },
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _typeController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: '输入自定义类型',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.pleaseEnterType;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(FontAwesomeIcons.xmark, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        _showCustomTypeInput = false;
                        _typeController.clear();
                      });
                    },
                    tooltip: '返回选择列表',
                  ),
                ],
              ),

            const SizedBox(height: 20),

            // City (with Country+City combined picker)
            LocationPickerField(
              initialCountryId: _selectedCountryId,
              initialCountryName: _selectedCountry,
              initialCityId: _selectedCityId,
              initialCityName: _selectedCity,
              required: true,
              onChanged: (result) {
                setState(() {
                  _selectedCountryId = result.countryId;
                  _selectedCountry = result.countryName;
                  _selectedCityId = result.cityId;
                  _selectedCity = result.cityName;
                });
              },
            ),

            const SizedBox(height: 20),

            // Venue with Map Button
            Text(
              AppLocalizations.of(context)!.venue,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _venueController,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enterVenue,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.borderLight),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _venueErrorText != null && _venueErrorText!.isNotEmpty
                                  ? Theme.of(context).colorScheme.error
                                  : AppColors.borderLight,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _venueErrorText != null && _venueErrorText!.isNotEmpty
                                  ? Theme.of(context).colorScheme.error
                                  : const Color(0xFFFF4458),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        validator: (value) {
                          final l10n = AppLocalizations.of(context)!;
                          if (value == null || value.isEmpty) {
                            setState(() {
                              _venueErrorText = l10n.pleaseEnterVenue;
                            });
                            return '';
                          }
                          setState(() {
                            _venueErrorText = null;
                          });
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _selectVenueFromMap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4458),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Icon(FontAwesomeIcons.map, size: 20),
                      ),
                    ),
                  ],
                ),
                if (_venueErrorText != null && _venueErrorText!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, top: 4),
                    child: Text(
                      _venueErrorText!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Date and Time
            Row(
              children: [
                // Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.date,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.calendar, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _selectedDate == null
                                    ? AppLocalizations.of(context)!.selectDate
                                    : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedDate == null ? Colors.grey : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.time,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _selectTime,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.clock, size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime == null
                                    ? AppLocalizations.of(context)!.selectTime
                                    : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _selectedTime == null ? Colors.grey : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Max Attendees
            Text(
              AppLocalizations.of(context)!.maxAttendees,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _maxAttendees,
                    min: 2,
                    max: 50,
                    divisions: 48,
                    activeColor: const Color(0xFFFF4458),
                    label: _maxAttendees.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        _maxAttendees = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _maxAttendees.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF4458),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              AppLocalizations.of(context)!.description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterMeetupDescription,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 20),

            // Venue Photos Section
            Text(
              AppLocalizations.of(context)!.venuePhotos,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.addVenuePhotosCount(_existingImageUrls.length + _selectedImages.length),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // 图片网格显示
            if (_existingImageUrls.isNotEmpty || _selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: _existingImageUrls.length + _selectedImages.length + 1, // +1 for add button
                itemBuilder: (context, index) {
                  final totalImages = _existingImageUrls.length + _selectedImages.length;

                  if (index == totalImages) {
                    // 添加更多图片按钮
                    return InkWell(
                      onTap: totalImages < 10 ? _showImagePickerOptions : null,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade300,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color:
                              totalImages < 10 ? const Color(0xFFFF4458).withValues(alpha: 0.05) : Colors.grey.shade100,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.photoFilm,
                              size: 32,
                              color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.addPhoto,
                              style: TextStyle(
                                fontSize: 11,
                                color: totalImages < 10 ? const Color(0xFFFF4458) : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // 判断是已上传的图片还是新选择的图片
                  final isExistingImage = index < _existingImageUrls.length;

                  // 图片缩略图
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isExistingImage
                            ? Image.network(
                                _existingImageUrls[index],
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      FontAwesomeIcons.image,
                                      color: Colors.grey.shade400,
                                    ),
                                  );
                                },
                              )
                            : Image.file(
                                File(_selectedImages[index - _existingImageUrls.length].path),
                                fit: BoxFit.cover,
                              ),
                      ),
                      // 删除按钮
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            if (isExistingImage) {
                              _removeExistingImage(index);
                            } else {
                              _removeImage(index - _existingImageUrls.length);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              FontAwesomeIcons.xmark,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      // 主图标记
                      if (index == 0)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF4458),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.coverPhoto,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),

            if (_isUploadingImages)
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _uploadProgress > 0 ? _uploadProgress : null,
                            valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFF4458),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Uploading venue photos... (${(_uploadProgress * 100).clamp(0, 100).toStringAsFixed(0)}%)',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      minHeight: 4,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFF4458)),
                    ),
                  ],
                ),
              ),

            // 如果没有图片，显示添加按钮
            if (_existingImageUrls.isEmpty && _selectedImages.isEmpty)
              InkWell(
                onTap: _showImagePickerOptions,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.photoFilm,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.addVenuePhotos,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context)!.tapToSelectPhoto,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),

            // Create Button
            Obx(() {
              final isControllerLoading = meetupController.isLoading.value;
              final isProcessing = isControllerLoading || _isUploadingImages || _isSubmitting;
              final l10n = AppLocalizations.of(context)!;
              final buttonLabel = isEditMode ? l10n.save : l10n.createMeetup;

              return SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isProcessing ? null : _createMeetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4458),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              buttonLabel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          buttonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              );
            }),

            // 底部安全区域间距
            SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
          ],
        ),
      ),
    );
  }
}
