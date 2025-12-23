import 'package:df_admin_mobile/features/user/domain/entities/user_preferences.dart';

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
}
