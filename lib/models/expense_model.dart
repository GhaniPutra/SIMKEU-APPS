// lib/models/expense_model.dart
// Model pengeluaran operasional

class ExpenseModel {
  final int     id;
  final String  name;
  final double  amount;
  final String  category;
  final String? description;
  final String  date;
  final String  createdAt;

  const ExpenseModel({
    required this.id,
    required this.name,
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
      name        : json['name'] as String? ?? json['keterangan'] as String? ?? '-',
      amount      : d(json['amount'] ?? json['jumlah'] ?? 0),
      category    : json['category'] as String? ?? json['kategori'] as String? ?? '-',
      description : json['description'] as String?,
      date        : json['date'] as String? ?? json['tanggal'] as String? ?? '',
      createdAt   : json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name'        : name,
        'amount'      : amount,
        'category'    : category,
        'description' : description,
        'date'        : date,
      };
}
