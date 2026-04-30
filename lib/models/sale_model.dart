// lib/models/sale_model.dart
// Model transaksi penjualan (header)

import 'sale_item_model.dart';

class SaleModel {
  final int              id;
  final String           invoiceNumber;
  final double           totalAmount;
  final String           paymentMethod;
  final String?          notes;
  final String           createdAt;
  final List<SaleItemModel> items;

  const SaleModel({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.items,
  });

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => double.tryParse(v.toString()) ?? 0.0;

    final rawItems = json['items'] as List<dynamic>? ?? [];
    return SaleModel(
      id            : json['id'] as int,
      invoiceNumber : json['invoice_number'] as String? ?? '#${json['id']}',
      totalAmount   : d(json['total_amount'] ?? json['total'] ?? 0),
      paymentMethod : json['payment_method'] as String? ?? 'tunai',
      notes         : json['notes'] as String?,
      createdAt     : json['created_at'] as String? ?? '',
      items         : rawItems
          .map((e) => SaleItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
