import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:go_nomads_app/config/tencent_im_config.dart';
import 'package:tencent_cloud_chat_sdk/enum/V2TimSDKListener.dart';
import 'package:tencent_cloud_chat_sdk/enum/log_level_enum.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

/// 腾讯云IM服务 - 初始化模块
/// 负责SDK初始化和基础状态管理
class TencentIMService extends GetxService {
  // 状态
  final _isInitialized = false.obs;
  final _isLoggedIn = false.obs;
  final _currentUserId = Rx<String?>(null);

  bool get isInitialized => _isInitialized.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String? get currentUserId => _currentUserId.value;

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
          onConnectFailed: (code, error) => log('❌ IM连接失败: $code - $error'),
          onKickedOffline: () {
            log('⚠️ 账号在其他设备登录');
            _isLoggedIn.value = false;
          },
          onUserSigExpired: () {
            log('⚠️ UserSig已过期');
            _isLoggedIn.value = false;
          },
          onSelfInfoUpdated: (info) => log('📝 个人信息已更新'),
        ),
      );

      if (result.code == 0) {
        _isInitialized.value = true;
        log('✅ 腾讯云IM SDK初始化成功');
        return true;
      } else {
        log('❌ SDK初始化失败: ${result.code} - ${result.desc}');
        return false;
      }
    } catch (e) {
      log('❌ SDK初始化异常: $e');
      return false;
    }
  }

  /// 反初始化SDK
  Future<void> unInitSDK() async {
    if (!_isInitialized.value) return;
    await TencentImSDKPlugin.v2TIMManager.unInitSDK();
    _isInitialized.value = false;
    _isLoggedIn.value = false;
    log('🔌 SDK已反初始化');
  }

  @override
  void onClose() {
    unInitSDK();
    super.onClose();
  }
}
