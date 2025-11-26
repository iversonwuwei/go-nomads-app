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
        size: (width != null && height != null) 
            ? (width! < height! ? width! * 0.5 : height! * 0.5)
            : 48,
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

  const SafeCircleAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // 检查 URL 是否有效
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey[300],
        child: errorWidget ?? Icon(FontAwesomeIcons.user, size: radius, color: Colors.grey[600]),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: NetworkImage(imageUrl!),
      onBackgroundImageError: (exception, stackTrace) {
        // 图片加载失败时的处理
      },
      child: Container(), // 占位,等待图片加载
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
