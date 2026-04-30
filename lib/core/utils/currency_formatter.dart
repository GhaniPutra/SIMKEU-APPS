// lib/core/utils/currency_formatter.dart
// Utilitas untuk format angka menjadi format Rupiah Indonesia

import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Format angka ke Rupiah: 50000 → "Rp 50.000"
  static String format(dynamic amount) {
    final number = (amount is String)
        ? double.tryParse(amount) ?? 0.0
        : (amount as num).toDouble();
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  // Format singkat: 1500000 → "1,5 Jt"
  static String formatShort(dynamic amount) {
    final number = (amount is String)
        ? double.tryParse(amount) ?? 0.0
        : (amount as num).toDouble();
    if (number >= 1000000000) {
      return 'Rp ${(number / 1000000000).toStringAsFixed(1)} M';
    } else if (number >= 1000000) {
      return 'Rp ${(number / 1000000).toStringAsFixed(1)} Jt';
    } else if (number >= 1000) {
      return 'Rp ${(number / 1000).toStringAsFixed(0)} Rb';
    }
    return format(number);
  }

  // Parse string Rupiah kembali ke double
  static double parse(String formatted) {
    final clean = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(clean) ?? 0.0;
  }
}
