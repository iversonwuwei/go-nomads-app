import 'package:df_admin_mobile/features/user_city_content/presentation/controllers/user_city_content_state_controller.dart';
import 'package:df_admin_mobile/pages/flutter_map_picker_page.dart';
import 'package:df_admin_mobile/utils/image_upload_helper.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// 城市照片提交页面控制器
class CityPhotoSubmissionPageController extends GetxController {
  final String cityId;
  final String cityName;

  static const int maxPhotoCount = 10;

  CityPhotoSubmissionPageController({
    required this.cityId,
    required this.cityName,
  });

  // 表单控制器
  final titleController = TextEditingController();
  final locationNoteController = TextEditingController();
  final descriptionController = TextEditingController();

  /// 已上传的照片URL列表
  final RxList<String> photoUrls = <String>[].obs;

  /// 是否正在上传图片
  final RxBool isUploadingImages = false.obs;

  /// 是否正在提交
  final RxBool isSubmitting = false.obs;

  /// 上传状态信息
  final Rx<String?> uploadStatus = Rx<String?>(null);

  /// 选中的纬度
  final Rx<double?> selectedLat = Rx<double?>(null);

  /// 选中的经度
  final Rx<double?> selectedLng = Rx<double?>(null);

  /// 剩余可上传数量
  int get remainingSlots => maxPhotoCount - photoUrls.length;

  /// 获取 UserCityContentStateController
  UserCityContentStateController get contentController => Get.find<UserCityContentStateController>();

  @override
  void onClose() {
    titleController.dispose();
    locationNoteController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  /// 强制隐藏键盘（使用系统级 API）
  void _hideKeyboard() {
    // 使用系统级 API 强制隐藏键盘，避免拍照/选图返回后键盘占位
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    // 同时清除焦点
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// 从相册选择照片
  Future<void> pickFromGallery() async {
    if (remainingSlots <= 0) {
      AppToast.info('最多只能上传 $maxPhotoCount 张照片');
      return;
    }

    // 在打开相册前强制隐藏键盘
    _hideKeyboard();

    isUploadingImages.value = true;
    uploadStatus.value = null;

    try {
      final newUrls = await ImageUploadHelper.pickMultipleAndUpload(
        folder: 'city_photos/$cityId',
        maxImages: remainingSlots,
        onProgress: (current, total) {
          uploadStatus.value = '上传进度 $current / $total';
        },
      );

      if (newUrls.isNotEmpty) {
        photoUrls.addAll(newUrls);
      }
    } catch (e) {
      AppToast.error('选择照片失败: $e');
    } finally {
      isUploadingImages.value = false;
      uploadStatus.value = null;
    }
  }

  /// 拍照上传
  Future<void> capturePhoto() async {
    if (remainingSlots <= 0) {
      AppToast.info('最多只能上传 $maxPhotoCount 张照片');
      return;
    }

    // 在打开相机前强制隐藏键盘
    _hideKeyboard();

    isUploadingImages.value = true;

    try {
      final url = await ImageUploadHelper.captureAndUpload(
        folder: 'city_photos/$cityId',
      );

      if (url != null) {
        photoUrls.add(url);
      }
    } catch (e) {
      AppToast.error('拍照失败: $e');
    } finally {
      isUploadingImages.value = false;
    }
  }

  /// 移除照片
  void removePhoto(int index) {
    photoUrls.removeAt(index);
  }

  /// 打开地图选择器
  Future<void> openMapPicker() async {
    final address = locationNoteController.text.trim();

    final result = await Get.to<Map<String, dynamic>>(
      () => FlutterMapPickerPage(
        initialLatitude: selectedLat.value,
        initialLongitude: selectedLng.value,
        searchQuery: address,
      ),
    );

    if (result != null) {
      selectedLat.value = result['latitude'] as double?;
      selectedLng.value = result['longitude'] as double?;

      // 更新地址信息
      final addressText = result['address'] as String? ?? '';
      final nameText = result['name'] as String? ?? '';

      // 优先使用 name，如果为空则使用 address
      final displayText = nameText.isNotEmpty ? nameText : addressText;

      if (displayText.isNotEmpty) {
        locationNoteController.text = displayText;
      }
    }
  }

  /// 提交照片
  Future<bool> submit(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (photoUrls.isEmpty) {
      AppToast.info('请至少上传一张照片');
      return false;
    }

    isSubmitting.value = true;

    final success = await contentController.submitPhotoCollection(
      cityId: cityId,
      title: titleController.text.trim(),
      imageUrls: photoUrls.toList(),
      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
      locationNote: locationNoteController.text.trim().isEmpty ? null : locationNoteController.text.trim(),
      reloadAfterSubmit: true,
    );

    isSubmitting.value = false;

    if (success) {
      AppToast.success('照片已提交');
      return true;
    } else {
      AppToast.error('提交失败，请稍后再试');
      return false;
    }
  }
}
