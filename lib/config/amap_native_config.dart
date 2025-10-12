/// 高德地图原生 iOS 集成配置
class AmapNativeConfig {
  AmapNativeConfig._();

  /// iOS API Key
  /// Bundle ID: com.example.dfAdminMobile
  /// 从高德控制台获取: https://console.amap.com/dev/key/app
  static const String iosApiKey = '6b053c71911726f46271e4b54124d35f';

  /// Platform Channel 名称
  static const String channelName = 'com.example.df_admin_mobile/amap';

  /// Method 名称
  static const String methodOpenMapPicker = 'openMapPicker';
  static const String methodGetCurrentLocation = 'getCurrentLocation';
}
