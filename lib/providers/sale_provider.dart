// lib/providers/sale_provider.dart
// State management untuk transaksi penjualan

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/sale_model.dart';

class SaleProvider extends ChangeNotifier {
  List<SaleModel> _sales                = [];
  List<dynamic>   _salesReportByProduct = [];
  SaleModel?      _lastSale;
  bool            _isLoading            = false;
  String?         _errorMessage;

  // Data dashboard summary
  double _todayTotal      = 0;
  int    _todayCount      = 0;
  double _monthTotal      = 0;

  List<SaleModel> get sales                => _sales;
  List<dynamic>   get salesReportByProduct => _salesReportByProduct;
  SaleModel?      get lastSale             => _lastSale;
  bool            get isLoading            => _isLoading;
  String?         get errorMessage         => _errorMessage;
  double          get todayTotal           => _todayTotal;
  int             get todayCount           => _todayCount;
  double          get monthTotal           => _monthTotal;

  // ── Ambil riwayat penjualan ───────────────────────────
  Future<void> fetchSales({String? search, String? metode}) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (metode != null && metode.isNotEmpty) params['metode'] = metode;

    final result = await ApiService.get(
      ApiConstants.sales,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw  = result['data'];
      final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
      _sales = list
          .map((e) => SaleModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat penjualan';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil data dashboard ──────────────────────────────
  Future<void> fetchDashboard() async {
    // Coba fetch dari API endpoint dashboard
    final result = await ApiService.get(ApiConstants.dashboard);
    
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      
      // Parse berbagai format field yang mungkin dari backend
      final todayFromApi = _toDouble(data['today_sales'] ?? data['penjualan_hari_ini'] ?? 0);
      final countFromApi = (data['today_transactions'] ?? data['transaksi_hari_ini'] ?? data['count'] ?? 0) as int;
      final monthFromApi = _toDouble(data['month_sales'] ?? data['penjualan_bulan'] ?? data['bulan'] ?? 0);
      
      // Jika API mengembalikan data valid (bukan 0), gunakan
      if (todayFromApi > 0 || countFromApi > 0 || monthFromApi > 0) {
        _todayTotal = todayFromApi;
        _todayCount = countFromApi;
        _monthTotal = monthFromApi;
        notifyListeners();
        return;
      }
    }
    
    // FALLBACK: Jika API gagal atau tidak ada data, hitung dari sales list
    await _calculateDashboardFromSales();
  }

  // ── Hitung dashboard dari sales data (fallback) ────────
  Future<void> _calculateDashboardFromSales() async {
    // Pastikan kita punya data sales terbaru
    if (_sales.isEmpty) {
      await fetchSales();
    }

    final today = DateTime.now();
    final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    double todaySum = 0;
    int todayCount = 0;
    double monthSum = 0;

    for (final sale in _sales) {
      final saleDate = sale.createdAt;
      double amount = sale.totalAmount;

      // Hitung penjualan hari ini
      if (saleDate.startsWith(todayStr)) {
        todaySum += amount;
        todayCount += 1;
      }

      // Hitung penjualan bulan ini
      final monthStr = '${today.year}-${today.month.toString().padLeft(2, '0')}';
      if (saleDate.startsWith(monthStr)) {
        monthSum += amount;
      }
    }

    _todayTotal = todaySum;
    _todayCount = todayCount;
    _monthTotal = monthSum;
    notifyListeners();
  }

  // ── Buat transaksi penjualan baru ─────────────────────
  Future<String?> createSale({
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final body = {
      'payment_method' : paymentMethod,
      'items'          : items,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final result = await ApiService.post(ApiConstants.posTransaction, body);
    _isLoading = false;

    if (result['success'] == true) {
      final raw = result['data'];
      // Data bisa langsung sale atau nested
      final saleData = (raw is Map && raw.containsKey('sale'))
          ? raw['sale'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      _lastSale = SaleModel.fromJson(saleData);
      notifyListeners();
      return null; // sukses
    }

    notifyListeners();
    return result['message'] as String? ?? 'Gagal membuat transaksi';
  }

  // ── Ambil laporan penjualan per periode ──────────────
  Future<void> fetchSalesReportByPeriod({
    String? startDate,
    String? endDate,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final result = await ApiService.get(
      ApiConstants.salesReportPeriod,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw = result['data'];
      final list = (raw is List) ? raw : (raw is Map ? raw['data'] : []);
      _salesReportByProduct = list as List<dynamic>;
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat laporan penjualan';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil laporan penjualan per produk ───────────────
  Future<void> fetchSalesReportByProduct({
    String? startDate,
    String? endDate,
  }) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final params = <String, String>{};
    if (startDate != null) params['start_date'] = startDate;
    if (endDate != null) params['end_date'] = endDate;

    final result = await ApiService.get(
      ApiConstants.salesReportByProduct,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw = result['data'];
      final list = (raw is List) ? raw : (raw is Map ? raw['data'] : []);
      _salesReportByProduct = list as List<dynamic>;
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat laporan penjualan per produk';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Clear error message ─────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  double _toDouble(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
}
