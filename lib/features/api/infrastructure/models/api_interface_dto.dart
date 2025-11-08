import 'package:flutter/material.dart';

import '../../../../models/api_interface_model.dart' as legacy;
import '../../domain/entities/api_interface.dart' as domain;

/// ApiInterface DTO
class ApiInterfaceDto {
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
  final int tileColorValue;
  final int iconCodePoint;

  ApiInterfaceDto({
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
    this.isHot = false,
    this.isFree = false,
    required this.tileColorValue,
    required this.iconCodePoint,
  });

  factory ApiInterfaceDto.fromJson(Map<String, dynamic> json) {
    return ApiInterfaceDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      endpoint: json['endpoint'] as String,
      methods: (json['methods'] as List<dynamic>).cast<String>(),
      callsPerMonth: json['callsPerMonth'] as int,
      responseTime: (json['responseTime'] as num).toDouble(),
      reliability: (json['reliability'] as num).toDouble(),
      isHot: json['isHot'] as bool? ?? false,
      isFree: json['isFree'] as bool? ?? false,
      tileColorValue: json['tileColorValue'] as int,
      iconCodePoint: json['iconCodePoint'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'originalPrice': originalPrice,
      'endpoint': endpoint,
      'methods': methods,
      'callsPerMonth': callsPerMonth,
      'responseTime': responseTime,
      'reliability': reliability,
      'isHot': isHot,
      'isFree': isFree,
      'tileColorValue': tileColorValue,
      'iconCodePoint': iconCodePoint,
    };
  }

  domain.ApiInterface toDomain() {
    return domain.ApiInterface(
      id: id,
      name: name,
      description: description,
      category: category,
      price: price,
      originalPrice: originalPrice,
      endpoint: endpoint,
      methods: methods,
      callsPerMonth: callsPerMonth,
      responseTime: responseTime,
      reliability: reliability,
      isHot: isHot,
      isFree: isFree,
      tileColor: Color(tileColorValue),
      icon: IconData(iconCodePoint, fontFamily: 'MaterialIcons'),
    );
  }

  factory ApiInterfaceDto.fromLegacyModel(legacy.ApiInterfaceModel model) {
    return ApiInterfaceDto(
      id: model.id,
      name: model.name,
      description: model.description,
      category: model.category,
      price: model.price,
      originalPrice: model.originalPrice,
      endpoint: model.endpoint,
      methods: model.methods,
      callsPerMonth: model.callsPerMonth,
      responseTime: model.responseTime,
      reliability: model.reliability,
      isHot: model.isHot,
      isFree: model.isFree,
      tileColorValue: model.tileColor.value,
      iconCodePoint: model.icon.codePoint,
    );
  }
}
