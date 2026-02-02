import 'dart:async';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:go_nomads_app/config/tencent_im_config.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/usersig_generator.dart';

import 'tencent_im_login_mixin.dart';
import 'tencent_im_message_send_mixin.dart';
import 'tencent_im_message_listener_mixin.dart';
import 'tencent_im_conversation_mixin.dart';

/// 腾讯云IM服务 - 完整实现
/// 整合所有功能模块
class TencentIMService extends GetxService
    with TencentIMLoginMixin, TencentIMMessageSendMixin, TencentIMMessageListenerMixin, TencentIMConversationMixin {
  // 状态
  final _isInitialized = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUserId = Rx<String?>(null);

  // 已导入的用户缓存
  final Set<String> _importedUsers = {};

  @override
  bool get isInitialized => _isInitialized.value;
  @override
  bool get isLoggedIn => _isLoggedIn.value;
  String? get currentUserId => _currentUserId.value;

  // Mixin需要的setter
  @override
  set isLoggedInValue(bool v) => _isLoggedIn.value = v;
  @override
  set currentUserIdValue(String? v) => _currentUserId.value = v;

  /// 格式化用户ID（腾讯云IM要求用户ID不能以数字开头）
  /// 统一添加 "user_" 前缀
  static String formatUserId(String userId) {
    // 如果已经有前缀，直接返回
    if (userId.startsWith('user_')) return userId;
    return 'user_$userId';
  }

  /// 确保用户存在于IM系统中（通过临时登录方式"注册"用户）
  /// 这是一个workaround，生产环境应使用服务端API导入用户
  Future<bool> ensureUserExists(String userId) async {
    final formattedId = formatUserId(userId);

    // 如果已经确认存在，直接返回
    if (_importedUsers.contains(formattedId)) {
      return true;
    }

    // 检查用户信息
    try {
      final result = await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
        userIDList: [formattedId],
      );

      if (result.code == 0 && result.data != null && result.data!.isNotEmpty) {
        final userInfo = result.data!.first;
        // 如果能获取到用户信息，说明用户存在
        if (userInfo.userID != null) {
          _importedUsers.add(formattedId);
          log('✅ 用户 $formattedId 已存在于IM系统');
          return true;
        }
      }

      log('⚠️ 用户 $formattedId 不存在于IM系统，对方需要先登录一次');
      return false;
    } catch (e) {
      log('❌ 检查用户存在性失败: $e');
      return false;
    }
  }

  /// 生成指定用户的UserSig（用于用户导入等场景）
  String generateUserSig(String userId) {
    final formattedId = formatUserId(userId);
    return UserSigGenerator.generate(
      sdkAppId: TencentIMConfig.sdkAppId,
      secretKey: TencentIMConfig.secretKey,
      userId: formattedId,
      expireTime: TencentIMConfig.userSigExpireTime,
    );
  }

  /// 初始化SDK
  Future<bool> initSDK() async {
    if (_isInitialized.value) return true;

    try {
      log('🔧 正在初始化腾讯云IM SDK...');

      final result = await TencentImSDKPlugin.v2TIMManager.initSDK(
        sdkAppID: TencentIMConfig.sdkAppId,
        loglevel: LogLevelEnum.values[TencentIMConfig.logLevel],
        listener: V2TimSDKListener(
          onConnecting: () => log('🔄 IM正在连接...'),
          onConnectSuccess: () => log('✅ IM连接成功'),
          onConnectFailed: (code, error) => log('❌ IM连接失败: $code'),
          onKickedOffline: () => _isLoggedIn.value = false,
          onUserSigExpired: () => _isLoggedIn.value = false,
        ),
      );

      if (result.code == 0) {
        _isInitialized.value = true;
        addMessageListener();
        log('✅ 腾讯云IM SDK初始化成功');
        return true;
      }
      return false;
    } catch (e) {
      log('❌ SDK初始化异常: $e');
      return false;
    }
  }

  @override
  void onClose() {
    removeMessageListener();
    disposeMessageListenerStreams();
    TencentImSDKPlugin.v2TIMManager.unInitSDK();
    super.onClose();
  }
}
