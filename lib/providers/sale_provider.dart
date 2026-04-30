// lib/providers/sale_provider.dart
// State management untuk transaksi penjualan

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/sale_model.dart';

class SaleProvider extends ChangeNotifier {
  List<SaleModel> _sales       = [];
  SaleModel?      _lastSale;
  bool            _isLoading   = false;
  String?         _errorMessage;

  // Data dashboard summary
  double _todayTotal      = 0;
  int    _todayCount      = 0;
  double _monthTotal      = 0;

  List<SaleModel> get sales        => _sales;
  SaleModel?      get lastSale     => _lastSale;
  bool            get isLoading    => _isLoading;
  String?         get errorMessage => _errorMessage;
  double          get todayTotal   => _todayTotal;
  int             get todayCount   => _todayCount;
  double          get monthTotal   => _monthTotal;

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
    final result = await ApiService.get(ApiConstants.dashboard);
    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>? ?? {};
      _todayTotal  = _toDouble(data['today_sales']  ?? data['penjualan_hari_ini'] ?? 0);
      _todayCount  = (data['today_transactions'] ?? data['transaksi_hari_ini'] ?? 0) as int;
      _monthTotal  = _toDouble(data['month_sales']  ?? data['penjualan_bulan'] ?? 0);
      notifyListeners();
    }
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

    final result = await ApiService.post(ApiConstants.sales, body);
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

  double _toDouble(dynamic v) => double.tryParse(v.toString()) ?? 0.0;
}
