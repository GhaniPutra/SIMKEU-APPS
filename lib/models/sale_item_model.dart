// lib/models/sale_item_model.dart
// Model satu baris item dalam transaksi penjualan

class SaleItemModel {
  final int    productId;
  final String productName;
  final int    quantity;
  final double price;
  final double subtotal;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
    return SaleItemModel(
      productId   : json['product_id'] as int,
      productName : (json['product'] as Map<String, dynamic>?)?['name'] as String? ?? '-',
      quantity    : (json['quantity'] as num).toInt(),
      price       : d(json['price']),
      subtotal    : d(json['subtotal']),
    );
  }

  // Digunakan saat POST transaksi baru
  Map<String, dynamic> toJson() => {
        'product_id' : productId,
        'quantity'   : quantity,
        'price'      : price,
      };
}
