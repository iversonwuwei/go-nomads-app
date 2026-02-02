import 'dart:async';
import 'dart:developer';

import 'package:tencent_cloud_chat_sdk/enum/V2TimAdvancedMsgListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/message_elem_type.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message.dart';
import 'package:tencent_cloud_chat_sdk/models/v2_tim_message_receipt.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

/// 腾讯云IM服务 - 消息监听模块扩展
mixin TencentIMMessageListenerMixin {
  // 消息事件流
  final _onNewMessageController = StreamController<V2TimMessage>.broadcast();
  final _onMessageRevokedController = StreamController<String>.broadcast();
  final _onReadReceiptController = StreamController<List<V2TimMessageReceipt>>.broadcast();

  Stream<V2TimMessage> get onNewMessage => _onNewMessageController.stream;
  Stream<String> get onMessageRevoked => _onMessageRevokedController.stream;
  Stream<List<V2TimMessageReceipt>> get onReadReceipt => _onReadReceiptController.stream;

  V2TimAdvancedMsgListener? _msgListener;

  /// 添加消息监听器
  void addMessageListener() {
    _msgListener = V2TimAdvancedMsgListener(
      onRecvNewMessage: (V2TimMessage message) {
        log('📩 [MessageListener] 收到新消息:');
        log('   - msgID: ${message.msgID}');
        log('   - sender: ${message.sender}');
        log('   - userID: ${message.userID}');
        log('   - isSelf: ${message.isSelf}');
        log('   - elemType: ${message.elemType}');
        log('   - 内容: ${_getMessagePreview(message)}');
        _onNewMessageController.add(message);
      },
      onRecvMessageRevoked: (String msgId) {
        log('🗑️ 消息被撤回: $msgId');
        _onMessageRevokedController.add(msgId);
      },
      onRecvC2CReadReceipt: (List<V2TimMessageReceipt> receiptList) {
        log('👁️ 收到已读回执: ${receiptList.length}条');
        _onReadReceiptController.add(receiptList);
      },
      onSendMessageProgress: (V2TimMessage message, int progress) {
        log('📤 消息发送进度: $progress%');
      },
    );

    TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(listener: _msgListener!);
    log('✅ 消息监听器已添加');
  }

  /// 移除消息监听器
  void removeMessageListener() {
    if (_msgListener != null) {
      TencentImSDKPlugin.v2TIMManager.getMessageManager().removeAdvancedMsgListener(listener: _msgListener);
      _msgListener = null;
      log('✅ 消息监听器已移除');
    }
  }

  /// 获取消息预览文本
  String _getMessagePreview(V2TimMessage message) {
    switch (message.elemType) {
      case MessageElemType.V2TIM_ELEM_TYPE_TEXT:
        return message.textElem?.text ?? '[文本]';
      case MessageElemType.V2TIM_ELEM_TYPE_IMAGE:
        return '[图片]';
      case MessageElemType.V2TIM_ELEM_TYPE_SOUND:
        return '[语音]';
      case MessageElemType.V2TIM_ELEM_TYPE_VIDEO:
        return '[视频]';
      case MessageElemType.V2TIM_ELEM_TYPE_FILE:
        return '[文件]';
      case MessageElemType.V2TIM_ELEM_TYPE_LOCATION:
        return '[位置]';
      default:
        return '[消息]';
    }
  }

  /// 关闭流控制器
  void disposeMessageListenerStreams() {
    _onNewMessageController.close();
    _onMessageRevokedController.close();
    _onReadReceiptController.close();
  }
}
