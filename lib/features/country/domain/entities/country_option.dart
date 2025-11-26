/// CountryOption Domain Entity - 国家选项
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

  // Business logic methods
  bool get hasCode => code != null && code!.isNotEmpty;

  bool get hasFlag => flagUrl != null && flagUrl!.isNotEmpty;

  String displayName(String localeCode) {
    if (localeCode.startsWith('zh') && (nameZh?.isNotEmpty ?? false)) {
      return nameZh!;
    }
    return name;
  }
}
