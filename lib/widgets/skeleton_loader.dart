import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 通用骨架屏加载组件
/// 提供多种预设骨架屏样式和自定义骨架屏构建器
class SkeletonLoader extends StatefulWidget {
  final SkeletonType type;
  final Widget? customSkeleton;

  const SkeletonLoader({
    super.key,
    this.type = SkeletonType.list,
    this.customSkeleton,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.customSkeleton != null) {
      return widget.customSkeleton!;
    }

    switch (widget.type) {
      case SkeletonType.list:
        return _buildListSkeleton();
      case SkeletonType.grid:
        return _buildGridSkeleton();
      case SkeletonType.detail:
        return _buildDetailSkeleton();
      case SkeletonType.profile:
        return _buildProfileSkeleton();
      case SkeletonType.card:
        return _buildCardSkeleton();
      case SkeletonType.home:
        return _buildHomeSkeleton();
      case SkeletonType.chat:
        return _buildChatSkeleton();
      case SkeletonType.community:
        return _buildCommunitySkeleton();
      case SkeletonType.messages:
        return _buildMessagesSkeleton();
    }
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SkeletonCard(
            shimmerController: _shimmerController,
            height: 120.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 60.w,
                      height: 60.h,
                      borderRadius: 12,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: double.infinity,
                            height: 16.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 8.h),
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 150.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 8.h),
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 100.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return SkeletonCard(
          shimmerController: _shimmerController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonBox(
                shimmerController: _shimmerController,
                width: double.infinity,
                height: 140.h,
                borderRadius: 12,
              ),
              SizedBox(height: 12.h),
              SkeletonBox(
                shimmerController: _shimmerController,
                width: double.infinity,
                height: 16.h,
                borderRadius: 4,
              ),
              SizedBox(height: 8.h),
              SkeletonBox(
                shimmerController: _shimmerController,
                width: 100.w,
                height: 14.h,
                borderRadius: 4,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header image
          SkeletonBox(
            shimmerController: _shimmerController,
            width: double.infinity,
            height: 200.h,
            borderRadius: 16,
          ),
          SizedBox(height: 16.h),
          // Title
          SkeletonBox(
            shimmerController: _shimmerController,
            width: double.infinity,
            height: 24.h,
            borderRadius: 4,
          ),
          SizedBox(height: 12.h),
          // Subtitle
          SkeletonBox(
            shimmerController: _shimmerController,
            width: 200.w,
            height: 16.h,
            borderRadius: 4,
          ),
          SizedBox(height: 24.h),
          // Content cards
          ...List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: SkeletonCard(
                shimmerController: _shimmerController,
                height: 150.h,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SkeletonBox(
                          shimmerController: _shimmerController,
                          width: 24.w,
                          height: 24.h,
                          borderRadius: 6,
                        ),
                        SizedBox(width: 12.w),
                        SkeletonBox(
                          shimmerController: _shimmerController,
                          width: 120.w,
                          height: 20.h,
                          borderRadius: 4,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: double.infinity,
                      height: 14.h,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 10.h),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: double.infinity,
                      height: 14.h,
                      borderRadius: 4,
                    ),
                    SizedBox(height: 10.h),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 200.w,
                      height: 14.h,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Avatar
          SkeletonBox(
            shimmerController: _shimmerController,
            width: 100.w,
            height: 100.h,
            borderRadius: 50,
          ),
          SizedBox(height: 16.h),
          // Name
          SkeletonBox(
            shimmerController: _shimmerController,
            width: 150.w,
            height: 20.h,
            borderRadius: 4,
          ),
          SizedBox(height: 8.h),
          // Email
          SkeletonBox(
            shimmerController: _shimmerController,
            width: 200.w,
            height: 16.h,
            borderRadius: 4,
          ),
          SizedBox(height: 24.h),
          // Stats cards
          Row(
            children: [
              Expanded(
                child: SkeletonCard(
                  shimmerController: _shimmerController,
                  height: 80.h,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: SkeletonCard(
                  shimmerController: _shimmerController,
                  height: 80.h,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // List items
          ...List.generate(4, (index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: SkeletonCard(
                shimmerController: _shimmerController,
                height: 60.h,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardSkeleton() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: SkeletonCard(
        shimmerController: _shimmerController,
        height: 200.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 24.w,
                  height: 24.h,
                  borderRadius: 6,
                ),
                SizedBox(width: 12.w),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 120.w,
                  height: 20.h,
                  borderRadius: 4,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SkeletonBox(
              shimmerController: _shimmerController,
              width: double.infinity,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 10.h),
            SkeletonBox(
              shimmerController: _shimmerController,
              width: double.infinity,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 10.h),
            SkeletonBox(
              shimmerController: _shimmerController,
              width: 200.w,
              height: 14.h,
              borderRadius: 4,
            ),
            const Spacer(),
            Row(
              children: [
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 80.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
                const Spacer(),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 60.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 首页骨架屏：轮播图 + 快捷功能 + 网格卡片
  Widget _buildHomeSkeleton() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 轮播图骨架
          Container(
            margin: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 180.h,
                  borderRadius: 12,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      child: SkeletonBox(
                        shimmerController: _shimmerController,
                        width: index == 0 ? 24 : 6,
                        height: 6.h,
                        borderRadius: 3,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 分类标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SkeletonBox(
              shimmerController: _shimmerController,
              width: 150.w,
              height: 20.h,
              borderRadius: 4,
            ),
          ),
          SizedBox(height: 16.h),

          // 快捷功能网格
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 16.w,
              crossAxisSpacing: 16.w,
              children: List.generate(8, (index) {
                return Column(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 48.w,
                      height: 48.h,
                      borderRadius: 12,
                    ),
                    SizedBox(height: 8.h),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 60.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                  ],
                );
              }),
            ),
          ),
          SizedBox(height: 20.h),

          // 热门接口标题
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SkeletonBox(
              shimmerController: _shimmerController,
              width: 180.w,
              height: 20.h,
              borderRadius: 4,
            ),
          ),
          SizedBox(height: 16.h),

          // API接口网格
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              childAspectRatio: 1.2,
              children: List.generate(4, (index) {
                return SkeletonCard(
                  shimmerController: _shimmerController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 32.w,
                            height: 32.h,
                            borderRadius: 8,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: SkeletonBox(
                              shimmerController: _shimmerController,
                              width: double.infinity,
                              height: 16.h,
                              borderRadius: 4,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      SkeletonBox(
                        shimmerController: _shimmerController,
                        width: double.infinity,
                        height: 12.h,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 6.h),
                      SkeletonBox(
                        shimmerController: _shimmerController,
                        width: 100.w,
                        height: 12.h,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // 聊天室列表骨架屏
  Widget _buildChatSkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: SkeletonCard(
            shimmerController: _shimmerController,
            height: 140.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 聊天室头像
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 48.w,
                      height: 48.h,
                      borderRadius: 24,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 150.w,
                            height: 16.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 6.h),
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 100.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 60.w,
                      height: 24.h,
                      borderRadius: 12,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // 最后消息
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 200.w,
                  height: 14.h,
                  borderRadius: 4,
                ),
                const Spacer(),
                // 底部信息
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 80.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                    const Spacer(),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 100.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 社区内容骨架屏
  Widget _buildCommunitySkeleton() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          child: SkeletonCard(
            shimmerController: _shimmerController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 用户信息头部
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 40.w,
                      height: 40.h,
                      borderRadius: 20,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 120.w,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                          SizedBox(height: 6.h),
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: 180.w,
                            height: 12.h,
                            borderRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 50.w,
                      height: 28.h,
                      borderRadius: 6,
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                // 内容图片
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 200.h,
                  borderRadius: 12,
                ),
                SizedBox(height: 16.h),
                // 标题
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 18.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 8.h),
                // 内容
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: double.infinity,
                  height: 14.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 250.w,
                  height: 14.h,
                  borderRadius: 4,
                ),
                SizedBox(height: 16.h),
                // 底部统计信息
                Row(
                  children: [
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 60.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                    SizedBox(width: 16.w),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 60.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                    const Spacer(),
                    SkeletonBox(
                      shimmerController: _shimmerController,
                      width: 80.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 聊天消息骨架屏
  Widget _buildMessagesSkeleton() {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(16.w),
      itemCount: 8,
      itemBuilder: (context, index) {
        // 交替显示左右对齐的消息气泡
        final isLeft = index % 3 == 0;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Row(
            mainAxisAlignment:
                isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLeft) ...[
                // 左侧消息（他人）
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 32.w,
                  height: 32.h,
                  borderRadius: 16,
                ),
                SizedBox(width: 8.w),
              ],
              Container(
                constraints: BoxConstraints(
                  maxWidth: 250.w,
                ),
                child: Column(
                  crossAxisAlignment: isLeft
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.end,
                  children: [
                    if (isLeft)
                      Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: SkeletonBox(
                          shimmerController: _shimmerController,
                          width: 80.w,
                          height: 12.h,
                          borderRadius: 4,
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isLeft
                            ? Colors.grey[100]
                            : const Color(0xFFFF4458).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(isLeft ? 4 : 16),
                          topRight: Radius.circular(isLeft ? 16 : 4),
                          bottomLeft: Radius.circular(16.r),
                          bottomRight: Radius.circular(16.r),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(
                            shimmerController: _shimmerController,
                            width: index % 2 == 0 ? 180.0 : 120.0,
                            height: 14.h,
                            borderRadius: 4,
                          ),
                          if (index % 4 == 0) ...[
                            SizedBox(height: 8.h),
                            SkeletonBox(
                              shimmerController: _shimmerController,
                              width: 150.w,
                              height: 14.h,
                              borderRadius: 4,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 4.h),
                      child: SkeletonBox(
                        shimmerController: _shimmerController,
                        width: 60.w,
                        height: 10.h,
                        borderRadius: 4,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLeft) ...[
                SizedBox(width: 8.w),
                SkeletonBox(
                  shimmerController: _shimmerController,
                  width: 32.w,
                  height: 32.h,
                  borderRadius: 16,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// 骨架屏卡片容器
class SkeletonCard extends StatelessWidget {
  final AnimationController shimmerController;
  final double? height;
  final Widget? child;

  const SkeletonCard({
    super.key,
    required this.shimmerController,
    this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (child != null) {
      return Container(
        height: height,
        padding: EdgeInsets.all(16.w),
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

    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        return Container(
          height: height,
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
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 8.r,
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
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.shimmerController,
    required this.width,
    required this.height,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmerController,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
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

/// 骨架屏类型枚举
enum SkeletonType {
  list, // 列表骨架屏
  grid, // 网格骨架屏
  detail, // 详情页骨架屏
  profile, // 个人资料骨架屏
  card, // 卡片骨架屏
  home, // 首页骨架屏（轮播图+快捷功能+网格）
  chat, // 聊天室列表骨架屏
  community, // 社区内容骨架屏
  messages, // 聊天消息骨架屏
}
