import 'package:flutter/material.dart';

import 'base_skeleton.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 聊天室列表骨架屏组件
class ChatListSkeleton extends BaseSkeleton {
  const ChatListSkeleton({super.key});

  @override
  State<ChatListSkeleton> createState() => _ChatListSkeletonState();
}

class _ChatListSkeletonState extends BaseSkeletonState<ChatListSkeleton> {
  @override
  Widget buildSkeleton(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildChatRoomCard();
      },
    );
  }

  Widget _buildChatRoomCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: SkeletonCard(
        height: 140.h,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 聊天室头部
            Row(
              children: [
                SkeletonCircle(
                  size: 48.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 150.w,
                        height: 16.h,
                        borderRadius: 4,
                      ),
                      SizedBox(height: 6.h),
                      SkeletonBox(
                        width: 100.w,
                        height: 12.h,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                SkeletonBox(
                  width: 60.w,
                  height: 24.h,
                  borderRadius: 12,
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 最后消息
            SkeletonBox(
              width: double.infinity,
              height: 14.h,
              borderRadius: 4,
            ),
            SizedBox(height: 6.h),
            SkeletonBox(
              width: 200.w,
              height: 14.h,
              borderRadius: 4,
            ),
            const Spacer(),

            // 底部信息
            Row(
              children: [
                SkeletonBox(
                  width: 80.w,
                  height: 12.h,
                  borderRadius: 4,
                ),
                const Spacer(),
                SkeletonBox(
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
  }
}
