import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../config/supabase_config.dart';
import '../services/image_upload_service.dart';

/// 图片上传工具类
/// 
/// 提供便捷的图片选择和上传方法
class ImageUploadHelper {
  static final _picker = ImagePicker();
  static final _uploadService = ImageUploadService();

  /// 从相机拍照并上传
  /// 
  /// [bucket] 存储桶名称
  /// [folder] 文件夹路径
  /// [compress] 是否压缩
  /// [onProgress] 上传进度回调
  static Future<String?> captureAndUpload({
    String? bucket,
    String? folder,
    bool compress = true,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: SupabaseConfig.maxWidth.toDouble(),
        maxHeight: SupabaseConfig.maxHeight.toDouble(),
        imageQuality: SupabaseConfig.defaultQuality,
      );

      if (photo == null) return null;

      return await _uploadService.uploadImage(
        imageFile: File(photo.path),
        bucket: bucket ?? SupabaseConfig.defaultBucket,
        folder: folder,
        compress: compress,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('❌ 拍照上传失败: $e');
      rethrow;
    }
  }

  /// 从相册选择图片并上传
  /// 
  /// [bucket] 存储桶名称
  /// [folder] 文件夹路径
  /// [compress] 是否压缩
  /// [onProgress] 上传进度回调
  static Future<String?> pickAndUpload({
    String? bucket,
    String? folder,
    bool compress = true,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: SupabaseConfig.maxWidth.toDouble(),
        maxHeight: SupabaseConfig.maxHeight.toDouble(),
        imageQuality: SupabaseConfig.defaultQuality,
      );

      if (image == null) return null;

      return await _uploadService.uploadImage(
        imageFile: File(image.path),
        bucket: bucket ?? SupabaseConfig.defaultBucket,
        folder: folder,
        compress: compress,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('❌ 选择上传失败: $e');
      rethrow;
    }
  }

  /// 选择多张图片并上传
  /// 
  /// [maxImages] 最多选择多少张，默认 9 张
  static Future<List<String>> pickMultipleAndUpload({
    String? bucket,
    String? folder,
    bool compress = true,
    int maxImages = 9,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: SupabaseConfig.maxWidth.toDouble(),
        maxHeight: SupabaseConfig.maxHeight.toDouble(),
        imageQuality: SupabaseConfig.defaultQuality,
      );

      if (images.isEmpty) return [];

      // 限制数量
      final selectedImages = images.take(maxImages).toList();
      
      final imageFiles = selectedImages.map((xFile) => File(xFile.path)).toList();
      
      return await _uploadService.uploadMultipleImages(
        imageFiles: imageFiles,
        bucket: bucket ?? SupabaseConfig.defaultBucket,
        folder: folder,
        compress: compress,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('❌ 批量上传失败: $e');
      rethrow;
    }
  }

  /// 显示图片来源选择对话框
  /// 
  /// 让用户选择从相机拍照或从相册选择
  static Future<String?> showImageSourceDialog(
    BuildContext context, {
    String? bucket,
    String? folder,
    bool compress = true,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return await captureAndUpload(
        bucket: bucket,
        folder: folder,
        compress: compress,
      );
    } else {
      return await pickAndUpload(
        bucket: bucket,
        folder: folder,
        compress: compress,
      );
    }
  }

  /// 上传头像（专用优化）
  /// 
  /// 头像使用更高的压缩质量和固定尺寸
  static Future<String?> uploadAvatar(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                '选择头像',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (source == null) return null;

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: SupabaseConfig.avatarMaxSize.toDouble(),
        maxHeight: SupabaseConfig.avatarMaxSize.toDouble(),
        imageQuality: SupabaseConfig.avatarQuality,
      );

      if (image == null) return null;

      return await _uploadService.uploadImage(
        imageFile: File(image.path),
        bucket: SupabaseConfig.buckets['avatars']!,
        folder: 'avatars',
        compress: true,
        quality: SupabaseConfig.avatarQuality,
        maxWidth: SupabaseConfig.avatarMaxSize,
        maxHeight: SupabaseConfig.avatarMaxSize,
      );
    } catch (e) {
      debugPrint('❌ 头像上传失败: $e');
      rethrow;
    }
  }
}

/// 带进度的图片上传 Widget
class ImageUploadWidget extends StatefulWidget {
  final String? bucket;
  final String? folder;
  final bool compress;
  final Function(String imageUrl) onUploadSuccess;
  final Function(String error)? onUploadError;
  final Widget? placeholder;
  final bool showProgress;

  const ImageUploadWidget({
    super.key,
    this.bucket,
    this.folder,
    this.compress = true,
    required this.onUploadSuccess,
    this.onUploadError,
    this.placeholder,
    this.showProgress = true,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  bool _uploading = false;
  double _progress = 0.0;
  String? _uploadedUrl;

  Future<void> _handleUpload() async {
    try {
      setState(() {
        _uploading = true;
        _progress = 0.0;
      });

      final url = await ImageUploadHelper.showImageSourceDialog(
        context,
        bucket: widget.bucket,
        folder: widget.folder,
        compress: widget.compress,
      );

      if (url != null) {
        setState(() {
          _uploadedUrl = url;
          _progress = 1.0;
        });
        widget.onUploadSuccess(url);
      }
    } catch (e) {
      widget.onUploadError?.call(e.toString());
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _uploading ? null : _handleUpload,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_uploadedUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _uploadedUrl!,
                  fit: BoxFit.cover,
                ),
              )
            else
              widget.placeholder ??
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('点击上传图片', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
            if (_uploading)
              Container(
                color: Colors.black54,
                child: Center(
                  child: widget.showProgress
                      ? CircularProgressIndicator(
                          value: _progress > 0 ? _progress : null,
                          backgroundColor: Colors.white24,
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
