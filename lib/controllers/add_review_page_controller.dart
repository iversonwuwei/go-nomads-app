import 'dart:developer';

import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// AddReviewPage 控制器
class AddReviewPageController extends GetxController {
  final String cityId;
  final String cityName;

  AddReviewPageController({
    required this.cityId,
    required this.cityName,
  });

  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxDouble rating = 0.0.obs;
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    contentController.dispose();
    super.onClose();
  }

  /// 检查是否为有效的 UUID 格式
  bool isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  /// 验证 cityId
  bool validateCityId() {
    return cityId.isNotEmpty && isValidUuid(cityId);
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
    if (ratingValue <= 1.5) return const Color(0xFFE74C3C);
    if (ratingValue <= 2.5) return const Color(0xFFE67E22);
    if (ratingValue <= 3.5) return const Color(0xFFF39C12);
    if (ratingValue <= 4.5) return const Color(0xFF2ECC71);
    return const Color(0xFF9B59B6);
  }

  /// 选择图片
  Future<void> pickImages({
    required String errorTitle,
    required String Function(String) failedToPickImages,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      final remainingSlots = 5 - selectedImages.length;
      final imagesToAdd = images.take(remainingSlots).toList();
      selectedImages.addAll(imagesToAdd);
    } catch (e) {
      AppToast.error(
        failedToPickImages('$e'),
        title: errorTitle,
      );
    }
  }

  /// 移除图片
  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  /// 提交评论
  Future<bool> submitReview({
    required String pleaseSelectRating,
    required String missingRating,
    required String reviewSubmitted,
    required String successTitle,
    required String errorTitle,
    required String Function(String) failedToSubmitReview,
  }) async {
    // 验证评分
    if (rating.value == 0) {
      AppToast.warning(pleaseSelectRating, title: missingRating);
      return false;
    }

    // 验证表单
    if (!formKey.currentState!.validate()) {
      return false;
    }

    isSubmitting.value = true;

    try {
      final apiService = Get.find<IUserCityContentRepository>();

      log('🔄 Submitting review for city: $cityId');
      log('   Rating: ${rating.value.round()}');
      log('   Title: ${titleController.text.trim()}');

      final result = await apiService.upsertCityReview(
        cityId: cityId,
        rating: rating.value.round(),
        title: titleController.text.trim(),
        content: contentController.text.trim(),
      );

      log('✅ API Response: ${result.runtimeType}');

      switch (result) {
        case Success(:final data):
          log('✅ Success! Review data: $data');

          DataEventBus.instance.emit(DataChangedEvent(
            entityType: 'city_review',
            entityId: cityId,
            version: DateTime.now().millisecondsSinceEpoch,
            changeType: DataChangeType.created,
          ));
          log('✅ [城市评论] 已发送数据变更事件');

          isSubmitting.value = false;
          AppToast.success(reviewSubmitted, title: successTitle);

          await Future.delayed(const Duration(milliseconds: 800));

          Get.back(result: {'success': true, 'review': data});
          return true;

        case Failure(:final exception):
          log('❌ Failure: $exception');
          AppToast.error(
            failedToSubmitReview(exception.toString()),
            title: errorTitle,
          );
          isSubmitting.value = false;
          return false;
      }
    } catch (e, stackTrace) {
      log('❌ Exception caught: $e');
      log('Stack trace: $stackTrace');
      AppToast.error(failedToSubmitReview('$e'), title: errorTitle);
      isSubmitting.value = false;
      return false;
    }
  }
}
