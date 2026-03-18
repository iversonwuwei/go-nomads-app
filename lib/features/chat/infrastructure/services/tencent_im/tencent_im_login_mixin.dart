import 'dart:developer';

import 'package:go_nomads_app/config/tencent_im_config.dart';
import 'package:go_nomads_app/features/chat/infrastructure/services/tencent_im/tencent_im_service.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

import 'usersig_generator.dart';

/// 腾讯云IM服务 - 登录模块扩展
/// 为TencentIMService提供登录相关方法
mixin TencentIMLoginMixin {
  bool get isInitialized;
  set isLoggedInValue(bool value);
  set currentUserIdValue(String? value);

  /// 登录IM（自动格式化用户ID）
  Future<bool> login(String userId) async {
    if (!isInitialized) {
      log('❌ SDK未初始化，请先调用initSDK');
      return false;
    }

    // 格式化用户ID
    final formattedUserId = TencentIMService.formatUserId(userId);

    try {
      log('🔐 正在登录腾讯云IM: $formattedUserId (原始: $userId)');

      final userSig = _generateUserSig(formattedUserId);

      final result = await TencentImSDKPlugin.v2TIMManager.login(
        userID: formattedUserId,
        userSig: userSig,
      );

      if (result.code == 0) {
        isLoggedInValue = true;
        currentUserIdValue = formattedUserId;
        log('✅ 腾讯云IM登录成功: $formattedUserId');
        return true;
      } else {
        log('❌ IM登录失败: ${result.code} - ${result.desc}');
        return false;
      }
    } catch (e) {
      log('❌ IM登录异常: $e');
      return false;
    }
  }

  /// 登出IM
  Future<void> logout() async {
    try {
      await TencentImSDKPlugin.v2TIMManager.logout();
      isLoggedInValue = false;
      currentUserIdValue = null;
      log('✅ 腾讯云IM已登出');
    } catch (e) {
      log('❌ IM登出异常: $e');
    }
  }

  /// 生成UserSig
  String _generateUserSig(String userId) {
    if (TencentIMConfig.useClientSideUserSig) {
      return UserSigGenerator.generate(
        sdkAppId: TencentIMConfig.sdkAppId,
        secretKey: TencentIMConfig.secretKey,
        userId: userId,
        expireTime: TencentIMConfig.userSigExpireTime,
      );
    }
    // TODO: 生产环境从后端获取UserSig
    throw UnimplementedError('后端UserSig获取尚未实现');
  }
}
