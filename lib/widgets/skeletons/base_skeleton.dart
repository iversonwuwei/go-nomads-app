import 'package:flutter/material.dart';

/// 基础骨架屏组件
/// 所有页面特定的骨架屏都应继承此类
abstract class BaseSkeleton extends StatefulWidget {
  const BaseSkeleton({super.key});

  @override
  State<BaseSkeleton> createState();
}

abstract class BaseSkeletonState<T extends BaseSkeleton> extends State<T>
    with SingleTickerProviderStateMixin {
  late AnimationController shimmerController;

  @override
  void initState() {
    super.initState();
    shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return buildSkeleton(context);
  }

  /// 子类需要实现此方法来构建特定的骨架屏布局
  Widget buildSkeleton(BuildContext context);
}

/// 骨架屏卡片容器
class SkeletonCard extends StatelessWidget {
  final AnimationController shimmerController;
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const SkeletonCard({
    super.key,
    required this.shimmerController,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(
        height: height,
        width: width,
        padding: padding ?? const EdgeInsets.all(16),
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      );
    }

    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        return Container(
          height: height,
          width: width,
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              begin: Alignment(-1.0 + shimmerController.value * 2, 0),
              end: Alignment(1.0 + shimmerController.value * 2, 0),
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 骨架屏基础盒子组件
class SkeletonBox extends StatelessWidget {
  final AnimationController shimmerController;
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    required this.shimmerController,
    this.width,
    this.height,
    this.borderRadius = 4,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              begin: Alignment(-1.0 + shimmerController.value * 2, 0),
              end: Alignment(1.0 + shimmerController.value * 2, 0),
              stops: const [0.0, 0.5, 1.0],
            ),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
    );
  }
}

/// 骨架屏圆形组件（用于头像等）
class SkeletonCircle extends StatelessWidget {
  final AnimationController shimmerController;
  final double size;
  final EdgeInsetsGeometry? margin;

  const SkeletonCircle({
    super.key,
    required this.shimmerController,
    required this.size,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: size,
      height: size,
      borderRadius: size / 2,
      margin: margin,
    );
  }
}

/// 骨架屏分隔线
class SkeletonDivider extends StatelessWidget {
  final AnimationController shimmerController;
  final double? width;
  final double height;
  final EdgeInsetsGeometry? margin;

  const SkeletonDivider({
    super.key,
    required this.shimmerController,
    this.width,
    this.height = 1,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(
      shimmerController: shimmerController,
      width: width ?? double.infinity,
      height: height,
      borderRadius: 0,
      margin: margin,
    );
  }
}
