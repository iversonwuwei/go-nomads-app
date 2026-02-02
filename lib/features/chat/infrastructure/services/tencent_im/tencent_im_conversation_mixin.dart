import 'dart:developer';

import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_service.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_conversation.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

/// 腾讯云IM服务 - 会话管理模块扩展
mixin TencentIMConversationMixin {
  bool get isLoggedIn;

  /// 获取会话列表
  Future<List<V2TimConversation>> getConversationList({
    int count = 20,
    String? nextSeq,
  }) async {
    if (!isLoggedIn) return [];

    try {
      final result = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .getConversationList(count: count, nextSeq: nextSeq ?? '0');

      if (result.code == 0) {
        return result.data?.conversationList ?? [];
      }
      return [];
    } catch (e) {
      log('❌ 获取会话列表异常: $e');
      return [];
    }
  }

  /// 获取C2C历史消息
  Future<List<V2TimMessage>> getC2CHistoryMessages({
    required String userId,
    int count = 20,
    V2TimMessage? lastMsg,
  }) async {
    if (!isLoggedIn) return [];

    // 格式化用户ID
    final formattedUserId = TencentIMService.formatUserId(userId);

    try {
      final result = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .getC2CHistoryMessageList(
            userID: formattedUserId,
            count: count,
            lastMsgID: lastMsg?.msgID,
          );

      if (result.code == 0) {
        log('✅ 获取到${result.data?.length ?? 0}条历史消息');
        return result.data ?? [];
      }
      return [];
    } catch (e) {
      log('❌ 获取历史消息异常: $e');
      return [];
    }
  }

  /// 删除会话
  Future<bool> deleteConversation(String conversationId) async {
    if (!isLoggedIn) return false;

    try {
      final result = await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .deleteConversation(conversationID: conversationId);

      return result.code == 0;
    } catch (e) {
      log('❌ 删除会话异常: $e');
      return false;
    }
  }

  /// 标记消息已读
  Future<bool> markC2CMessageAsRead(String userId) async {
    if (!isLoggedIn) return false;

    // 格式化用户ID
    final formattedUserId = TencentIMService.formatUserId(userId);

    try {
      final result = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .markC2CMessageAsRead(userID: formattedUserId);

      return result.code == 0;
    } catch (e) {
      log('❌ 标记已读异常: $e');
      return false;
    }
  }
}
