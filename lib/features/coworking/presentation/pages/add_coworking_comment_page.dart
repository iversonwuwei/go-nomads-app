import 'dart:io';

import 'package:df_admin_mobile/config/supabase_config.dart';
import 'package:df_admin_mobile/features/coworking/infrastructure/repositories/coworking_review_repository.dart';
import 'package:df_admin_mobile/services/image_upload_service.dart';
import 'package:df_admin_mobile/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// Coworking 评论创建页面
class AddCoworkingCommentPage extends StatefulWidget {
  final String coworkingId;
  final String coworkingName;

  const AddCoworkingCommentPage({
    super.key,
    required this.coworkingId,
    required this.coworkingName,
  });

  @override
  State<AddCoworkingCommentPage> createState() =>
      _AddCoworkingCommentPageState();
}

class _AddCoworkingCommentPageState extends State<AddCoworkingCommentPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  final _imagePicker = ImagePicker();
  bool _isSubmitting = false;
  double _rating = 0.0; // 评分 (0-5 星，支持0.5步长)
  DateTime? _visitDate;

  @override
  void dispose() {
    _titleController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images);
        // 限制最多 5 张图片
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
          AppToast.error('最多只能上传 5 张图片');
        }
      });
    } catch (e) {
      print('选择图片失败: $e');
    }
  }

  Future<void> _selectVisitDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: '选择访问日期',
      cancelText: '取消',
      confirmText: '确定',
    );
    if (picked != null && picked != _visitDate) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) {
      AppToast.error('请输入评论内容');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final reviewRepository = Get.find<CoworkingReviewRepository>();

      // 上传图片到存储服务
      List<String>? imageUrls;
      if (_selectedImages.isNotEmpty) {
        // 检查 Supabase 配置
        if (!SupabaseConfig.isConfigured) {
          AppToast.error('图片上传服务未配置，请联系技术支持');
          setState(() {
            _isSubmitting = false;
          });
          return;
        }

        try {
          final imageUploadService = ImageUploadService();

          // 转换 XFile 为 File
          final imageFiles =
              _selectedImages.map((xFile) => File(xFile.path)).toList();

          // 显示上传提示
          AppToast.info('正在上传 ${imageFiles.length} 张图片...');

          debugPrint('📤 开始上传 ${imageFiles.length} 张图片');

          // 上传图片到 Supabase Storage
          imageUrls = await imageUploadService.uploadMultipleImages(
            imageFiles: imageFiles,
            bucket: SupabaseConfig.defaultBucket,
            folder: 'coworking-reviews/${widget.coworkingId}',
            compress: true,
            quality: 85,
            maxWidth: 1920,
            maxHeight: 1920,
            onProgress: (current, total) {
              debugPrint('📊 上传进度: $current/$total');
            },
          );

          if (imageUrls.isEmpty) {
            throw Exception('未能上传任何图片');
          }

          debugPrint('✅ 图片上传成功: ${imageUrls.length} 张');
          debugPrint('📸 图片 URLs: $imageUrls');

          AppToast.success('已上传 ${imageUrls.length} 张图片');
        } catch (e) {
          debugPrint('❌ 图片上传失败: $e');
          AppToast.warning('图片上传失败: ${e.toString()}');
          imageUrls = null;
        }
      }

      debugPrint('🚀 准备提交评论：');
      debugPrint('  - coworkingId: ${widget.coworkingId}');
      debugPrint('  - rating: $_rating');
      debugPrint('  - title: ${_titleController.text}');
      debugPrint('  - content: $content');
      debugPrint('  - photoUrls: $imageUrls');
      debugPrint('  - visitDate: $_visitDate');

      await reviewRepository.addReview(
        coworkingId: widget.coworkingId,
        rating: _rating.toDouble(),
        title: _titleController.text.trim(),
        content: content,
        visitDate: _visitDate,
        photoUrls: imageUrls,
      );

      debugPrint('✅ 评论创建成功，准备关闭页面');

      // 立即关闭页面并返回成功结果
      if (mounted) {
        Get.back(result: true); // 返回 true 表示成功创建
      }
    } catch (e) {
      debugPrint('❌ 评论创建失败: $e');
      AppToast.error('发布评论失败: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('发表评论 - ${widget.coworkingName}'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submitComment,
              child: const Text(
                '发布',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 评分区域
              _buildRatingSection(),
              const SizedBox(height: 24),

              // 标题输入框
              TextField(
                controller: _titleController,
                maxLength: 100,
                decoration: InputDecoration(
                  labelText: '评价标题',
                  hintText: '用一句话总结您的体验',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 24),

              // 访问日期选择器
              InkWell(
                onTap: _isSubmitting ? null : _selectVisitDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '访问日期（可选）',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: const Icon(FontAwesomeIcons.calendar),
                  ),
                  child: Text(
                    _visitDate == null
                        ? '选择您的访问日期'
                        : '${_visitDate!.year}-${_visitDate!.month.toString().padLeft(2, '0')}-${_visitDate!.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: _visitDate == null
                          ? Colors.grey[600]
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 评论输入框
              TextField(
                controller: _commentController,
                maxLines: 8,
                maxLength: 1000,
                decoration: InputDecoration(
                  hintText: '分享您的体验...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                enabled: !_isSubmitting,
              ),
              const SizedBox(height: 24),

              // 图片上传区域标题
              Row(
                children: [
                  const Icon(FontAwesomeIcons.images, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '添加图片 (${_selectedImages.length}/5)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 图片网格预览
              _buildImageGrid(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建评分区域
  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(FontAwesomeIcons.solidStar, color: Colors.amber, size: 20),
              SizedBox(width: 8),
              Text(
                '您的评分',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTapDown: _isSubmitting
                    ? null
                    : (details) {
                        // 通过点击位置判断是半星还是整星
                        final RenderBox box =
                            context.findRenderObject() as RenderBox;
                        final starSize = 40.0;
                        final padding = 4.0;
                        final totalWidth = starSize + padding * 2;

                        // 计算相对于整个Row的x坐标
                        final localX =
                            box.globalToLocal(details.globalPosition).dx;

                        // 计算点击的是哪颗星
                        final clickedIndex = (localX / totalWidth).floor();

                        if (clickedIndex >= 0 && clickedIndex < 5) {
                          // 计算在该星星内的相对位置
                          final offsetInStar = (localX % totalWidth) - padding;
                          final relativePos = offsetInStar / starSize;

                          setState(() {
                            // 点击左半部分给半星，右半部分给整星
                            if (relativePos < 0.5) {
                              _rating = clickedIndex + 0.5;
                            } else {
                              _rating = clickedIndex + 1.0;
                            }
                          });
                        }
                      },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildStarIcon(index),
                ),
              );
            }),
          ),
          if (_rating > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFA000), // 深黄色背景
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white, // 白色文字
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getRatingText(_rating),
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (_rating == 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '点击星星选择评分（点击左侧半星，右侧整星）',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建星星图标
  Widget _buildStarIcon(int index) {
    final fullStars = _rating.floor();
    final hasHalfStar = (_rating - fullStars) >= 0.5;

    IconData iconData;
    Color color;

    if (index < fullStars) {
      // 完整的星星 - 实心黄色星
      iconData = FontAwesomeIcons.solidStar;
      color = const Color(0xFFFFA000); // 深黄色/橙黄色
    } else if (index == fullStars && hasHalfStar) {
      // 半星 - 黄色
      iconData = FontAwesomeIcons.starHalfAlt;
      color = const Color(0xFFFFA000); // 深黄色/橙黄色
    } else {
      // 空星 - 浅灰色边框
      iconData = FontAwesomeIcons.star; // regular空心星
      color = const Color(0xFFE0E0E0); // 浅灰色
    }

    return Icon(
      iconData,
      color: color,
      size: 40,
    );
  }

  /// 获取评分文本
  String _getRatingText(double rating) {
    if (rating >= 4.5) {
      return '非常棒，强烈推荐';
    } else if (rating >= 3.5) {
      return '很好，值得推荐';
    } else if (rating >= 2.5) {
      return '还可以，基本满意';
    } else if (rating >= 1.5) {
      return '一般，有待改进';
    } else if (rating >= 0.5) {
      return '很差，不推荐';
    } else {
      return '';
    }
  }

  /// 构建图片网格
  Widget _buildImageGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // 已选择的图片
        ..._selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return _buildImageItem(image, index);
        }),
        // 添加图片按钮
        if (_selectedImages.length < 5) _buildAddImageButton(),
      ],
    );
  }

  /// 构建单个图片项
  Widget _buildImageItem(XFile image, int index) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
          ),
          if (!_isSubmitting)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    FontAwesomeIcons.xmark,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建添加图片按钮
  Widget _buildAddImageButton() {
    return GestureDetector(
      onTap: _isSubmitting ? null : _pickImages,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.photoFilm,
              size: 32,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 4),
            Text(
              '添加图片',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
