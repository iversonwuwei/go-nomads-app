class CityNomadSummary {
  final String cityId;
  final String cityName;
  final String country;
  final String? timezone;
  final CityBudgetRange? monthlyBudgetRange;
  final CityDecisionSignals decisionSignals;
  final List<CityCoworkingPreview> recommendedCoworkings;
  final List<CityStayPreview> recommendedStays;
  final List<CityMeetupPreview> upcomingMeetups;
  final DateTime? lastUpdatedAt;

  const CityNomadSummary({
    required this.cityId,
    required this.cityName,
    required this.country,
    required this.timezone,
    required this.monthlyBudgetRange,
    required this.decisionSignals,
    required this.recommendedCoworkings,
    required this.recommendedStays,
    required this.upcomingMeetups,
    required this.lastUpdatedAt,
  });

  factory CityNomadSummary.fromJson(Map<String, dynamic> json) {
    return CityNomadSummary(
      cityId: json['cityId']?.toString() ?? '',
      cityName: json['cityName'] as String? ?? '',
      country: json['country'] as String? ?? '',
      timezone: json['timezone'] as String?,
      monthlyBudgetRange: json['monthlyBudgetRange'] is Map<String, dynamic>
          ? CityBudgetRange.fromJson(
              json['monthlyBudgetRange'] as Map<String, dynamic>,
            )
          : null,
      decisionSignals: json['decisionSignals'] is Map<String, dynamic>
          ? CityDecisionSignals.fromJson(
              json['decisionSignals'] as Map<String, dynamic>,
            )
          : const CityDecisionSignals(),
      recommendedCoworkings: (json['recommendedCoworkings'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CityCoworkingPreview.fromJson)
          .toList(),
      recommendedStays: (json['recommendedStays'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CityStayPreview.fromJson)
          .toList(),
      upcomingMeetups: (json['upcomingMeetups'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CityMeetupPreview.fromJson)
          .toList(),
      lastUpdatedAt: json['lastUpdatedAt'] != null
          ? DateTime.tryParse(json['lastUpdatedAt'].toString())
          : null,
    );
  }
}

class CityBudgetRange {
  final String currency;
  final double min;
  final double max;

  const CityBudgetRange({
    required this.currency,
    required this.min,
    required this.max,
  });

  factory CityBudgetRange.fromJson(Map<String, dynamic> json) {
    return CityBudgetRange(
      currency: json['currency'] as String? ?? 'USD',
      min: (json['min'] as num?)?.toDouble() ?? 0,
      max: (json['max'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CityDecisionSignals {
  final int? networkQualityScore;
  final int? videoCallFriendlinessScore;
  final int? visaFriendlinessScore;
  final int? timezoneOverlapScore;
  final int? communityActivityScore;
  final int? climateStabilityScore;
  final int? safetyScore;

  const CityDecisionSignals({
    this.networkQualityScore,
    this.videoCallFriendlinessScore,
    this.visaFriendlinessScore,
    this.timezoneOverlapScore,
    this.communityActivityScore,
    this.climateStabilityScore,
    this.safetyScore,
  });

  factory CityDecisionSignals.fromJson(Map<String, dynamic> json) {
    return CityDecisionSignals(
      networkQualityScore: (json['networkQualityScore'] as num?)?.toInt(),
      videoCallFriendlinessScore: (json['videoCallFriendlinessScore'] as num?)?.toInt(),
      visaFriendlinessScore: (json['visaFriendlinessScore'] as num?)?.toInt(),
      timezoneOverlapScore: (json['timezoneOverlapScore'] as num?)?.toInt(),
      communityActivityScore: (json['communityActivityScore'] as num?)?.toInt(),
      climateStabilityScore: (json['climateStabilityScore'] as num?)?.toInt(),
      safetyScore: (json['safetyScore'] as num?)?.toInt(),
    );
  }
}

class CityCoworkingPreview {
  final String id;
  final String name;
  final double rating;
  final double? dayPassPrice;
  final String currency;

  const CityCoworkingPreview({
    required this.id,
    required this.name,
    required this.rating,
    required this.dayPassPrice,
    required this.currency,
  });

  factory CityCoworkingPreview.fromJson(Map<String, dynamic> json) {
    return CityCoworkingPreview(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      dayPassPrice: (json['dayPassPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class CityStayPreview {
  final String id;
  final String name;
  final double rating;
  final double? pricePerNight;
  final String currency;

  const CityStayPreview({
    required this.id,
    required this.name,
    required this.rating,
    required this.pricePerNight,
    required this.currency,
  });

  factory CityStayPreview.fromJson(Map<String, dynamic> json) {
    return CityStayPreview(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );
  }
}

class CityMeetupPreview {
  final String id;
  final String title;
  final DateTime? startTime;
  final String? venue;
  final int participantCount;

  const CityMeetupPreview({
    required this.id,
    required this.title,
    required this.startTime,
    required this.venue,
    required this.participantCount,
  });

  factory CityMeetupPreview.fromJson(Map<String, dynamic> json) {
    return CityMeetupPreview(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      venue: json['venue'] as String?,
      participantCount: (json['participantCount'] as num?)?.toInt() ?? 0,
    );
  }
}
