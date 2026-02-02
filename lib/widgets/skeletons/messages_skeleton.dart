import 'package:flutter/material.dart';

import 'base_skeleton.dart';

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
      padding: const EdgeInsets.all(16),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLeft) ...[
            // 左侧消息（他人）
            const SkeletonCircle(
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: const BoxConstraints(
              maxWidth: 250,
            ),
            child: Column(
              crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (isLeft)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: SkeletonBox(
                      width: 80,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isLeft ? Colors.grey[100] : const Color(0xFFFF4458).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isLeft ? 4 : 16),
                      topRight: Radius.circular(isLeft ? 16 : 4),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: index % 2 == 0 ? 180.0 : 120.0,
                        height: 14,
                        borderRadius: 4,
                      ),
                      if (index % 4 == 0) ...[
                        const SizedBox(height: 8),
                        const SkeletonBox(
                          width: 150,
                          height: 14,
                          borderRadius: 4,
                        ),
                      ],
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: SkeletonBox(
                    width: 60,
                    height: 10,
                    borderRadius: 4,
                  ),
                ),
              ],
            ),
          ),
          if (!isLeft) ...[
            const SizedBox(width: 8),
            const SkeletonCircle(
              size: 32,
            ),
          ],
        ],
      ),
    );
  }
}
