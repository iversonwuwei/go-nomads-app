/// 产品横幅领域实体
class Banner {
  final int id;
  final String title;
  final String imageUrl;
  final String linkUrl;

  const Banner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.linkUrl,
  });

  /// 是否有有效的链接
  bool get hasValidLink => linkUrl.isNotEmpty && Uri.tryParse(linkUrl) != null;
}

/// 产品领域实体
class Product {
  final int id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final String description;
  final bool isHot;

  const Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    required this.description,
    required this.isHot,
  });

  /// 是否有折扣
  bool get isOnSale => originalPrice != null && originalPrice! > price;

  /// 折扣百分比
  double get discountPercentage {
    if (!isOnSale || originalPrice == null) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  /// 是否是热门产品
  bool get isTrending => isHot;

  /// 价格显示文本
  String get priceDisplay => '¥${price.toStringAsFixed(2)}';

  /// 原价显示文本
  String? get originalPriceDisplay =>
      originalPrice != null ? '¥${originalPrice!.toStringAsFixed(2)}' : null;
}
