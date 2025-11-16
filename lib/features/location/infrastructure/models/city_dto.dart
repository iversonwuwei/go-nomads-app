import '../../../city/domain/entities/city_option.dart';

/// City DTO - 基础设施层数据传输对象
class CityDto {
  final String id;
  final String name;
  final String? region;
  final String? country;
  final String? countryId;

  CityDto({
    required this.id,
    required this.name,
    this.region,
    this.country,
    this.countryId,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? json['nameEn'] as String? ?? '',
      region: json['region'] as String?,
      country: json['country'] as String?,
      countryId: json['countryId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
      'country': country,
      'countryId': countryId,
    };
  }

  /// 转换为领域实体
  CityOption toDomain() {
    return CityOption(
      id: id,
      name: name,
      region: region,
      countryId: countryId,
    );
  }
}
