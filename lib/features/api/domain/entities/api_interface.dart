import 'package:flutter/material.dart';

/// ApiInterface Domain Entity - API接口
class ApiInterface {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? originalPrice;
  final String endpoint;
  final List<String> methods;
  final int callsPerMonth;
  final double responseTime;
  final double reliability;
  final bool isHot;
  final bool isFree;
  final Color tileColor;
  final IconData icon;

  ApiInterface({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.endpoint,
    required this.methods,
    required this.callsPerMonth,
    required this.responseTime,
    required this.reliability,
    required this.isHot,
    required this.isFree,
    required this.tileColor,
    required this.icon,
  });

  // Business logic methods
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!hasDiscount) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get isHighPerformance => responseTime < 100 && reliability > 99.0;

  bool get isPopular => isHot || callsPerMonth > 100000;

  bool supportsMethod(String method) =>
      methods.any((m) => m.toUpperCase() == method.toUpperCase());
}
