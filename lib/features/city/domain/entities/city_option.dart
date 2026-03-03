/// CityOption Domain Entity - 城市选项
class CityOption {
  final String id;
  final String name;
  final String? region;
  final String? countryId;

  const CityOption({
    required this.id,
    required this.name,
    this.region,
    this.countryId,
  });

  // Business logic methods
  bool get hasRegion => region != null && region!.isNotEmpty;
}
