import 'package:flutter/material.dart';

class ApiInterfaceModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final double? originalPrice;
  final String endpoint;
  final List<String> methods; // GET, POST, PUT, DELETE
  final int callsPerMonth;
  final double responseTime; // 响应时间(毫秒)
  final double reliability; // 可靠性百分比
  final bool isHot;
  final bool isFree;
  final Color tileColor;
  final IconData icon;

  ApiInterfaceModel({
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
    required this.tileColor,
    required this.icon,
  });
}
