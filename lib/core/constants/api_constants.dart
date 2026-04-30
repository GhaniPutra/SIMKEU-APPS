// lib/core/constants/api_constants.dart
// Konstanta URL dan endpoint API SIMKEU

class ApiConstants {
  // Base URL backend Laravel — ganti jika IP berubah
  static const String baseUrl = 'http://10.69.96.210:8000/api';

  // ── Auth ──────────────────────────────────────────────
  static const String login    = '$baseUrl/login';
  static const String logout   = '$baseUrl/logout';
  static const String user     = '$baseUrl/user';

  // ── Dashboard ─────────────────────────────────────────
  static const String dashboard        = '$baseUrl/dashboard';
  static const String dashboardSummary = '$baseUrl/dashboard/summary';

  // ── Products ──────────────────────────────────────────
  static const String products = '$baseUrl/products';
  static String productDetail(int id) => '$baseUrl/products/$id';
  static String productStock(int id)  => '$baseUrl/products/$id/stock';
  static String productSearch(String q) => '$baseUrl/products/search/$q';

  // ── Categories ────────────────────────────────────────
  static const String categories = '$baseUrl/categories';
  static String categoryDetail(int id) => '$baseUrl/categories/$id';

  // ── POS ───────────────────────────────────────────────
  static const String posItems       = '$baseUrl/pos/items';
  static const String posTransaction = '$baseUrl/pos/transaction';
  static String posComplete(int id)  => '$baseUrl/pos/transaction/$id/complete';

  // ── Sales (Penjualan) ─────────────────────────────────
  static const String sales         = '$baseUrl/sales';
  static String saleDetail(int id)  => '$baseUrl/sales/$id';
  static const String salesReport   = '$baseUrl/sales/report/period';

  // ── Expenses (Pengeluaran) ────────────────────────────
  static const String expenses         = '$baseUrl/expenses';
  static String expenseDetail(int id)  => '$baseUrl/expenses/$id';
}
