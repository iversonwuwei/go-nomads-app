import 'dart:developer';

import 'dart:io';

import 'package:df_admin_mobile/config/app_colors.dart';
import 'package:df_admin_mobile/core/domain/result.dart';
import 'package:df_admin_mobile/features/user_city_content/domain/repositories/iuser_city_content_repository.dart';
import 'package:df_admin_mobile/generated/app_localizations.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
  void initState() {
    super.initState();
    _validateCityId();
  }

  /// 验证 cityId 是否为有效的 UUID 格式
  void _validateCityId() {
    if (widget.cityId.isEmpty || !_isValidUuid(widget.cityId)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.error(
          l10n.invalidCityId,
          title: l10n.error,
        );
        Get.back();
      });
    }
  }

  /// 检查是否为有效的 UUID 格式
  bool _isValidUuid(String id) {
    final uuidRegex = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
      caseSensitive: false,
    );
    return uuidRegex.hasMatch(id);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.cityPrimary,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.xmark, color: Colors.white, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.writeAReview,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.cityName,
              style: TextStyle(
                color: Colors.white70,
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
            hintText: l10n.reviewTitleHint,
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
            counterStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textTertiary,
            ),
          ),
          validator: (value) {
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
            hintText: l10n.experienceHint,
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
            counterStyle: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textTertiary,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.pleaseShareExperience;
            }
            if (value.trim().length < 20) {
              return l10n.experienceMinLength;
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(FontAwesomeIcons.images,
                    color: AppColors.textSecondary, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  l10n.photos,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  l10n.optional,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            Obx(() => Text(
                  '${_selectedImages.length} / 5',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _selectedImages.length >= 5
                        ? const Color(0xFFFF4458)
                        : AppColors.textSecondary,
                  ),
                )),
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
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderLight,
          width: 1.w,
        ),
      ),
      child: Stack(
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
          // 删除按钮
          Positioned(
            top: 4.h,
            right: 4.w,
            child: GestureDetector(
              onTap: () => _selectedImages.removeAt(index),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
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
      ),
    );
  }

  /// 添加图片按钮
  Widget _buildAddImageButton() {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100.w,
        height: 100.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: const Color(0xFFFF4458),
            width: 2.w,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.photoFilm,
              color: const Color(0xFFFF4458),
              size: 32.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              l10n.addPhoto,
              style: TextStyle(
                fontSize: 12.sp,
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.2),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.circleInfo, color: Colors.blue, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                l10n.reviewGuidelines,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildGuidelineItem(l10n.guidelineHonest),
          _buildGuidelineItem(l10n.guidelineFacts),
          _buildGuidelineItem(l10n.guidelineRespect),
          _buildGuidelineItem(l10n.guidelinePhotos),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13.sp,
          color: AppColors.textSecondary,
          height: 1.4,
        ),
      ),
    );
  }

  /// 底部栏
  Widget _buildBottomBar() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(20.w),
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
              onPressed: _isSubmitting.value ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cityPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
                disabledBackgroundColor:
                    AppColors.cityPrimary.withValues(alpha: 0.5),
              ),
              child: _isSubmitting.value
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FontAwesomeIcons.circleCheck, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          l10n.submitReview,
                          style: TextStyle(
                            fontSize: 16.sp,
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
    final l10n = AppLocalizations.of(context)!;

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
      AppToast.error(
        l10n.failedToPickImages('$e'),
        title: l10n.error,
      );
    }
  }

  /// 提交评论
  Future<void> _submitReview() async {
    final l10n = AppLocalizations.of(context)!;

    // 验证评分
    if (_rating.value == 0) {
      AppToast.warning(
        l10n.pleaseSelectRating,
        title: l10n.missingRating,
      );
      return;
    }

    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _isSubmitting.value = true;

    try {
      // 实际的 API 调用
      final apiService = Get.find<IUserCityContentRepository>();

      log('🔄 Submitting review for city: ${widget.cityId}');
      log('   Rating: ${_rating.value.round()}');
      log('   Title: ${_titleController.text.trim()}');
      
      final result = await apiService.upsertCityReview(
        cityId: widget.cityId,
        rating: _rating.value.round(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        // visitDate: 可以添加一个日期选择器
      );

      log('✅ API Response: ${result.runtimeType}');

      switch (result) {
        case Success(:final data):
          log('✅ Success! Review data: $data');

          // 先重置按钮状态,让用户看到提交完成
          _isSubmitting.value = false;

          // 显示成功提示
          if (mounted) {
            AppToast.success(
              l10n.reviewSubmitted,
              title: l10n.success,
            );
          }

          log('🔙 等待 Toast 显示后跳转...');

          // 等待 Toast 显示
          await Future.delayed(const Duration(milliseconds: 800));

          // 返回上一页并传递结果
          if (mounted) {
            log('✅ Widget mounted, calling Get.back()');
            Get.back(result: {
              'success': true,
              'review': data,
            });
            log('✅ Get.back() called');
          } else {
            log('❌ Widget not mounted, cannot navigate');
          }
          return;
          
        case Failure(:final exception):
          log('❌ Failure: $exception');
          AppToast.error(
            l10n.failedToSubmitReview(exception.toString()),
            title: l10n.error,
          );
          _isSubmitting.value = false;
      }
    } catch (e, stackTrace) {
      log('❌ Exception caught: $e');
      log('Stack trace: $stackTrace');
      AppToast.error(
        l10n.failedToSubmitReview('$e'),
        title: l10n.error,
      );
      _isSubmitting.value = false;
    }
  }

  /// 获取评分标签
  String _getRatingLabel(double rating) {
    final l10n = AppLocalizations.of(context)!;

    if (rating >= 4.5) return l10n.excellent;
    if (rating >= 4.0) return l10n.veryGood;
    if (rating >= 3.0) return l10n.good;
    if (rating >= 2.0) return l10n.fair;
    if (rating >= 1.0) return l10n.poor;
    return l10n.veryPoor;
  }
}
