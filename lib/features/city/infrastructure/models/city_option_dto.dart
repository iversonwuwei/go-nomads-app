// Legacy model import removed - model no longer exists
// import 'package:df_admin_mobile/models/city_option.dart' as legacy;
import 'package:df_admin_mobile/features/city/domain/entities/city_option.dart'
    as domain;

/// CityOption DTO
class CityOptionDto {
  final String id;
  final String name;
  final String? region;

  const CityOptionDto({
    required this.id,
    required this.name,
    this.region,
  });

  factory CityOptionDto.fromJson(Map<String, dynamic> json) {
    return CityOptionDto(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      region: json['region']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
    };
  }

  domain.CityOption toDomain() {
    return domain.CityOption(
      id: id,
      name: name,
      region: region,
    );
  }

  factory CityOptionDto.fromLegacyModel(CityOptionDto model) {
    return CityOptionDto(
      id: model.id,
      name: model.name,
      region: model.region,
    );
  }
}
