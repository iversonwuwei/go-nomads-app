/// NomadStats Domain Entity
///
/// 用户游牧生活统计数据的领域对象
class NomadStats {
  final String id;
  final String userId;
  
  /// 访问过的国家数量
  final int countriesVisited;
  
  /// 居住过的城市数量
  final int citiesLived;
  
  /// 游牧天数
  final int daysNomading;
  
  /// 用户创建的 Meetup 数量
  final int meetupsCreated;
  
  /// 完成的旅行数量
  final int tripsCompleted;
  
  /// 收藏的城市数量
  final int favoriteCitiesCount;
  
  final DateTime createdAt;
  final DateTime updatedAt;

  NomadStats({
    required this.id,
    required this.userId,
    this.countriesVisited = 0,
    this.citiesLived = 0,
    this.daysNomading = 0,
    this.meetupsCreated = 0,
    this.tripsCompleted = 0,
    this.favoriteCitiesCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 创建空的统计数据
  factory NomadStats.empty(String userId) {
    final now = DateTime.now();
    return NomadStats(
      id: '',
      userId: userId,
      countriesVisited: 0,
      citiesLived: 0,
      daysNomading: 0,
      meetupsCreated: 0,
      tripsCompleted: 0,
      favoriteCitiesCount: 0,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 从 JSON 创建
  factory NomadStats.fromJson(Map<String, dynamic> json) {
    return NomadStats(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      countriesVisited: json['countriesVisited'] as int? ?? json['countries_visited'] as int? ?? 0,
      citiesLived: json['citiesLived'] as int? ?? json['cities_lived'] as int? ?? 0,
      daysNomading: json['daysNomading'] as int? ?? json['days_nomading'] as int? ?? 0,
      meetupsCreated: json['meetupsCreated'] as int? ?? json['meetups_created'] as int? ?? 0,
      tripsCompleted: json['tripsCompleted'] as int? ?? json['trips_completed'] as int? ?? 0,
      favoriteCitiesCount: json['favoriteCitiesCount'] as int? ?? json['favorite_cities_count'] as int? ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String) 
          : json['created_at'] != null 
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : json['updated_at'] != null 
              ? DateTime.parse(json['updated_at'] as String)
              : DateTime.now(),
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'countriesVisited': countriesVisited,
      'citiesLived': citiesLived,
      'daysNomading': daysNomading,
      'meetupsCreated': meetupsCreated,
      'tripsCompleted': tripsCompleted,
      'favoriteCitiesCount': favoriteCitiesCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 复制并修改
  NomadStats copyWith({
    String? id,
    String? userId,
    int? countriesVisited,
    int? citiesLived,
    int? daysNomading,
    int? meetupsCreated,
    int? tripsCompleted,
    int? favoriteCitiesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NomadStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      countriesVisited: countriesVisited ?? this.countriesVisited,
      citiesLived: citiesLived ?? this.citiesLived,
      daysNomading: daysNomading ?? this.daysNomading,
      meetupsCreated: meetupsCreated ?? this.meetupsCreated,
      tripsCompleted: tripsCompleted ?? this.tripsCompleted,
      favoriteCitiesCount: favoriteCitiesCount ?? this.favoriteCitiesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 是否是新手（所有统计都是0）
  bool get isNewbie => 
      countriesVisited == 0 && 
      citiesLived == 0 && 
      daysNomading == 0;

  /// 游牧等级
  int get nomadLevel {
    final totalScore = countriesVisited * 10 + 
        citiesLived * 5 + 
        (daysNomading ~/ 30) * 3 + 
        tripsCompleted * 2;
    
    if (totalScore >= 500) return 5; // Master Nomad
    if (totalScore >= 200) return 4; // Expert Nomad
    if (totalScore >= 100) return 3; // Seasoned Nomad
    if (totalScore >= 30) return 2;  // Aspiring Nomad
    return 1; // Newbie
  }

  /// 游牧等级名称
  String get nomadLevelName {
    switch (nomadLevel) {
      case 5:
        return 'Master Nomad';
      case 4:
        return 'Expert Nomad';
      case 3:
        return 'Seasoned Nomad';
      case 2:
        return 'Aspiring Nomad';
      default:
        return 'Newbie';
    }
  }
}
