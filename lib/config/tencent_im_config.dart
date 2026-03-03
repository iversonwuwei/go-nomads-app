/// 腾讯云IM配置
///
/// 注意: SecretKey 不应该在客户端硬编码，仅用于开发测试
/// 生产环境应该通过后端服务生成UserSig
class TencentIMConfig {
  /// 腾讯云IM应用ID
  static const int sdkAppId = 1600125279;

  /// 密钥 - 仅用于开发测试，生产环境请通过后端生成UserSig
  /// ⚠️ 警告: 此密钥不应暴露在客户端代码中
  static const String secretKey = 'f7dccba979a02c1fd15bfa234be823f7a29968850d11e68a5a2f3f0ff467b3e7';

  /// UserSig 有效期（秒）- 默认7天
  static const int userSigExpireTime = 604800;

  /// 是否使用客户端生成UserSig（仅开发测试用）
  /// 生产环境应设为false，通过后端API获取UserSig
  static const bool useClientSideUserSig = true;

  /// 后端获取UserSig的API地址（生产环境使用）
  static const String userSigApiUrl = '/api/im/usersig';

  /// 日志级别
  /// 0: 不打印日志
  /// 1: 只打印错误日志
  /// 2: 打印错误和警告日志
  /// 3: 打印错误、警告和信息日志
  /// 4: 打印所有日志（包括调试日志）
  static const int logLevel = 3;
}
