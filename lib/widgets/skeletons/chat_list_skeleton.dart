import 'package:flutter/material.dart';

import 'base_skeleton.dart';

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
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildChatRoomCard();
      },
    );
  }

  Widget _buildChatRoomCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SkeletonCard(
        shimmerController: shimmerController,
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 聊天室头部
            Row(
              children: [
                SkeletonCircle(
                  shimmerController: shimmerController,
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 150,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      SkeletonBox(
                        shimmerController: shimmerController,
                        width: 100,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 60,
                  height: 24,
                  borderRadius: 12,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 最后消息
            SkeletonBox(
              shimmerController: shimmerController,
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            SkeletonBox(
              shimmerController: shimmerController,
              width: 200,
              height: 14,
              borderRadius: 4,
            ),
            const Spacer(),

            // 底部信息
            Row(
              children: [
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 80,
                  height: 12,
                  borderRadius: 4,
                ),
                const Spacer(),
                SkeletonBox(
                  shimmerController: shimmerController,
                  width: 100,
                  height: 12,
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
