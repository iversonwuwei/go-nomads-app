/// 城市区域标签实体 - 用于 Tab 展示，数据由后端控制
class CityRegionTab {
  final String key;
  final String label;
  final int cityCount;
  final int displayOrder;

  const CityRegionTab({
    required this.key,
    required this.label,
    required this.cityCount,
    required this.displayOrder,
  });

  factory CityRegionTab.fromJson(Map<String, dynamic> json) {
    return CityRegionTab(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      cityCount: json['cityCount'] as int? ?? 0,
      displayOrder: json['displayOrder'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'label': label,
      'cityCount': cityCount,
      'displayOrder': displayOrder,
    };
  }

  @override
  String toString() => 'CityRegionTab(key: $key, label: $label, cityCount: $cityCount)';
}
