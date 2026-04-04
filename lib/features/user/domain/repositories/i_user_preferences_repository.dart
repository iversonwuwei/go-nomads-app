import 'package:go_nomads_app/features/user/domain/entities/user_preferences.dart';

/// 用户偏好设置仓储接口
abstract class IUserPreferencesRepository {
  /// 获取当前用户的偏好设置
  Future<UserPreferences> getCurrentUserPreferences();

  /// 更新当前用户的偏好设置
  Future<UserPreferences> updatePreferences({
    bool? notificationsEnabled,
    bool? travelHistoryVisible,
    bool? autoTravelDetectionEnabled,
    bool? profilePublic,
    String? currency,
    String? temperatureUnit,
    String? language,
  });

  /// 接受隐私政策
  Future<UserPreferences> acceptPrivacyPolicy();

  /// 接受用户协议
  Future<UserPreferences> acceptTermsOfService();
}
