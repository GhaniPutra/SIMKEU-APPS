// lib/models/expense_model.dart
// Model pengeluaran operasional

class ExpenseModel {
  final int     id;
  final double  amount;
  final String  category;
  final String? description;
  final String  date;        // expense_date dari backend
  final String  createdAt;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.category,
    this.description,
    required this.date,
    required this.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
    return ExpenseModel(
      id          : json['id'] as int,
      amount      : d(json['amount'] ?? json['jumlah'] ?? 0),
      category    : json['category'] as String? ?? json['kategori'] as String? ?? 'lainnya',
      description : json['description'] as String?,
      date        : json['expense_date'] as String? ?? json['date'] as String? ?? json['tanggal'] as String? ?? '',
      createdAt   : json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'amount'       : amount,
        'category'     : category,
        'description'  : description,
        'expense_date' : date,
      };
}
