// lib/core/constants/api_constants.dart
// Konstanta URL dan endpoint API SIMKEU

class ApiConstants {
  // Base URL backend Laravel — ganti jika IP berubah
  static const String baseUrl = 'http://10.179.184.35:8000/api';

  // ── Auth ──────────────────────────────────────────────
  static const String register    = '$baseUrl/register';
  static const String login       = '$baseUrl/login';
  static const String logout      = '$baseUrl/logout';
  static const String user        = '$baseUrl/user';
  static const String userProfile = '$baseUrl/user/profile';

  // ── Dashboard ─────────────────────────────────────────
  static const String dashboard        = '$baseUrl/dashboard';
  static const String dashboardSummary = '$baseUrl/dashboard/summary';

  // ── Products ──────────────────────────────────────────
  static const String products          = '$baseUrl/products';
  static String productDetail(int id)    => '$baseUrl/products/$id';
  static String productStock(int id)     => '$baseUrl/products/$id/stock';
  static String productSearch(String q)  => '$baseUrl/products/search/$q';

  // ── Categories ────────────────────────────────────────
  static const String categories         = '$baseUrl/categories';
  static String categoryDetail(int id)   => '$baseUrl/categories/$id';

  // ── POS ───────────────────────────────────────────────
  static const String posItems       = '$baseUrl/pos/items';
  static const String posTransaction = '$baseUrl/pos/transaction';
  static String posComplete(int id)  => '$baseUrl/pos/transaction/$id/complete';

  // ── Sales (Penjualan) ─────────────────────────────────
  static const String sales                    = '$baseUrl/sales';
  static String saleDetail(int id)             => '$baseUrl/sales/$id';
  static const String salesReportPeriod        = '$baseUrl/sales/report/period';
  static const String salesReportByProduct     = '$baseUrl/sales/report/product';

  // ── Expenses (Pengeluaran) ────────────────────────────
  static const String expenses                 = '$baseUrl/expenses';
  static String expenseDetail(int id)          => '$baseUrl/expenses/$id';
  static const String expensesReportPeriod     = '$baseUrl/expenses/report/period';
  static const String expensesReportByCategory = '$baseUrl/expenses/report/category';

  // ── Employees (Karyawan) ──────────────────────────────
  static const String employees                 = '$baseUrl/employees';
  static String employeeDetail(int id)          => '$baseUrl/employees/$id';
  static String employeeSales(int id)           => '$baseUrl/employees/$id/sales';

  // ── Stock allocation (alokasi stok) ───────────────────
  // Backend web SIMKEU memiliki endpoint review alokasi di routes/web.php,
  // tetapi kontrak API mobile belum tersedia di routes/api.php. UI dibuat
  // supaya tidak mengarang struktur JSON baru dan menampilkan pesan jelas
  // ketika endpoint belum ada.
  static const String pendingStockAllocations = '$baseUrl/stock-allocations/pending';
  static String employeeStockAllocations(int employeeId) =>
      '$baseUrl/employees/$employeeId/stock/allocations';
  static String reviewStockAllocation(int allocationId) =>
      '$baseUrl/stock-allocations/$allocationId/review';
}
