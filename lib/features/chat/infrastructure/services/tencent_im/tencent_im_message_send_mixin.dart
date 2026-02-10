import 'dart:developer';

import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_service.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

/// 消息发送被内容安全策略拦截的异常
class IMContentBlockedException implements Exception {
  final int code;
  final String description;
  IMContentBlockedException(this.code, this.description);

  @override
  String toString() => 'IMContentBlockedException($code): $description';
}

/// 腾讯云IM服务 - 消息发送模块扩展
mixin TencentIMMessageSendMixin {
  bool get isLoggedIn;

  /// 发送C2C文本消息（使用高级消息接口）
  Future<V2TimMessage?> sendC2CTextMessage({
    required String userId,
    required String text,
  }) async {
    if (!isLoggedIn) {
      log('❌ 未登录，无法发送消息');
      return null;
    }

    // 格式化接收者用户ID
    final receiverId = TencentIMService.formatUserId(userId);

    try {
      // 创建文本消息
      final createResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: text);

      if (createResult.code != 0) {
        log('❌ 创建文本消息失败: ${createResult.desc}');
        return null;
      }

      // 发送消息
      final sendResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
            id: createResult.data!.id!,
            receiver: receiverId,
            groupID: '',
          );

      if (sendResult.code == 0) {
        log('✅ 文本消息发送成功 -> $receiverId');
        return sendResult.data;
      } else {
        log('❌ 发送失败: ${sendResult.code} - ${sendResult.desc}');
        // 80001/80004: 消息内容安全打击（含敏感词）
        if (sendResult.code == 80001 || sendResult.code == 80004) {
          throw IMContentBlockedException(sendResult.code, sendResult.desc ?? '消息包含敏感内容，发送失败');
        }
        return null;
      }
    } catch (e) {
      if (e is IMContentBlockedException) rethrow;
      log('❌ 发送异常: $e');
      return null;
    }
  }

  /// 发送C2C图片消息
  Future<V2TimMessage?> sendC2CImageMessage({
    required String userId,
    required String imagePath,
  }) async {
    if (!isLoggedIn) return null;

    // 格式化接收者用户ID
    final receiverId = TencentIMService.formatUserId(userId);

    try {
      // 创建图片消息
      final createResult =
          await TencentImSDKPlugin.v2TIMManager.getMessageManager().createImageMessage(imagePath: imagePath);

      if (createResult.code != 0) {
        log('❌ 创建图片消息失败: ${createResult.desc}');
        return null;
      }

      // 发送消息
      final sendResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
            id: createResult.data!.id!,
            receiver: receiverId,
            groupID: '',
          );

      if (sendResult.code == 0) {
        log('✅ 图片消息发送成功');
        return sendResult.data;
      }
      // 80001/80004: 消息内容安全打击
      if (sendResult.code == 80001 || sendResult.code == 80004) {
        throw IMContentBlockedException(sendResult.code, sendResult.desc ?? '图片包含敏感内容，发送失败');
      }
      return null;
    } catch (e) {
      if (e is IMContentBlockedException) rethrow;
      log('❌ 图片发送异常: $e');
      return null;
    }
  }

  /// 发送C2C语音消息
  Future<V2TimMessage?> sendC2CVoiceMessage({
    required String userId,
    required String soundPath,
    required int duration,
  }) async {
    if (!isLoggedIn) return null;

    // 格式化接收者用户ID
    final receiverId = TencentIMService.formatUserId(userId);

    try {
      final createResult = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .createSoundMessage(soundPath: soundPath, duration: duration);

      if (createResult.code != 0) return null;

      final sendResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
            id: createResult.data!.id!,
            receiver: receiverId,
            groupID: '',
          );

      return sendResult.code == 0 ? sendResult.data : null;
    } catch (e) {
      log('❌ 语音发送异常: $e');
      return null;
    }
  }

  /// 发送C2C文件消息
  Future<V2TimMessage?> sendC2CFileMessage({
    required String userId,
    required String filePath,
    required String fileName,
  }) async {
    if (!isLoggedIn) return null;

    // 格式化接收者用户ID
    final receiverId = TencentIMService.formatUserId(userId);

    try {
      final createResult = await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .createFileMessage(filePath: filePath, fileName: fileName);

      if (createResult.code != 0) {
        log('❌ 创建文件消息失败: ${createResult.desc}');
        return null;
      }

      final sendResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
            id: createResult.data!.id!,
            receiver: receiverId,
            groupID: '',
          );

      if (sendResult.code == 0) {
        log('✅ 文件消息发送成功');
        return sendResult.data;
      }
      return null;
    } catch (e) {
      log('❌ 文件发送异常: $e');
      return null;
    }
  }

  /// 发送C2C表情消息
  Future<V2TimMessage?> sendC2CFaceMessage({
    required String userId,
    required int index,
    required String data,
  }) async {
    if (!isLoggedIn) return null;

    // 格式化接收者用户ID
    final receiverId = TencentIMService.formatUserId(userId);

    try {
      final createResult =
          await TencentImSDKPlugin.v2TIMManager.getMessageManager().createFaceMessage(index: index, data: data);

      if (createResult.code != 0) {
        log('❌ 创建表情消息失败: ${createResult.desc}');
        return null;
      }

      final sendResult = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(
            id: createResult.data!.id!,
            receiver: receiverId,
            groupID: '',
          );

      if (sendResult.code == 0) {
        log('✅ 表情消息发送成功');
        return sendResult.data;
      }
      return null;
    } catch (e) {
      log('❌ 表情发送异常: $e');
      return null;
    }
  }
}
