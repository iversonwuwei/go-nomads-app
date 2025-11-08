import '../../../../models/product_model.dart';
import '../../domain/entities/product.dart';

/// 产品横幅数据传输对象
class BannerDto {
  final int id;
  final String title;
  final String imageUrl;
  final String linkUrl;

  BannerDto({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
  });

  factory BannerDto.fromJson(Map<String, dynamic> json) {
    return BannerDto(
      id: json['id'] as int,
      title: json['title'] as String,
      imageUrl: json['imageUrl'] as String,
      linkUrl: json['linkUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
    };
  }

  Banner toDomain() {
    return Banner(
      id: id,
      title: title,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
    );
  }

  static BannerDto fromLegacyModel(BannerModel model) {
    return BannerDto(
      id: model.id,
      title: model.title,
      imageUrl: model.imageUrl,
      linkUrl: model.linkUrl,
    );
  }
}

/// 产品数据传输对象
class ProductDto {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String description;
  final bool isHot;

  ProductDto({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.isHot,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null
          ? (json['originalPrice'] as num).toDouble()
          : null,
      description: json['description'] as String,
      isHot: json['isHot'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'originalPrice': originalPrice,
      'description': description,
      'isHot': isHot,
    };
  }

  Product toDomain() {
    return Product(
      id: id,
      name: name,
      imageUrl: imageUrl,
      price: price,
      originalPrice: originalPrice,
      description: description,
      isHot: isHot,
    );
  }

  static ProductDto fromLegacyModel(ProductModel model) {
    return ProductDto(
      id: model.id,
      name: model.name,
      imageUrl: model.imageUrl,
      price: model.price,
      originalPrice: model.originalPrice,
      description: model.description,
      isHot: model.isHot,
    );
  }
}
