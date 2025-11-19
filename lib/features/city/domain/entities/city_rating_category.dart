/// 城市评分项实体
class CityRatingCategory {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? icon;
  final bool isDefault;
  final int displayOrder;
  final String? createdBy;
  final DateTime createdAt;

  const CityRatingCategory({
    required this.id,
    required this.name,
    this.nameEn,
    this.description,
    this.icon,
    this.isDefault = false,
    this.displayOrder = 0,
    this.createdBy,
    required this.createdAt,
  });
}
