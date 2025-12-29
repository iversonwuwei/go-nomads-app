import 'dart:developer';
import 'dart:io';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/sync/sync.dart';
import 'package:df_admin_mobile/features/coworking/domain/repositories/icoworking_review_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      if (_selectedImages.length + images.length > 5) {
        AppToast.warning(l10n.maxPhotosWarning);
        return;
      }
      _selectedImages.addAll(images);
    }
  }

  /// 拍照
  Future<void> _takePhoto() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selectedImages.length >= 5) {
      AppToast.warning(l10n.maxPhotosWarning);
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
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rating.value == 0) {
      AppToast.warning(l10n.pleaseSelectRating);
      return;
    }

    _isSubmitting.value = true;

    try {
      log('📝 开始提交评论...');
      log('   coworkingId: ${widget.coworkingId}');
      log('   rating: ${_rating.value}');
      log('   title: ${_titleController.text.trim()}');

      final repository = Get.find<ICoworkingReviewRepository>();

      // 上传图片到 Supabase Storage
      List<String> photoUrls = [];
      if (_selectedImages.isNotEmpty) {
        log('📷 开始上传 ${_selectedImages.length} 张图片...');
        try {
          final imageUploadService = ImageUploadService();
          final imageFiles = _selectedImages.map((xFile) => File(xFile.path)).toList();

          photoUrls = await imageUploadService.uploadMultipleImages(
            imageFiles: imageFiles,
            bucket: 'user-uploads',
            folder: 'coworking-reviews/${widget.coworkingId}',
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

      final result = await repository.addReview(
        coworkingId: widget.coworkingId,
        rating: _rating.value,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        visitDate: _visitDate,
        photoUrls: photoUrls.isNotEmpty ? photoUrls : null,
      );

      log('✅ 评论提交成功: ${result.id}');

      // 发送数据变更事件通知其他组件
      DataEventBus.instance.emit(DataChangedEvent(
        entityType: 'coworking_review',
        entityId: widget.coworkingId,
        version: DateTime.now().millisecondsSinceEpoch,
        changeType: DataChangeType.created,
      ));
      log('✅ [Coworking评论] 已发送数据变更事件');

      // 显示成功提示
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.success(l10n.coworkingReviewSubmitSuccess);
      }

      log('🔙 准备跳转...');

      // 立即返回，不要等待
      if (mounted) {
        log('✅ Widget mounted, calling Navigator.pop()');
        Navigator.of(context).pop(true);
        log('✅ Navigator.pop() called');
      }

      // 重置按钮状态
      _isSubmitting.value = false;
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      log('❌ 提交评论失败: $e');
      AppToast.error(l10n.submitFailed('$e'));
      _isSubmitting.value = false;
    }
  }

  /// 获取评分标签
  String _getRatingLabel(double rating) {
    final l10n = AppLocalizations.of(context)!;
    if (rating >= 4.5) return l10n.excellent;
    if (rating >= 3.5) return l10n.good;
    if (rating >= 2.5) return l10n.fair;
    if (rating >= 1.5) return l10n.poor;
    return l10n.veryPoor;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.xmark, color: AppColors.textPrimary, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.writeAReview,
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

  /// 评分区域 - 创意表情滑动条设计
  Widget _buildRatingSection() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            _getRatingColor(_rating.value).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: _getRatingColor(_rating.value).withValues(alpha: 0.15),
            blurRadius: 20.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        children: [
          // 标题
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.faceSmile,
                color: _getRatingColor(_rating.value),
                size: 24.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.overallRating,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),

          // 大表情符号显示
          Obx(() => AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Text(
                  _getRatingEmoji(_rating.value),
                  key: ValueKey<double>(_rating.value),
                  style: TextStyle(
                    fontSize: 80.sp,
                    height: 1.0,
                  ),
                ),
              )),
          SizedBox(height: 24.h),

          // 评分文字
          Obx(() => Column(
                children: [
                  Text(
                    _rating.value == 0 ? l10n.tapStarsToRate : _getRatingLabel(_rating.value),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: _getRatingColor(_rating.value),
                    ),
                  ),
                  if (_rating.value > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      '${_rating.value.toStringAsFixed(1)} / 5.0',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              )),
          SizedBox(height: 32.h),

          // 滑动条
          Obx(() => Column(
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 8.h,
                      activeTrackColor: _getRatingColor(_rating.value),
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: Colors.white,
                      overlayColor: _getRatingColor(_rating.value).withValues(alpha: 0.2),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 16.r,
                        elevation: 4,
                      ),
                      overlayShape: RoundSliderOverlayShape(
                        overlayRadius: 28.r,
                      ),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: _rating.value,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      onChanged: (value) {
                        _rating.value = value;
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 表情符号刻度
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        final value = index.toDouble();
                        final isSelected = (_rating.value - value).abs() < 0.3;
                        return GestureDetector(
                          onTap: () => _rating.value = value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.all(isSelected ? 8.w : 4.w),
                            decoration: BoxDecoration(
                              color: isSelected ? _getRatingColor(value).withValues(alpha: 0.15) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              _getRatingEmoji(value),
                              style: TextStyle(
                                fontSize: isSelected ? 28.sp : 20.sp,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  /// 获取评分对应的表情符号
  String _getRatingEmoji(double rating) {
    if (rating == 0) return '🤔';
    if (rating <= 1.0) return '😢';
    if (rating <= 2.0) return '😕';
    if (rating <= 3.0) return '😐';
    if (rating <= 4.0) return '🙂';
    if (rating <= 4.5) return '😊';
    return '🤩';
  }

  /// 获取评分对应的颜色
  Color _getRatingColor(double rating) {
    if (rating == 0) return Colors.grey;
    if (rating <= 1.5) return const Color(0xFFE74C3C); // 红色
    if (rating <= 2.5) return const Color(0xFFE67E22); // 橙色
    if (rating <= 3.5) return const Color(0xFFF39C12); // 黄色
    if (rating <= 4.5) return const Color(0xFF2ECC71); // 绿色
    return const Color(0xFF9B59B6); // 紫色（完美）
  }

  /// 访问日期区域
  Widget _buildVisitDateSection() {
    final l10n = AppLocalizations.of(context)!;

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
            Icon(FontAwesomeIcons.calendar, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.visitDateOptional,
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
                      l10n.whenDidYouVisit,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(FontAwesomeIcons.chevronRight, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  /// 标题输入
  Widget _buildTitleInput() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.heading, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.reviewTitle,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.required,
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
            hintText: l10n.sumUpExperience,
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
            final l10n = AppLocalizations.of(context)!;
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseEnterTitle;
            }
            if (value.trim().length < 5) {
              return l10n.titleMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 内容输入
  Widget _buildContentInput() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.penToSquare, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.yourExperience,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Text(
              l10n.required,
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
            hintText: l10n.coworkingExperienceHint,
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
            final l10n = AppLocalizations.of(context)!;
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseShareExperience;
            }
            if (value.trim().length < 20) {
              return l10n.reviewMinLength;
            }
            return null;
          },
        ),
      ],
    );
  }

  /// 照片区域
  Widget _buildPhotosSection() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(FontAwesomeIcons.photoFilm, color: AppColors.textSecondary, size: 20.sp),
            SizedBox(width: 8.w),
            Text(
              l10n.photosOptional,
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
                              FontAwesomeIcons.xmark,
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
                      final l10n = AppLocalizations.of(context)!;
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(FontAwesomeIcons.images),
                                title: Text(l10n.chooseFromGallery),
                                onTap: () {
                                  Get.back();
                                  _pickImages();
                                },
                              ),
                              ListTile(
                                leading: const Icon(FontAwesomeIcons.camera),
                                title: Text(l10n.takeAPhoto),
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
                            FontAwesomeIcons.photoFilm,
                            size: 32.sp,
                            color: AppColors.textTertiary,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            l10n.addPhoto,
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
    final l10n = AppLocalizations.of(context)!;

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
              Icon(FontAwesomeIcons.circleInfo, color: Colors.blue[700], size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                l10n.reviewGuidelines,
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
            '${l10n.coworkingGuidelineHonest}\n'
            '${l10n.coworkingGuidelineFocus}\n'
            '${l10n.coworkingGuidelineMention}\n'
            '${l10n.coworkingGuidelineRespectful}',
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
    final l10n = AppLocalizations.of(context)!;

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
                      l10n.submitReview,
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
