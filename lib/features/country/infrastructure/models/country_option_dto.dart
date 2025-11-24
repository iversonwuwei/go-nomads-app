import 'package:df_admin_mobile/features/country/domain/entities/country_option.dart'
    as domain;

/// CountryOption DTO
class CountryOptionDto {
  final String id;
  final String name;
  final String? nameZh;
  final String? code;
  final String? codeAlpha3;
  final String? continent;
  final String? flagUrl;
  final String? callingCode;
  final bool isActive;

  const CountryOptionDto({
    required this.id,
    required this.name,
    this.nameZh,
    this.code,
    this.codeAlpha3,
    this.continent,
    this.flagUrl,
    this.callingCode,
    required this.isActive,
  });

  factory CountryOptionDto.fromJson(Map<String, dynamic> json) {
    return CountryOptionDto(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      nameZh: json['nameZh']?.toString(),
      code: json['code']?.toString(),
      codeAlpha3: json['codeAlpha3']?.toString(),
      continent: json['continent']?.toString(),
      flagUrl: json['flagUrl']?.toString(),
      callingCode: json['callingCode']?.toString(),
      isActive: json['isActive'] == null
          ? true
          : json['isActive'] is bool
              ? json['isActive'] as bool
              : (json['isActive']?.toString().toLowerCase() == 'true'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameZh': nameZh,
      'code': code,
      'codeAlpha3': codeAlpha3,
      'continent': continent,
      'flagUrl': flagUrl,
      'callingCode': callingCode,
      'isActive': isActive,
    };
  }

  domain.CountryOption toDomain() {
    return domain.CountryOption(
      id: id,
      name: name,
      nameZh: nameZh,
      code: code,
      codeAlpha3: codeAlpha3,
      continent: continent,
      flagUrl: flagUrl,
      callingCode: callingCode,
      isActive: isActive,
    );
  }
}
