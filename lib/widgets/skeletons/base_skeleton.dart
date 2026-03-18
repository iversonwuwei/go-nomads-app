import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_nomads_app/widgets/app_loading_widget.dart';

/// Compatibility wrapper kept for existing call sites.
/// Skeleton/shimmer animation is intentionally disabled.
class SafeShimmer extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const SafeShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) => child;
}

/// 基础骨架屏组件（已迁移到统一加载组件）
/// 所有页面特定的骨架屏都应继承此类
abstract class BaseSkeleton extends StatefulWidget {
  const BaseSkeleton({super.key});

  @override
  State<BaseSkeleton> createState();
}

abstract class BaseSkeletonState<T extends BaseSkeleton> extends State<T> {
  /// Shimmer 基础颜色
  Color get shimmerBaseColor => Colors.grey[300]!;

  /// Shimmer 高亮颜色
  Color get shimmerHighlightColor => Colors.grey[100]!;

  @override
  Widget build(BuildContext context) {
    return const AppSceneLoading(scene: AppLoadingScene.generic, fullScreen: true);
  }

  /// 子类需要实现此方法来构建特定的骨架屏布局
  Widget buildSkeleton(BuildContext context);
}

/// 骨架屏卡片容器（简化版，不再需要 AnimationController）
class SkeletonCard extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: padding ?? EdgeInsets.all(16.w),
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 骨架屏基础盒子组件（简化版）
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 4,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// 骨架屏圆形组件（用于头像等）
class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }
}

/// 骨架屏分隔线
class SkeletonDivider extends StatelessWidget {
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonDivider({
    super.key,
    this.width,
    this.height = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      width: width ?? double.infinity,
      height: height,
      borderRadius: 0,
      margin: margin,
    );
  }
}
