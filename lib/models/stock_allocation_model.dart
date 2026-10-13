class StockAllocationModel {
  final int id;
  final int productId;
  final String productName;
  final String productUnit;
  final int requestedQuantity;
  final int? confirmedQuantity;
  final int? actualReceivedQuantity;
  final int? differenceQuantity;
  final String status;
  final String? declineReason;
  final int? ownerUserId;
  final int? employeeUserId;
  final DateTime? createdAt;
  final DateTime? reviewedAt;

  const StockAllocationModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productUnit,
    required this.requestedQuantity,
    this.confirmedQuantity,
    this.actualReceivedQuantity,
    this.differenceQuantity,
    required this.status,
    this.declineReason,
    this.ownerUserId,
    this.employeeUserId,
    this.createdAt,
    this.reviewedAt,
  });

  factory StockAllocationModel.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    final productName = (productData['name'] ?? json['product_name'] ?? 'Produk')
        .toString();
    final productUnit = (productData['unit'] ?? json['unit'] ?? 'pcs').toString();

    return StockAllocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      productId: (json['product_id'] as num?)?.toInt() ??
          (productData['id'] as num?)?.toInt() ?? 0,
      productName: productName,
      productUnit: productUnit,
      requestedQuantity: (json['requested_quantity'] as num?)?.toInt() ??
          (json['requestedQuantity'] as num?)?.toInt() ?? 0,
      confirmedQuantity: (json['confirmed_quantity'] as num?)?.toInt() ??
          (json['confirmedQuantity'] as num?)?.toInt(),
      actualReceivedQuantity: (json['actual_received_quantity'] as num?)?.toInt() ??
          (json['actualReceivedQuantity'] as num?)?.toInt(),
      differenceQuantity: (json['difference_quantity'] as num?)?.toInt() ??
          (json['differenceQuantity'] as num?)?.toInt(),
      status: (json['status'] ?? 'pending').toString(),
      declineReason: json['decline_reason'] as String? ??
          json['declineReason'] as String?,
      ownerUserId: (json['owner_user_id'] as num?)?.toInt() ??
          (json['ownerUserId'] as num?)?.toInt(),
      employeeUserId: (json['employee_user_id'] as num?)?.toInt() ??
          (json['employeeUserId'] as num?)?.toInt(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      reviewedAt: _parseDate(json['reviewed_at'] ?? json['reviewedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'product_id': productId,
        'product_name': productName,
        'unit': productUnit,
        'requested_quantity': requestedQuantity,
        'confirmed_quantity': confirmedQuantity,
        'actual_received_quantity': actualReceivedQuantity,
        'difference_quantity': differenceQuantity,
        'status': status,
        'decline_reason': declineReason,
        'owner_user_id': ownerUserId,
        'employee_user_id': employeeUserId,
        'created_at': createdAt?.toIso8601String(),
        'reviewed_at': reviewedAt?.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value == '') return null;
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }
}
