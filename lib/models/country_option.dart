class CountryOption {
  final String id;
  final String name;
  final String? nameZh;
  final String? code;
  final String? codeAlpha3;
  final String? continent;
  final String? flagUrl;
  final String? callingCode;
  final bool isActive;

  const CountryOption({
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

  factory CountryOption.fromJson(Map<String, dynamic> json) {
    return CountryOption(
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

  String displayName(String localeCode) {
    if (localeCode.startsWith('zh') && (nameZh?.isNotEmpty ?? false)) {
      return nameZh!;
    }
    return name;
  }
}
