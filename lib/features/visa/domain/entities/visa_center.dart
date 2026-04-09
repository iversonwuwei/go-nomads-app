class VisaCenter {
  final int activeProfileCount;
  final int attentionRequiredCount;
  final int reminderReadyCount;
  final String recommendedAction;
  final DateTime? lastUpdatedAt;
  final VisaProfile? focusProfile;
  final List<VisaProfile> profiles;

  const VisaCenter({
    required this.activeProfileCount,
    required this.attentionRequiredCount,
    required this.reminderReadyCount,
    required this.recommendedAction,
    required this.lastUpdatedAt,
    required this.focusProfile,
    required this.profiles,
  });

  bool get hasData => focusProfile != null || profiles.isNotEmpty;

  factory VisaCenter.fromJson(Map<String, dynamic> json) {
    final profilesJson = (json['profiles'] as List?)?.whereType<Map<String, dynamic>>().toList() ?? const [];

    return VisaCenter(
      activeProfileCount: json['activeProfileCount'] as int? ?? 0,
      attentionRequiredCount: json['attentionRequiredCount'] as int? ?? 0,
      reminderReadyCount: json['reminderReadyCount'] as int? ?? 0,
      recommendedAction: json['recommendedAction'] as String? ?? '',
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'] as String)
          : null,
      focusProfile: json['focusProfile'] is Map<String, dynamic>
          ? VisaProfile.fromJson(json['focusProfile'] as Map<String, dynamic>)
          : null,
      profiles: profilesJson.map(VisaProfile.fromJson).toList(),
    );
  }
}

class VisaProfile {
  final String id;
  final String cityId;
  final String cityName;
  final String visaType;
  final int stayDurationDays;
  final int? daysRemaining;
  final String status;
  final String requirementsSummary;
  final String processSummary;
  final double estimatedCostUsd;
  final DateTime? entryDate;
  final DateTime? expiryDate;
  final DateTime? reminderSuggestedAt;
  final List<String> requiredDocuments;
  final List<DateTime> reminderDates;

  const VisaProfile({
    required this.id,
    required this.cityId,
    required this.cityName,
    required this.visaType,
    required this.stayDurationDays,
    required this.daysRemaining,
    required this.status,
    required this.requirementsSummary,
    required this.processSummary,
    required this.estimatedCostUsd,
    required this.entryDate,
    required this.expiryDate,
    required this.reminderSuggestedAt,
    this.requiredDocuments = const [],
    this.reminderDates = const [],
  });

  factory VisaProfile.fromJson(Map<String, dynamic> json) {
    final documentsJson = (json['requiredDocuments'] as List?)?.cast<String>() ?? const [];
    final reminderJson = (json['reminderDates'] as List?)?.cast<String>() ?? const [];

    return VisaProfile(
      id: json['id']?.toString() ?? '',
      cityId: json['cityId'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      visaType: json['visaType'] as String? ?? '',
      stayDurationDays: json['stayDurationDays'] as int? ?? 0,
      daysRemaining: json['daysRemaining'] as int?,
      status: json['status'] as String? ?? '',
      requirementsSummary: json['requirementsSummary'] as String? ?? '',
      processSummary: json['processSummary'] as String? ?? '',
      estimatedCostUsd: _toDouble(json['estimatedCostUsd']),
      entryDate: json['entryDate'] != null ? DateTime.tryParse(json['entryDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate'] as String) : null,
      reminderSuggestedAt: json['reminderSuggestedAt'] != null
          ? DateTime.tryParse(json['reminderSuggestedAt'] as String)
          : null,
      requiredDocuments: documentsJson,
      reminderDates: reminderJson.map((item) => DateTime.tryParse(item)).whereType<DateTime>().toList(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value) ?? 0;
    }

    return 0;
  }
}
