// lib/models/product_model.dart
// Model produk untuk POS dan manajemen stok

class ProductModel {
  final int id;
  final String name;
  final int? categoryId;
  final String? categoryName;
  final double buyPrice;
  final double sellPrice;
  final int stock;
  final String unit;
  final String? description;
  final String? image;

  const ProductModel({
    required this.id,
    required this.name,
    this.categoryId,
    this.categoryName,
    required this.buyPrice,
    required this.sellPrice,
    required this.stock,
    required this.unit,
    this.description,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Harga bisa berupa String atau num dari API
    double toDouble(dynamic v) =>
        v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    String? toNullableString(dynamic value) {
      final text = value?.toString().trim();
      return text == null || text.isEmpty ? null : text;
    }

    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      categoryId: json['category_id'] as int?,
      categoryName:
          (json['category'] as Map<String, dynamic>?)?['name'] as String?,
      buyPrice: toDouble(json['buy_price']),
      sellPrice: toDouble(json['sell_price']),
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      unit: json['unit'] as String? ?? 'pcs',
      description: json['description'] as String?,
      image: toNullableString(
        json['image'] ?? json['image_url'] ?? json['imageUrl'],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'category_id': categoryId,
        'buy_price': buyPrice,
        'sell_price': sellPrice,
        'stock': stock,
        'unit': unit,
        'description': description,
        'image': image,
      };
}
