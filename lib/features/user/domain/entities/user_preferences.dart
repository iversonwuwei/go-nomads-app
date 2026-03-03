/// 用户偏好设置领域实体
class UserPreferences {
  final String id;
  final String userId;
  final bool notificationsEnabled;
  final bool travelHistoryVisible;
  final bool autoTravelDetectionEnabled;
  final bool profilePublic;
  final String currency;
  final String temperatureUnit;
  final String language;
  final bool privacyPolicyAccepted;
  final DateTime? privacyPolicyAcceptedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserPreferences({
    required this.id,
    required this.userId,
    required this.notificationsEnabled,
    required this.travelHistoryVisible,
    required this.autoTravelDetectionEnabled,
    required this.profilePublic,
    required this.currency,
    required this.temperatureUnit,
    required this.language,
    this.privacyPolicyAccepted = false,
    this.privacyPolicyAcceptedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从 JSON 创建实例
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      travelHistoryVisible: json['travelHistoryVisible'] as bool? ?? true,
      autoTravelDetectionEnabled: json['autoTravelDetectionEnabled'] as bool? ?? false,
      profilePublic: json['profilePublic'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'USD',
      temperatureUnit: json['temperatureUnit'] as String? ?? 'Celsius',
      language: json['language'] as String? ?? 'en',
      privacyPolicyAccepted: json['privacyPolicyAccepted'] as bool? ?? false,
      privacyPolicyAcceptedAt: json['privacyPolicyAcceptedAt'] != null
          ? DateTime.parse(json['privacyPolicyAcceptedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'notificationsEnabled': notificationsEnabled,
      'travelHistoryVisible': travelHistoryVisible,
      'autoTravelDetectionEnabled': autoTravelDetectionEnabled,
      'profilePublic': profilePublic,
      'currency': currency,
      'temperatureUnit': temperatureUnit,
      'language': language,
      'privacyPolicyAccepted': privacyPolicyAccepted,
      'privacyPolicyAcceptedAt': privacyPolicyAcceptedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 创建默认偏好设置
  factory UserPreferences.defaultPreferences(String userId) {
    return UserPreferences(
      id: '',
      userId: userId,
      notificationsEnabled: true,
      travelHistoryVisible: true,
      autoTravelDetectionEnabled: false,
      profilePublic: true,
      currency: 'USD',
      temperatureUnit: 'Celsius',
      language: 'en',
      privacyPolicyAccepted: false,
      privacyPolicyAcceptedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// 复制并更新
  UserPreferences copyWith({
    String? id,
    String? userId,
    bool? notificationsEnabled,
    bool? travelHistoryVisible,
    bool? autoTravelDetectionEnabled,
    bool? profilePublic,
    String? currency,
    String? temperatureUnit,
    String? language,
    bool? privacyPolicyAccepted,
    DateTime? privacyPolicyAcceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      travelHistoryVisible: travelHistoryVisible ?? this.travelHistoryVisible,
      autoTravelDetectionEnabled: autoTravelDetectionEnabled ?? this.autoTravelDetectionEnabled,
      profilePublic: profilePublic ?? this.profilePublic,
      currency: currency ?? this.currency,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      language: language ?? this.language,
      privacyPolicyAccepted: privacyPolicyAccepted ?? this.privacyPolicyAccepted,
      privacyPolicyAcceptedAt: privacyPolicyAcceptedAt ?? this.privacyPolicyAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
