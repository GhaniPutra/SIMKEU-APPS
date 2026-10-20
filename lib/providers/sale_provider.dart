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
  String?         _dashboardError;

  // Data dashboard summary
  double _todayTotal      = 0;
  int    _todayCount      = 0;
  double _monthTotal      = 0;
  double _todayExpenseTotal = 0;
  List<String> _trendLabels = [];
  List<double> _revenueTrend = [];
  List<double> _expenseTrend = [];

  List<SaleModel> get sales                => _sales;
  List<dynamic>   get salesReportByProduct => _salesReportByProduct;
  SaleModel?      get lastSale             => _lastSale;
  bool            get isLoading            => _isLoading;
  String?         get errorMessage         => _errorMessage;
  String?         get dashboardError       => _dashboardError;
  double          get todayTotal           => _todayTotal;
  int             get todayCount           => _todayCount;
  double          get monthTotal           => _monthTotal;
  double          get todayExpenseTotal    => _todayExpenseTotal;
  List<String>    get trendLabels          => _trendLabels;
  List<double>    get revenueTrend         => _revenueTrend;
  List<double>    get expenseTrend         => _expenseTrend;

  // ── Ambil riwayat penjualan ───────────────────────────
  Future<void> fetchSales({String? search, String? metode}) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (metode != null && metode.isNotEmpty) {
      params['metode'] = metode == 'ewallet' ? 'qris' : metode;
    }

    try {
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
    } catch (error) {
      _errorMessage = 'Data penjualan tidak dapat dibaca: $error';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil data dashboard ──────────────────────────────
  Future<void> fetchDashboard() async {
    _dashboardError = null;
    try {
      final result = await ApiService.get(ApiConstants.dashboardSummary);
      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>? ?? {};
        final summary = data['summary'] as Map<String, dynamic>? ?? {};
        final trends = data['trends'] as Map<String, dynamic>? ?? {};
        if (summary.isNotEmpty) {
          _todayTotal = _toDouble(summary['revenue_today']);
          _todayCount = _toInt(summary['transactions_today']);
          _monthTotal = _toDouble(summary['revenue_month']);
          _todayExpenseTotal = _toDouble(summary['expense_today']);
          _trendLabels = (trends['labels'] as List<dynamic>? ?? [])
              .map((value) => value.toString()).toList();
          _revenueTrend = (trends['revenue_data'] as List<dynamic>? ?? [])
              .map(_toDouble).toList();
          _expenseTrend = (trends['expense_data'] as List<dynamic>? ?? [])
              .map(_toDouble).toList();
          notifyListeners();
          return;
        }
        _dashboardError = result['message'] as String? ?? 'Ringkasan belum dapat dimuat.';
      } else {
        _dashboardError = result['message'] as String? ?? 'Ringkasan belum dapat dimuat.';
      }
    } catch (error) {
      _dashboardError = 'Ringkasan tidak dapat dibaca: $error';
    }
    _todayTotal = 0;
    _todayCount = 0;
    _monthTotal = 0;
    _todayExpenseTotal = 0;
    _trendLabels = [];
    _revenueTrend = [];
    _expenseTrend = [];
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
      'payment_method' : paymentMethod == 'ewallet' ? 'qris' : paymentMethod,
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

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? double.tryParse(v.toString())?.toInt() ?? 0;
  }
}
