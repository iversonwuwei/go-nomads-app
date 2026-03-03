/// 旅行计划摘要（用于列表显示）
class TravelPlanSummary {
  final String id;
  final String cityId;
  final String cityName;
  final String? cityImage;
  final int duration;
  final String budgetLevel;
  final String travelStyle;
  final String status;
  final DateTime? departureDate;
  final DateTime createdAt;

  const TravelPlanSummary({
    required this.id,
    required this.cityId,
    required this.cityName,
    this.cityImage,
    required this.duration,
    required this.budgetLevel,
    required this.travelStyle,
    required this.status,
    this.departureDate,
    required this.createdAt,
  });

  factory TravelPlanSummary.fromJson(Map<String, dynamic> json) {
    return TravelPlanSummary(
      id: json['id'] ?? '',
      cityId: json['cityId'] ?? '',
      cityName: json['cityName'] ?? '',
      cityImage: json['cityImage'],
      duration: json['duration'] ?? 0,
      budgetLevel: json['budgetLevel'] ?? '',
      travelStyle: json['travelStyle'] ?? '',
      status: json['status'] ?? '',
      departureDate: json['departureDate'] != null ? DateTime.parse(json['departureDate']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cityId': cityId,
      'cityName': cityName,
      'cityImage': cityImage,
      'duration': duration,
      'budgetLevel': budgetLevel,
      'travelStyle': travelStyle,
      'status': status,
      'departureDate': departureDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 格式化出行日期
  String? get formattedDepartureDate {
    if (departureDate == null) return null;
    return '${departureDate!.year}/${departureDate!.month.toString().padLeft(2, '0')}/${departureDate!.day.toString().padLeft(2, '0')}';
  }

  /// 获取预算级别显示文本
  String get budgetLevelDisplay {
    switch (budgetLevel.toLowerCase()) {
      case 'low':
        return '💰 Budget';
      case 'medium':
        return '💰💰 Mid-range';
      case 'high':
        return '💰💰💰 Luxury';
      default:
        return budgetLevel;
    }
  }

  /// 获取旅行风格显示文本
  String get travelStyleDisplay {
    switch (travelStyle.toLowerCase()) {
      case 'adventure':
        return '🏔️ Adventure';
      case 'relaxation':
        return '🏖️ Relaxation';
      case 'culture':
        return '🏛️ Culture';
      case 'nightlife':
        return '🎉 Nightlife';
      default:
        return travelStyle;
    }
  }

  /// 格式化创建时间
  String get formattedCreatedAt {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} minutes ago';
      }
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${createdAt.month}/${createdAt.day}/${createdAt.year}';
    }
  }
}
