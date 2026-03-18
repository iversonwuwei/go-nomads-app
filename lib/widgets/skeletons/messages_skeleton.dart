import 'package:flutter/material.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 聊天消息骨架屏组件
class MessagesSkeleton extends BaseSkeleton {
  const MessagesSkeleton({super.key});

  @override
  State<MessagesSkeleton> createState() => _MessagesSkeletonState();
}

class _MessagesSkeletonState extends BaseSkeletonState<MessagesSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: EdgeInsets.all(16.w),
      itemCount: 8,
      itemBuilder: (context, index) {
        // 交替显示左右对齐的消息气泡
        final isLeft = index % 3 == 0;
        return _buildMessageBubble(isLeft, index);
      },
    );
  }

  Widget _buildMessageBubble(bool isLeft, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLeft) ...[
            // 左侧消息（他人）
            SkeletonCircle(
              size: 32.r,
            ),
            SizedBox(width: 8.w),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: 250.w,
            ),
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (isLeft)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: SkeletonBox(
                      width: 80.w,
                      height: 12.h,
                      borderRadius: 4,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isLeft ? Colors.grey[100] : const Color(0xFFFF4458).withValues(alpha: 0.1),
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
                        width: index % 2 == 0 ? 180.0 : 120.0,
                        height: 14.h,
                        borderRadius: 4,
                      ),
                      if (index % 4 == 0) ...[
                        SizedBox(height: 8.h),
                        SkeletonBox(
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
            SkeletonCircle(
              size: 32.r,
            ),
          ],
        ],
      ),
    );
  }
}
