class CityOption {
  final String id;
  final String name;
  final String? region;

  const CityOption({
    required this.id,
    required this.name,
    this.region,
  });

  factory CityOption.fromJson(Map<String, dynamic> json) {
    return CityOption(
      id: json['id']?.toString() ?? '',
      name: (json['name'] ?? '').toString(),
      region: json['region']?.toString(),
    );
  }
}
