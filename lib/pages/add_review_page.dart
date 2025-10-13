import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';

/// 添加 Review 页面 - 独立页面形式
class AddReviewPage extends StatefulWidget {
  final String cityId;
  final String cityName;

  const AddReviewPage({
    super.key,
    required this.cityId,
    required this.cityName,
  });

  @override
  State<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends State<AddReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final RxList<XFile> _selectedImages = <XFile>[].obs;
  final RxDouble _rating = 0.0.obs;
  final RxBool _isSubmitting = false.obs;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Write a Review',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.cityName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Rating Section
            _buildRatingSection(),
            const SizedBox(height: 32),

            // Title Input
            _buildTitleInput(),
            const SizedBox(height: 24),

            // Content Input
            _buildContentInput(),
            const SizedBox(height: 24),

            // Photos Section
            _buildPhotosSection(),
            const SizedBox(height: 32),

            // Guidelines
            _buildGuidelines(),
            const SizedBox(height: 96),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 评分区域
  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.star_border, color: Color(0xFFFF4458), size: 24),
              SizedBox(width: 8),
              Text(
                'Overall Rating',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final fullStar = index < _rating.value.floor();
                  final halfStar = index < _rating.value &&
                      index >= _rating.value.floor() &&
                      _rating.value % 1 != 0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: SizedBox(
                      width: 44,
                      height: 44,
                      child: Stack(
                        children: [
                          // 星星图标
                          Icon(
                            fullStar
                                ? Icons.star
                                : halfStar
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: const Color(0xFFFF4458),
                            size: 44,
                          ),
                          // 左半边点击区域
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            width: 22,
                            child: GestureDetector(
                              onTap: () {
                                _rating.value = index + 0.5;
                              },
                              behavior: HitTestBehavior.opaque,
                            ),
                          ),
                          // 右半边点击区域
                          Positioned(
                            right: 0,
                            top: 0,
                            bottom: 0,
                            width: 22,
                            child: GestureDetector(
                              onTap: () {
                                _rating.value = (index + 1).toDouble();
                              },
                              behavior: HitTestBehavior.opaque,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              )),
          const SizedBox(height: 16),
          Obx(() => Text(
                _rating.value == 0
                    ? 'Tap stars to rate'
                    : '${_rating.value.toStringAsFixed(1)} / 5.0',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _rating.value == 0
                      ? AppColors.textTertiary
                      : const Color(0xFFFF4458),
                ),
              )),
          if (_rating.value > 0)
            Obx(() => Text(
                  _getRatingLabel(_rating.value),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                )),
        ],
      ),
    );
  }

  /// 标题输入
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.title, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Review Title',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'e.g., Amazing place for digital nomads!',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF4458),
                width: 2,
              ),
            ),
            counterStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a title';
            }
            if (value.trim().length < 5) {
              return 'Title must be at least 5 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 内容输入
  Widget _buildContentInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 8),
            Text(
              'Your Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                color: Color(0xFFFF4458),
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _contentController,
          maxLength: 1000,
          maxLines: 8,
          decoration: InputDecoration(
            hintText:
                'Share your experience, tips, and recommendations...\n\nWhat did you like most?\nWhat could be improved?\nAny tips for other nomads?',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFFF4458),
                width: 2,
              ),
            ),
            counterStyle: const TextStyle(
              fontSize: 12,
              color: AppColors.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please share your experience';
            }
            if (value.trim().length < 20) {
              return 'Please write at least 20 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 照片区域
  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.photo_library,
                    color: AppColors.textSecondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Photos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '(Optional)',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            Obx(() => Text(
                  '${_selectedImages.length} / 5',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedImages.length >= 5
                        ? const Color(0xFFFF4458)
                        : AppColors.textSecondary,
                  ),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ..._selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return _buildImageThumbnail(image, index);
                }),
                if (_selectedImages.length < 5) _buildAddImageButton(),
              ],
            )),
      ],
    );
  }

  /// 图片缩略图
  Widget _buildImageThumbnail(XFile image, int index) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(image.path),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          // 删除按钮
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _selectedImages.removeAt(index),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 添加图片按钮
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFF4458),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              color: Color(0xFFFF4458),
              size: 32,
            ),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFFFF4458),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 指南
  Widget _buildGuidelines() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Review Guidelines',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuidelineItem('✓ Be honest and detailed about your experience'),
          _buildGuidelineItem('✓ Focus on facts and specific examples'),
          _buildGuidelineItem('✓ Respect others and avoid offensive language'),
          _buildGuidelineItem('✓ Photos should be relevant and appropriate'),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  /// 底部栏
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
              onPressed: _isSubmitting.value ? null : _submitReview,
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
                          'Submit Review',
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

  /// 选择图片
  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      final remainingSlots = 5 - _selectedImages.length;
      final imagesToAdd = images.take(remainingSlots).toList();
      _selectedImages.addAll(imagesToAdd);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        backgroundColor: const Color(0xFFFF4458),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// 提交评论
  Future<void> _submitReview() async {
    // 验证评分
    if (_rating.value == 0) {
      Get.snackbar(
        '⚠️ Missing Rating',
        'Please select a rating before submitting',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 2));

      // TODO: 实际的 API 调用
      // await reviewService.submitReview(
      //   cityId: widget.cityId,
      //   rating: _rating.value,
      //   title: _titleController.text.trim(),
      //   content: _contentController.text.trim(),
      //   images: _selectedImages,
      // );

      Get.back(result: {
        'rating': _rating.value,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'imageCount': _selectedImages.length,
      });

      Get.snackbar(
        '✅ Success',
        'Your review has been submitted successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar(
        '❌ Error',
        'Failed to submit review: $e',
        backgroundColor: const Color(0xFFFF4458),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isSubmitting.value = false;
    }
  }

  /// 获取评分标签
  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent!';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.0) return 'Good';
    if (rating >= 2.0) return 'Fair';
    if (rating >= 1.0) return 'Poor';
    return 'Very Poor';
  }
}
