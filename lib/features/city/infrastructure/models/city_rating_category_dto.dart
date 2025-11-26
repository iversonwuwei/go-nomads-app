import 'package:df_admin_mobile/features/city/domain/entities/city_rating_category.dart';

/// 城市评分项 DTO
class CityRatingCategoryDto {
  final String id;
  final String name;
  final String? nameEn;
  final String? description;
  final String? icon;
  final bool isDefault;
  final int displayOrder;
  final String? createdBy;
  final DateTime createdAt;

  const CityRatingCategoryDto({
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

  factory CityRatingCategoryDto.fromJson(Map<String, dynamic> json) {
    return CityRatingCategoryDto(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      isDefault: json['isDefault'] as bool? ?? false,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdBy: json['createdBy'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (nameEn != null) 'nameEn': nameEn,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      'isDefault': isDefault,
      'displayOrder': displayOrder,
      if (createdBy != null) 'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  CityRatingCategory toEntity() {
    return CityRatingCategory(
      id: id,
      name: name,
      nameEn: nameEn,
      description: description,
      icon: icon,
      isDefault: isDefault,
      displayOrder: displayOrder,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
