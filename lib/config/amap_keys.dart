import 'dart:io';

/// 高德地图 API Key 配置
/// 
/// 注意事项：
/// 1. iOS 和 Android 需要使用不同的 Key
/// 2. iOS Key 对应 Bundle ID: com.example.dfAdminMobile
/// 3. Android Key 对应 Package Name: com.example.df_admin_mobile
/// 
/// 获取步骤：
/// 1. 访问高德开放平台：https://console.amap.com/dev/key/app
/// 2. 创建两个应用（iOS 平台 + Android 平台）
/// 3. 将生成的 Key 分别填入下方
class AmapKeys {
  // 私有构造函数，防止实例化
  AmapKeys._();

  /// iOS 平台 Key
  /// Bundle ID: com.example.dfAdminMobile
  /// 
  /// 配置步骤：
  /// 1. 在高德控制台创建 iOS 平台应用
  /// 2. 填写 Bundle ID: com.example.dfAdminMobile
  /// 3. 复制生成的 Key 到这里
  static const String _iosKey = '6b053c71911726f46271e4b54124d35f';

  /// Android 平台 Key
  /// Package Name: com.example.df_admin_mobile
  /// 
  /// 配置步骤：
  /// 1. 在高德控制台创建 Android 平台应用
  /// 2. 填写 Package Name: com.example.df_admin_mobile
  /// 3. 配置 SHA1 签名（调试版 + 发布版）
  /// 4. 复制生成的 Key 到这里
  static const String _androidKey = '1b1caa568d9884680086a15613448b40';

  /// Web 服务 Key（可选）
  /// 用于逆地理编码、POI 搜索等 Web API
  static const String _webServiceKey = '你的Web服务Key';

  /// 根据当前平台返回对应的 Key
  static String get platformKey {
    if (Platform.isIOS) {
      return _iosKey;
    } else if (Platform.isAndroid) {
      return _androidKey;
    } else {
      throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
    }
  }

  /// 获取 Web 服务 Key
  static String get webServiceKey => _webServiceKey;

  /// 获取当前平台名称（用于调试）
  static String get currentPlatform {
    if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isAndroid) {
      return 'Android';
    } else {
      return Platform.operatingSystem;
    }
  }

  /// 验证 Key 是否已配置
  static bool get isConfigured {
    if (Platform.isIOS) {
      return _iosKey.isNotEmpty && !_iosKey.contains('你的');
    } else if (Platform.isAndroid) {
      return _androidKey.isNotEmpty && !_androidKey.contains('你的');
    }
    return false;
  }

  /// 获取配置信息摘要（用于调试）
  static Map<String, dynamic> get debugInfo => {
        'platform': currentPlatform,
        'key': platformKey.substring(0, 8) + '...',
        'configured': isConfigured,
        'ios_key_set': _iosKey.isNotEmpty && !_iosKey.contains('你的'),
        'android_key_set': _androidKey.isNotEmpty && !_androidKey.contains('你的'),
      };
}
