import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// App Logo 工具类
/// 提供统一的 Logo 加载和缓存，用于社交分享时的缩略图
class AppLogoUtil {
  static const String _assetPath = 'assets/icon/app_icon.png';

  /// 微信 thumbData 限制 32KB
  static const int _wechatMaxBytes = 32 * 1024;

  /// 缓存的缩略图数据（用于微信分享，Uint8List 格式，保证 ≤ 32KB）
  static Uint8List? _thumbnailCache;

  /// 缓存的 Logo 文件 URI（用于 QQ 分享，file:// URI 格式）
  static Uri? _fileUriCache;

  /// 获取 App Logo 缩略图（Uint8List 格式，适用于微信分享）
  /// 自动压缩确保 ≤ 32KB（微信 SDK 硬限制）
  static Future<Uint8List?> getThumbnail() async {
    if (_thumbnailCache != null) return _thumbnailCache;
    await _loadAndCache();
    return _thumbnailCache;
  }

  /// 获取 App Logo 文件 URI（适用于 QQ SDK 分享）
  static Future<Uri?> getFileUri() async {
    if (_fileUriCache != null) {
      // 检查文件是否还在
      final file = File(_fileUriCache!.toFilePath());
      if (await file.exists()) return _fileUriCache;
    }
    await _loadAndCache();
    return _fileUriCache;
  }

  /// 将图片编码为 PNG，指定宽高
  static Future<Uint8List?> _encodePng(Uint8List source, int size) async {
    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: size,
      targetHeight: size,
    );
    final frame = await codec.getNextFrame();
    final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    frame.image.dispose();
    return data?.buffer.asUint8List();
  }

  /// 加载 asset 图片并缓存
  static Future<void> _loadAndCache() async {
    try {
      // 从 asset 加载原图
      final byteData = await rootBundle.load(_assetPath);
      final originalBytes = byteData.buffer.asUint8List();

      // ---- 生成微信缩略图（必须 ≤ 32KB）----
      // 从 128 开始尝试，如果超限则逐步缩小
      Uint8List? thumb;
      for (int size = 128; size >= 32; size ~/= 2) {
        thumb = await _encodePng(originalBytes, size);
        if (thumb != null && thumb.length <= _wechatMaxBytes) {
          log('✅ AppLogoUtil: 微信缩略图 ${size}x$size = ${thumb.length} bytes');
          break;
        }
        log('⚠️ AppLogoUtil: ${size}x$size = ${thumb?.length} bytes，超过 32KB 限制，继续缩小');
        thumb = null;
      }
      _thumbnailCache = thumb;

      // ---- 生成 QQ 分享图（200x200，无大小限制）----
      final qqThumb = await _encodePng(originalBytes, 200);
      final tempDir = await getTemporaryDirectory();
      final logoFile = File('${tempDir.path}/share_logo.png');
      await logoFile.writeAsBytes(qqThumb ?? originalBytes);
      _fileUriCache = Uri.file(logoFile.path);

      log('✅ AppLogoUtil: Logo 加载完成, wechat=${_thumbnailCache?.length} bytes, qqFile=$_fileUriCache');
    } catch (e) {
      log('⚠️ AppLogoUtil: Logo 加载失败: $e');
    }
  }

  /// 预加载 Logo（可在 App 启动时调用）
  static Future<void> preload() async {
    await _loadAndCache();
  }
}
