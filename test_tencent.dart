import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
void main() async {
  await TencentImSDKPlugin.v2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(
    conversationID: 'c2c_123',
    cleanTimestamp: 0,
    cleanSequence: 0,
  );
}
