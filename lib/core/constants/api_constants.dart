// lib/core/constants/api_constants.dart
// Konstanta URL dan endpoint API SIMKEU

class ApiConstants {
  // Base URL backend Laravel — ganti jika IP berubah
  static const String serverUrl = 'http://10.75.21.192:8000';
  static const String baseUrl = '$serverUrl/api';
  static const String broadcastAuth = '$baseUrl/broadcasting/auth';
  static const String reverbAppKey = String.fromEnvironment('REVERB_APP_KEY');
  static const String configuredReverbScheme = String.fromEnvironment('REVERB_SCHEME');
  static const int configuredReverbPort =
      int.fromEnvironment('REVERB_PORT', defaultValue: 0);
  static String get reverbScheme => configuredReverbScheme.isEmpty
      ? Uri.parse(serverUrl).scheme
      : configuredReverbScheme;
  static int get reverbPort => configuredReverbPort > 0
      ? configuredReverbPort
      : (reverbScheme == 'https' ? 443 : 8080);
  static const String configuredReverbHost = String.fromEnvironment('REVERB_HOST');
  static String get reverbHost =>
      configuredReverbHost.isEmpty ? Uri.parse(serverUrl).host : configuredReverbHost;

  /// Membuat URL publik untuk path gambar yang dikembalikan Laravel.
  /// Backend biasanya mengirim `products/nama-file.jpg`, tetapi URL absolut
  /// dan path yang sudah diawali `storage/` juga tetap didukung.
  static String? productImageUrl(String? imagePath) {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;

    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return path;

    final normalizedPath = path.replaceFirst(RegExp(r'^/+'), '');
    final publicPath = normalizedPath.startsWith('storage/')
        ? normalizedPath
        : 'storage/$normalizedPath';

    return '$serverUrl/$publicPath';
  }

  // ── Auth ──────────────────────────────────────────────
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String user = '$baseUrl/user';
  static const String userProfile = '$baseUrl/user/profile';

  // ── Dashboard ─────────────────────────────────────────
  static const String dashboard = '$baseUrl/dashboard';
  static const String dashboardSummary = '$baseUrl/dashboard/summary';

  // ── Products ──────────────────────────────────────────
  static const String products = '$baseUrl/products';
  static String productDetail(int id) => '$baseUrl/products/$id';
  static String productStock(int id) => '$baseUrl/products/$id/stock';
  static String productSearch(String q) => '$baseUrl/products/search/$q';

  // ── Categories ────────────────────────────────────────
  static const String categories = '$baseUrl/categories';
  static String categoryDetail(int id) => '$baseUrl/categories/$id';

  // ── POS ───────────────────────────────────────────────
  static const String posItems = '$baseUrl/pos/items';
  static const String posTransaction = '$baseUrl/pos/transaction';
  static String posComplete(int id) => '$baseUrl/pos/transaction/$id/complete';

  // ── Sales (Penjualan) ─────────────────────────────────
  static const String sales = '$baseUrl/sales';
  static String saleDetail(int id) => '$baseUrl/sales/$id';
  static const String salesReportPeriod = '$baseUrl/sales/report/period';
  static const String salesReportByProduct = '$baseUrl/sales/report/product';

  // ── Expenses (Pengeluaran) ────────────────────────────
  static const String expenses = '$baseUrl/expenses';
  static String expenseDetail(int id) => '$baseUrl/expenses/$id';
  static const String expensesReportPeriod = '$baseUrl/expenses/report/period';
  static const String expensesReportByCategory =
      '$baseUrl/expenses/report/category';

  // ── Employees (Karyawan) ──────────────────────────────
  static const String employees = '$baseUrl/employees';
  static String employeeDetail(int id) => '$baseUrl/employees/$id';
  static String employeeSales(int id) => '$baseUrl/employees/$id/sales';

  // ── Stock allocation (alokasi stok) ───────────────────
  // Endpoint ini tersedia pada routes/api.php dan memerlukan Bearer token.
  static const String pendingStockAllocations =
      '$baseUrl/stock-allocations/pending';
  static String employeeStockAllocations(int employeeId) =>
      '$baseUrl/employees/$employeeId/stock/allocations';
  static String reviewStockAllocation(int allocationId) =>
      '$baseUrl/stock-allocations/$allocationId/review';
}
