import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// 安全的网络图片组件,处理空字符串和无效 URL
class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 检查 URL 是否有效
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return errorWidget ?? _buildDefaultPlaceholder();
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultPlaceholder();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: Icon(
        FontAwesomeIcons.image,
        size: (width != null && height != null) ? (width! < height! ? width! * 0.5 : height! * 0.5) : 48,
        color: Colors.grey[400],
      ),
    );
  }
}

/// 安全的圆形网络图片组件,用于头像
class SafeCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;

  const SafeCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // 检查 URL 是否有效
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return _buildPlaceholder();
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl!,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: radius * 0.6,
              height: radius * 0.6,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorWidget();
        },
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[200],
      ),
      child: placeholder ??
          Icon(
            FontAwesomeIcons.user,
            size: radius * 0.8,
            color: Colors.grey[500],
          ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? Colors.grey[200],
      ),
      child: errorWidget ??
          Icon(
            FontAwesomeIcons.user,
            size: radius * 0.8,
            color: Colors.grey[500],
          ),
    );
  }
}

/// 安全的网络图片 Provider,用于需要 ImageProvider 的场景
ImageProvider? safeNetworkImageProvider(String? imageUrl) {
  if (imageUrl == null || imageUrl.trim().isEmpty) {
    return null;
  }
  return NetworkImage(imageUrl);
}
