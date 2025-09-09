class BannerModel {
  final String id;
  final String title;
  final String imageUrl;
  final String? linkUrl;

  BannerModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.linkUrl,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String? description;
  final bool isHot;

  ProductModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.description,
    this.isHot = false,
  });
}
