/// 数字游民指南领域实体
class DigitalNomadGuide {
  final String cityId;
  final String cityName;
  final String overview;
  final VisaInfo visaInfo;
  final List<BestArea> bestAreas;
  final List<String> workspaceRecommendations;
  final List<String> tips;
  final Map<String, String> essentialInfo;

  const DigitalNomadGuide({
    required this.cityId,
    required this.cityName,
    required this.overview,
    required this.visaInfo,
    required this.bestAreas,
    required this.workspaceRecommendations,
    required this.tips,
    required this.essentialInfo,
  });

  /// 从 Map 创建实体
  factory DigitalNomadGuide.fromMap(Map<String, dynamic> map) {
    return DigitalNomadGuide(
      cityId: map['cityId'] as String? ?? '',
      cityName: map['cityName'] as String? ?? '',
      overview: map['overview'] as String? ?? '',
      visaInfo: map['visaInfo'] != null
          ? VisaInfo.fromMap(map['visaInfo'] as Map<String, dynamic>)
          : VisaInfo.empty(),
      bestAreas: (map['bestAreas'] as List<dynamic>?)
              ?.map((e) => BestArea.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      workspaceRecommendations: (map['workspaceRecommendations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tips: (map['tips'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      essentialInfo: (map['essentialInfo'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value as String)) ??
          {},
    );
  }

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {
      'cityId': cityId,
      'cityName': cityName,
      'overview': overview,
      'visaInfo': visaInfo.toMap(),
      'bestAreas': bestAreas.map((e) => e.toMap()).toList(),
      'workspaceRecommendations': workspaceRecommendations,
      'tips': tips,
      'essentialInfo': essentialInfo,
    };
  }
}

/// 签证信息
class VisaInfo {
  final String type;
  final int duration;
  final String requirements;
  final double cost;
  final String process;

  const VisaInfo({
    required this.type,
    required this.duration,
    required this.requirements,
    required this.cost,
    required this.process,
  });

  factory VisaInfo.empty() {
    return const VisaInfo(
      type: '',
      duration: 0,
      requirements: '',
      cost: 0,
      process: '',
    );
  }

  factory VisaInfo.fromMap(Map<String, dynamic> map) {
    return VisaInfo(
      type: map['type'] as String? ?? '',
      duration: (map['duration'] as num?)?.toInt() ?? 0,
      requirements: map['requirements'] as String? ?? '',
      cost: (map['cost'] as num?)?.toDouble() ?? 0.0,
      process: map['process'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'duration': duration,
      'requirements': requirements,
      'cost': cost,
      'process': process,
    };
  }
}

/// 最佳区域
class BestArea {
  final String name;
  final String description;
  final int entertainmentScore;
  final String entertainmentDescription;
  final int tourismScore;
  final String tourismDescription;
  final int economyScore;
  final String economyDescription;
  final int cultureScore;
  final String cultureDescription;

  const BestArea({
    required this.name,
    required this.description,
    required this.entertainmentScore,
    required this.entertainmentDescription,
    required this.tourismScore,
    required this.tourismDescription,
    required this.economyScore,
    required this.economyDescription,
    required this.cultureScore,
    required this.cultureDescription,
  });

  factory BestArea.fromMap(Map<String, dynamic> map) {
    return BestArea(
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      entertainmentScore: (map['entertainmentScore'] as num?)?.toInt() ?? 0,
      entertainmentDescription: map['entertainmentDescription'] as String? ?? '',
      tourismScore: (map['tourismScore'] as num?)?.toInt() ?? 0,
      tourismDescription: map['tourismDescription'] as String? ?? '',
      economyScore: (map['economyScore'] as num?)?.toInt() ?? 0,
      economyDescription: map['economyDescription'] as String? ?? '',
      cultureScore: (map['cultureScore'] as num?)?.toInt() ?? 0,
      cultureDescription: map['cultureDescription'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'entertainmentScore': entertainmentScore,
      'entertainmentDescription': entertainmentDescription,
      'tourismScore': tourismScore,
      'tourismDescription': tourismDescription,
      'economyScore': economyScore,
      'economyDescription': economyDescription,
      'cultureScore': cultureScore,
      'cultureDescription': cultureDescription,
    };
  }

  /// 综合评分
  double get overallScore {
    return (entertainmentScore + tourismScore + economyScore + cultureScore) / 4.0;
  }
}
