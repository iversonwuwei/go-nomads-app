import 'package:flutter/material.dart';

/// Represents a single rating entry (name, icon, score) that can be
/// displayed inside the City detail "Scores" tab.
class CityRatingItem {
  final String id;
  final String label;
  final int iconCodePoint;
  final String? fontFamily;
  final String? fontPackage;
  final bool matchTextDirection;
  final double score;
  final bool isDefault;

  const CityRatingItem({
    required this.id,
    required this.label,
    required this.iconCodePoint,
    required this.fontFamily,
    required this.fontPackage,
    required this.matchTextDirection,
    required this.score,
    this.isDefault = false,
  });

  factory CityRatingItem.fromIcon({
    required String id,
    required String label,
    required IconData icon,
    required double score,
    bool isDefault = false,
  }) {
    return CityRatingItem(
      id: id,
      label: label,
      iconCodePoint: icon.codePoint,
      fontFamily: icon.fontFamily,
      fontPackage: icon.fontPackage,
      matchTextDirection: icon.matchTextDirection,
      score: score,
      isDefault: isDefault,
    );
  }

  /// Returns the IconData for this rating item.
  /// Note: This is a method (not a getter) to avoid tree-shaking issues
  /// when building release APK.
  IconData getIcon() => IconData(
        iconCodePoint,
        fontFamily: fontFamily,
        fontPackage: fontPackage,
        matchTextDirection: matchTextDirection,
      );

  CityRatingItem copyWith({
    String? id,
    String? label,
    int? iconCodePoint,
    String? fontFamily,
    String? fontPackage,
    bool? matchTextDirection,
    double? score,
    bool? isDefault,
  }) {
    return CityRatingItem(
      id: id ?? this.id,
      label: label ?? this.label,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      fontFamily: fontFamily ?? this.fontFamily,
      fontPackage: fontPackage ?? this.fontPackage,
      matchTextDirection: matchTextDirection ?? this.matchTextDirection,
      score: score ?? this.score,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CityRatingItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
