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
        height: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 聊天室头部
            Row(
              children: [
                const SkeletonCircle(
                  size: 48,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonBox(
                        width: 150,
                        height: 16,
                        borderRadius: 4,
                      ),
                      const SizedBox(height: 6),
                      const SkeletonBox(
                        width: 100,
                        height: 12,
                        borderRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SkeletonBox(
                  width: 60,
                  height: 24,
                  borderRadius: 12,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 最后消息
            const SkeletonBox(
              width: double.infinity,
              height: 14,
              borderRadius: 4,
            ),
            const SizedBox(height: 6),
            const SkeletonBox(
              width: 200,
              height: 14,
              borderRadius: 4,
            ),
            const Spacer(),

            // 底部信息
            Row(
              children: [
                const SkeletonBox(
                  width: 80,
                  height: 12,
                  borderRadius: 4,
                ),
                const Spacer(),
                const SkeletonBox(
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
