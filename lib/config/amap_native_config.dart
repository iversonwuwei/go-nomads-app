/// 高德地图原生 iOS/Android 集成配置
class AmapNativeConfig {
  AmapNativeConfig._();

  /// iOS API Key
  /// Bundle ID: com.example.dfAdminMobile
  /// 从高德控制台获取: https://console.amap.com/dev/key/app
  static const String iosApiKey = '6b053c71911726f46271e4b54124d35f';

  /// Android API Key
  /// Package Name: com.example.df_admin_mobile
  /// SHA1: 80:14:37:54:EC:ED:51:EB:AF:41:7C:92:AF:71:A1:E8:4A:7D:80:6B
  /// ⚠️ 请到高德控制台创建 Android Key 后填写到这里
  /// https://console.amap.com/dev/key/app
  static const String androidApiKey = '1b1caa568d9884680086a15613448b40';

  /// Platform Channel 名称
  static const String channelName = 'com.example.df_admin_mobile/amap';

  /// Method 名称
  static const String methodOpenMapPicker = 'openMapPicker';
  static const String methodGetCurrentLocation = 'getCurrentLocation';
}
