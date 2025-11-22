import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_colors.dart';
import '../features/coworking/domain/repositories/icoworking_review_repository.dart';
import '../widgets/app_toast.dart';

/// 添加 Coworking Review 页面
class AddCoworkingReviewPage extends StatefulWidget {
  final String coworkingId;
  final String coworkingName;

  const AddCoworkingReviewPage({
    super.key,
    required this.coworkingId,
    required this.coworkingName,
  });

  @override
  State<AddCoworkingReviewPage> createState() => _AddCoworkingReviewPageState();
}

class _AddCoworkingReviewPageState extends State<AddCoworkingReviewPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final RxList<XFile> _selectedImages = <XFile>[].obs;
  final RxDouble _rating = 0.0.obs;
  final RxBool _isSubmitting = false.obs;
  DateTime? _visitDate;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 选择图片
  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (_selectedImages.length + images.length > 5) {
        AppToast.warning('最多只能选择5张图片');
        return;
      }
      _selectedImages.addAll(images);
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 5) {
      AppToast.warning('最多只能选择5张图片');
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      _selectedImages.add(image);
    }
  }

  /// 移除图片
  void _removeImage(int index) {
    _selectedImages.removeAt(index);
  }

  /// 选择访问日期
  Future<void> _selectVisitDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  /// 提交评论
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating.value == 0) {
      AppToast.warning('请选择评分');
      return;
    }

    _isSubmitting.value = true;

    try {
      print('📝 开始提交评论...');
      print('   coworkingId: ${widget.coworkingId}');
      print('   rating: ${_rating.value}');
      print('   title: ${_titleController.text.trim()}');
      
      final repository = Get.find<ICoworkingReviewRepository>();

      // TODO: 上传图片到服务器获取 URLs
      // 这里暂时传递空数组，实际应该先上传图片
      final photoUrls = <String>[];

      final result = await repository.addReview(
        coworkingId: widget.coworkingId,
        rating: _rating.value,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        visitDate: _visitDate,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
      );

      print('✅ 评论提交成功: ${result.id}');

      if (mounted) {
        AppToast.success('评论提交成功！');
        // 延迟一下让 Toast 显示
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      }
    } catch (e) {
      print('❌ 提交评论失败: $e');
      if (mounted) {
        AppToast.error('提交失败: $e');
      }
    } finally {
      if (mounted) {
        _isSubmitting.value = false;
      }
    }
  }

  /// 获取评分标签
  String _getRatingLabel(double rating) {
    if (rating >= 4.5) return 'Excellent!';
    if (rating >= 3.5) return 'Good';
    if (rating >= 2.5) return 'Average';
    if (rating >= 1.5) return 'Below Average';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.coworkingName,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            // Rating Section
            _buildRatingSection(),
            SizedBox(height: 32.h),

            // Visit Date
            _buildVisitDateSection(),
            SizedBox(height: 24.h),

            // Title Input
            _buildTitleInput(),
            SizedBox(height: 24.h),

            // Content Input
            _buildContentInput(),
            SizedBox(height: 24.h),

            // Photos Section
            _buildPhotosSection(),
            SizedBox(height: 32.h),

            // Guidelines
            _buildGuidelines(),
            SizedBox(height: 96.h),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  /// 评分区域
  Widget _buildRatingSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.star_border,
                  color: const Color(0xFFFF4458), size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Overall Rating',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final fullStar = index < _rating.value.floor();
                  final halfStar = index < _rating.value &&
                      index >= _rating.value.floor() &&
                      _rating.value % 1 != 0;

                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: GestureDetector(
                      onTap: () {
                        _rating.value = (index + 1).toDouble();
                      },
                      child: Icon(
                        fullStar
                            ? Icons.star
                            : halfStar
                                ? Icons.star_half
                                : Icons.star_border,
                        color: const Color(0xFFFF4458),
                        size: 44.sp,
                      ),
                    ),
                  );
                }),
              )),
          SizedBox(height: 16.h),
          Obx(() => Text(
                _rating.value == 0
                    ? 'Tap stars to rate'
                    : '${_rating.value.toStringAsFixed(1)} / 5.0',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: _rating.value == 0
                      ? AppColors.textTertiary
                      : const Color(0xFFFF4458),
                ),
              )),
          if (_rating.value > 0)
            Obx(() => Text(
                  _getRatingLabel(_rating.value),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                )),
        ],
      ),
    );
  }

  /// 访问日期区域
  Widget _buildVisitDateSection() {
    return InkWell(
      onTap: _selectVisitDate,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visit Date (Optional)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (_visitDate != null)
                    Text(
                      '${_visitDate!.year}-${_visitDate!.month.toString().padLeft(2, '0')}-${_visitDate!.day.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else
                    Text(
                      'When did you visit?',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 标题输入
  Widget _buildTitleInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.title, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Review Title',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                color: const Color(0xFFFF4458),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _titleController,
          maxLength: 100,
          decoration: InputDecoration(
            hintText: 'Sum up your experience in a few words',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFFF4458),
                width: 2.w,
              ),
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
        Row(
          children: [
            Icon(Icons.edit_note, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Your Experience',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              '*',
              style: TextStyle(
                color: const Color(0xFFFF4458),
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        TextFormField(
          controller: _contentController,
          maxLength: 1000,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Share your experience about WiFi, workspace, atmosphere...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(
                color: const Color(0xFFFF4458),
                width: 2.w,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please share your experience';
            }
            if (value.trim().length < 20) {
              return 'Review must be at least 20 characters';
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
          children: [
            Icon(Icons.add_photo_alternate,
                color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              'Photos (Optional)',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() => Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: [
                ..._selectedImages.asMap().entries.map((entry) {
                  final index = entry.key;
                  final image = entry.value;
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(image.path),
                          width: 100.w,
                          height: 100.w,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4.h,
                        right: 4.w,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                if (_selectedImages.length < 5)
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choose from gallery'),
                                onTap: () {
                                  Get.back();
                                  _pickImages();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt),
                                title: const Text('Take a photo'),
                                onTap: () {
                                  Get.back();
                                  _takePhoto();
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.borderLight,
                          width: 2.w,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 32.sp,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            )),
      ],
    );
  }

  /// 指南
  Widget _buildGuidelines() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'Review Guidelines',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '• Be honest and specific\n'
            '• Focus on workspace features\n'
            '• Mention WiFi, noise, facilities\n'
            '• Be respectful and constructive',
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.blue[900],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 底部提交栏
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, -2.h),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => ElevatedButton(
              onPressed: _isSubmitting.value ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4458),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: _isSubmitting.value
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Submit Review',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            )),
      ),
    );
  }
}
