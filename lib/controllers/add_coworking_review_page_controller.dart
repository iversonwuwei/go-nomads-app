import 'dart:developer';
import 'dart:io';

import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// AddCoworkingReviewPage 控制器
class AddCoworkingReviewPageController extends GetxController {
  final String coworkingId;
  final String coworkingName;

  AddCoworkingReviewPageController({
    required this.coworkingId,
    required this.coworkingName,
  });

  // Form
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  // 状态
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxDouble rating = 0.0.obs;
  final RxBool isSubmitting = false.obs;
  final Rx<DateTime?> visitDate = Rx<DateTime?>(null);

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  /// 选择图片
  Future<void> pickImages(String maxPhotosWarning) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (selectedImages.length + images.length > 5) {
        Get.snackbar('', maxPhotosWarning);
        return;
      }
      selectedImages.addAll(images);
    }
  }

  /// 拍照
  Future<void> takePhoto(String maxPhotosWarning) async {
    if (selectedImages.length >= 5) {
      Get.snackbar('', maxPhotosWarning);
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      selectedImages.add(image);
    }
  }

  /// 移除图片
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  /// 选择访问日期
  Future<void> selectVisitDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: visitDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      visitDate.value = picked;
    }
  }

  /// 提交评论
  Future<bool> submit({
    required String pleaseSelectRating,
    required String submitSuccess,
    required String Function(String) submitFailed,
  }) async {
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (rating.value == 0) {
      Get.snackbar('', pleaseSelectRating);
      return false;
    }

    isSubmitting.value = true;

    try {
      log('📝 开始提交评论...');
      log('   coworkingId: $coworkingId');
      log('   rating: ${rating.value}');
      log('   title: ${titleController.text.trim()}');

      final repository = Get.find<ICoworkingReviewRepository>();

      // 上传图片到 Supabase Storage
      List<String> photoUrls = [];
      if (selectedImages.isNotEmpty) {
        log('📷 开始上传 ${selectedImages.length} 张图片...');
        try {
          final imageUploadService = ImageUploadService();
          final imageFiles = selectedImages.map((xFile) => File(xFile.path)).toList();

          photoUrls = await imageUploadService.uploadMultipleImages(
            imageFiles: imageFiles,
            bucket: 'user-uploads',
            folder: 'coworking-reviews/$coworkingId',
            compress: true,
            quality: 85,
            onProgress: (current, total) {
              log('📷 图片上传进度: $current/$total');
            },
          );
          log('✅ 图片上传完成，共 ${photoUrls.length} 张');
        } catch (e) {
          log('⚠️ 图片上传失败: $e');
          // 图片上传失败不阻止评论提交，继续提交无图片的评论
        }
      }

      await repository.addReview(
        coworkingId: coworkingId,
        rating: rating.value,
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        visitDate: visitDate.value,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
      );

      log('✅ 评论提交成功');

      // 发送数据变更事件通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'coworking_review',
        entityId: coworkingId,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.created,
      ));
      log('✅ [Coworking评论] 已发送数据变更事件');

      isSubmitting.value = false;

      Get.snackbar('', submitSuccess);

      return true;
    } catch (e) {
      log('❌ 提交评论失败: $e');
      Get.snackbar('', submitFailed('$e'));
      isSubmitting.value = false;
      return false;
    }
  }

  /// 获取评分对应的表情符号
  String getRatingEmoji(double ratingValue) {
    if (ratingValue == 0) return '🤔';
    if (ratingValue <= 1.0) return '😢';
    if (ratingValue <= 2.0) return '😕';
    if (ratingValue <= 3.0) return '😐';
    if (ratingValue <= 4.0) return '🙂';
    if (ratingValue <= 4.5) return '😊';
    return '🤩';
  }

  /// 获取评分对应的颜色
  Color getRatingColor(double ratingValue) {
    if (ratingValue == 0) return Colors.grey;
    if (ratingValue <= 1.5) return const Color(0xFFE74C3C); // 红色
    if (ratingValue <= 2.5) return const Color(0xFFE67E22); // 橙色
    if (ratingValue <= 3.5) return const Color(0xFFF39C12); // 黄色
    if (ratingValue <= 4.5) return const Color(0xFF2ECC71); // 绿色
    return const Color(0xFF9B59B6); // 紫色（完美）
  }

  /// 获取评分标签
  String getRatingLabel(double ratingValue, {
    required String excellent,
    required String good,
    required String fair,
    required String poor,
    required String veryPoor,
  }) {
    if (ratingValue >= 4.5) return excellent;
    if (ratingValue >= 3.5) return good;
    if (ratingValue >= 2.5) return fair;
    if (ratingValue >= 1.5) return poor;
    return veryPoor;
  }
}
