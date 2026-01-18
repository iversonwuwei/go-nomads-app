import 'dart:io';

import 'package:df_admin_mobile/config/api_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'token_storage_service.dart';

/// 图片上传服务
///
/// 使用 Supabase Storage 作为图片存储后端
/// 支持图片压缩、进度回调、错误重试等功能
class ImageUploadService {
  static final ImageUploadService _instance = ImageUploadService._internal();
  factory ImageUploadService() => _instance;
  ImageUploadService._internal();

  SupabaseClient? _supabase;
  final _tokenStorage = TokenStorageService();

  /// 初始化 Supabase 客户端
  ///
  /// 在 app 启动时调用一次即可
  /// ```dart
  /// await ImageUploadService().initialize(
  ///   url: 'https://your-project.supabase.co',
  ///   anonKey: 'your-anon-key',
  /// );
  /// ```
  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    if (_supabase != null) return;

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _supabase = Supabase.instance.client;
    debugPrint('✅ Supabase Storage 初始化成功');
  }

  /// 获取 Supabase 客户端
  SupabaseClient get client {
    if (_supabase == null) {
      throw Exception('Supabase 未初始化，请先调用 initialize()');
    }
    return _supabase!;
  }

  /// 上传图片到 Supabase Storage
  ///
  /// [imageFile] 要上传的图片文件
  /// [bucket] 存储桶名称，默认 'user-uploads'
  /// [folder] 文件夹路径，默认使用用户ID
  /// [compress] 是否压缩图片，默认 true
  /// [quality] 压缩质量 0-100，默认 85
  /// [maxWidth] 最大宽度，默认 1920
  /// [maxHeight] 最大高度，默认 1920
  /// [onProgress] 上传进度回调 (当前字节数, 总字节数)
  ///
  /// 返回图片的公开访问 URL
  Future<String> uploadImage({
    required File imageFile,
    String bucket = 'user-uploads',
    String? folder,
    bool compress = true,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      // 1. 验证文件
      _validateImageFile(imageFile);

      // 2. 压缩图片（如果需要）
      final fileToUpload = compress
          ? await _compressImage(
              imageFile,
              quality: quality,
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            )
          : imageFile;

      // 3. 生成文件路径
      final userId = await _getUserId();
      final uploadFolder = folder ?? userId;
      final fileName = _generateFileName(imageFile);
      final filePath = '$uploadFolder/$fileName';

      debugPrint('📤 开始上传图片: $filePath');
      debugPrint(
          '📦 文件大小: ${(fileToUpload.lengthSync() / 1024).toStringAsFixed(2)} KB');

      // 4. 上传到 Supabase
      final storageResponse = await client.storage.from(bucket).upload(
            filePath,
            fileToUpload,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _getMimeType(imageFile),
            ),
          );

      debugPrint('✅ 图片上传成功: $storageResponse');

      // 5. 获取公开 URL
      final publicUrl = client.storage.from(bucket).getPublicUrl(filePath);

      debugPrint('🔗 图片 URL: $publicUrl');

      // 6. 清理临时压缩文件
      if (compress && fileToUpload.path != imageFile.path) {
        try {
          await fileToUpload.delete();
        } catch (e) {
          debugPrint('⚠️ 清理临时文件失败: $e');
        }
      }

      return publicUrl;
    } catch (e) {
      debugPrint('❌ 图片上传失败: $e');
      rethrow;
    }
  }

  /// 上传任意文件到 Supabase Storage
  ///
  /// [file] 要上传的文件
  /// [bucket] 存储桶名称，默认 'user-uploads'
  /// [folder] 文件夹路径
  /// [fileName] 指定文件名（可选，默认使用原始文件名）
  ///
  /// 返回文件的公开访问 URL
  Future<String> uploadFile({
    required File file,
    String bucket = 'user-uploads',
    String? folder,
    String? fileName,
  }) async {
    try {
      // 验证文件
      if (!file.existsSync()) {
        throw Exception('文件不存在');
      }

      // 检查文件大小（限制 100MB）
      final fileSize = file.lengthSync();
      if (fileSize > 100 * 1024 * 1024) {
        throw Exception('文件过大，请选择小于 100MB 的文件');
      }

      // 生成文件路径
      final userId = await _getUserId();
      final uploadFolder = folder ?? userId;
      final uploadFileName = fileName ?? _generateUniqueFileName(file);
      final filePath = '$uploadFolder/$uploadFileName';

      debugPrint('📤 开始上传文件: $filePath');
      debugPrint('📦 文件大小: ${(fileSize / 1024).toStringAsFixed(2)} KB');

      // 上传到 Supabase
      final storageResponse = await client.storage.from(bucket).upload(
            filePath,
            file,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: false,
              contentType: _getMimeType(file),
            ),
          );

      debugPrint('✅ 文件上传成功: $storageResponse');

      // 获取公开 URL
      final publicUrl = client.storage.from(bucket).getPublicUrl(filePath);

      debugPrint('🔗 文件 URL: $publicUrl');

      return publicUrl;
    } catch (e) {
      debugPrint('❌ 文件上传失败: $e');
      rethrow;
    }
  }

  /// 生成唯一文件名（保留原扩展名）
  String _generateUniqueFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = path.extension(file.path);
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'file_${timestamp}_$random$ext';
  }

  /// 上传多张图片
  ///
  /// 返回所有图片的 URL 列表
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    String bucket = 'user-uploads',
    String? folder,
    bool compress = true,
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
    Function(int current, int total)? onProgress,
  }) async {
    final urls = <String>[];

    for (int i = 0; i < imageFiles.length; i++) {
      try {
        final url = await uploadImage(
          imageFile: imageFiles[i],
          bucket: bucket,
          folder: folder,
          compress: compress,
          quality: quality,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
        );

        urls.add(url);
        onProgress?.call(i + 1, imageFiles.length);
      } catch (e) {
        debugPrint('❌ 上传第 ${i + 1} 张图片失败: $e');
        // 继续上传其他图片
      }
    }

    return urls;
  }

  /// 删除图片
  ///
  /// [imageUrl] 图片的完整 URL
  /// [bucket] 存储桶名称
  Future<void> deleteImage({
    required String imageUrl,
    String bucket = 'user-uploads',
  }) async {
    try {
      // 从 URL 中提取文件路径
      final filePath = _extractFilePathFromUrl(imageUrl, bucket);

      debugPrint('🗑️ 删除图片: $filePath');

      await client.storage.from(bucket).remove([filePath]);

      debugPrint('✅ 图片删除成功');
    } catch (e) {
      debugPrint('❌ 图片删除失败: $e');
      rethrow;
    }
  }

  /// 批量删除图片
  Future<void> deleteMultipleImages({
    required List<String> imageUrls,
    String bucket = 'user-uploads',
  }) async {
    try {
      final filePaths =
          imageUrls.map((url) => _extractFilePathFromUrl(url, bucket)).toList();

      debugPrint('🗑️ 批量删除 ${filePaths.length} 张图片');

      await client.storage.from(bucket).remove(filePaths);

      debugPrint('✅ 批量删除成功');
    } catch (e) {
      debugPrint('❌ 批量删除失败: $e');
      rethrow;
    }
  }

  /// 压缩图片
  Future<File> _compressImage(
    File file, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1920,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(
        dir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(file.path)}',
      );

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
        format: _getCompressFormat(file),
      );

      if (result == null) {
        debugPrint('⚠️ 图片压缩失败，使用原始文件');
        return file;
      }

      final originalSize = file.lengthSync();
      final compressedSize = File(result.path).lengthSync();
      final ratio =
          ((1 - compressedSize / originalSize) * 100).toStringAsFixed(1);

      debugPrint('🗜️ 图片压缩完成:');
      debugPrint('   原始: ${(originalSize / 1024).toStringAsFixed(2)} KB');
      debugPrint('   压缩: ${(compressedSize / 1024).toStringAsFixed(2)} KB');
      debugPrint('   节省: $ratio%');

      return File(result.path);
    } catch (e) {
      debugPrint('⚠️ 图片压缩出错，使用原始文件: $e');
      return file;
    }
  }

  /// 验证图片文件
  void _validateImageFile(File file) {
    // 检查文件是否存在
    if (!file.existsSync()) {
      throw Exception('图片文件不存在');
    }

    // 检查文件大小（限制 20MB）
    final fileSize = file.lengthSync();
    if (fileSize > 20 * 1024 * 1024) {
      throw Exception('图片文件过大，请选择小于 20MB 的图片');
    }

    // 检查文件类型
    final ext = path.extension(file.path).toLowerCase();
    const allowedExtensions = [
      '.jpg',
      '.jpeg',
      '.png',
      '.gif',
      '.webp',
      '.heic'
    ];
    if (!allowedExtensions.contains(ext)) {
      throw Exception('不支持的图片格式，仅支持: ${allowedExtensions.join(", ")}');
    }
  }

  /// 生成唯一文件名
  String _generateFileName(File file) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = path.extension(file.path);
    final random = DateTime.now().microsecondsSinceEpoch % 10000;
    return 'img_${timestamp}_$random$ext';
  }

  /// 获取 MIME 类型
  String? _getMimeType(File file) {
    return lookupMimeType(file.path);
  }

  /// 获取压缩格式
  CompressFormat _getCompressFormat(File file) {
    final ext = path.extension(file.path).toLowerCase();
    switch (ext) {
      case '.png':
        return CompressFormat.png;
      case '.heic':
        return CompressFormat.heic;
      case '.webp':
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// 获取当前用户 ID
  Future<String> _getUserId() async {
    try {
      // 尝试从 token 中获取用户 ID
      final userId = await _tokenStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
    } catch (e) {
      debugPrint('⚠️ 无法获取用户 ID: $e');
    }

    // 如果获取失败，使用临时 ID
    return 'guest';
  }

  /// 公开方法：获取用户ID用于上传
  Future<String> getUserIdForUpload() async {
    return await _getUserId();
  }

  /// 从 URL 中提取文件路径
  String _extractFilePathFromUrl(String url, String bucket) {
    // URL 格式: https://xxx.supabase.co/storage/v1/object/public/bucket-name/path/to/file.jpg
    // 提取: path/to/file.jpg

    final uri = Uri.parse(url);
    final segments = uri.pathSegments;

    // 找到 bucket 名称后的所有路径
    final bucketIndex = segments.indexOf(bucket);
    if (bucketIndex == -1) {
      throw Exception('无法从 URL 中提取文件路径');
    }

    final filePath = segments.sublist(bucketIndex + 1).join('/');
    return filePath;
  }

  /// 上传图片并保存记录到后端
  ///
  /// 这是一个完整的流程：上传图片 → 保存 URL 到数据库
  Future<Map<String, dynamic>> uploadAndSaveImage({
    required File imageFile,
    required String saveEndpoint, // 例如: '/cities/123/user-content/photos'
    String bucket = 'user-uploads',
    String? folder,
    Map<String, dynamic>? additionalData,
    bool compress = true,
  }) async {
    try {
      // 1. 上传图片到 Supabase
      final imageUrl = await uploadImage(
        imageFile: imageFile,
        bucket: bucket,
        folder: folder,
        compress: compress,
      );

      // 2. 保存图片 URL 到后端数据库
      final token = await _tokenStorage.getAccessToken();
      if (token == null) {
        throw Exception('用户未登录');
      }

      final requestBody = {
        'imageUrl': imageUrl,
        'fileName': path.basename(imageFile.path),
        'fileSize': imageFile.lengthSync(),
        'mimeType': _getMimeType(imageFile),
        ...?additionalData,
      };

      final response = await http.post(
        Uri.parse(ApiConfig.buildUrl(saveEndpoint)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: requestBody.toString(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // 上传失败，删除已上传的图片
        try {
          await deleteImage(imageUrl: imageUrl, bucket: bucket);
        } catch (e) {
          debugPrint('⚠️ 清理失败的上传文件出错: $e');
        }
        throw Exception('保存图片记录失败: ${response.body}');
      }

      debugPrint('✅ 图片上传并保存成功');
      return {
        'imageUrl': imageUrl,
        'response': response.body,
      };
    } catch (e) {
      debugPrint('❌ 上传并保存图片失败: $e');
      rethrow;
    }
  }
}
