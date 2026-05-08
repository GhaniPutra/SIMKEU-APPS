// lib/providers/expense_provider.dart
// State management untuk pengeluaran (CRUD lengkap)

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses              = [];
  List<dynamic>      _expensesReportByCategory = [];
  bool               _isLoading             = false;
  String?            _errorMessage;
  double             _totalMonth            = 0;

  List<ExpenseModel> get expenses                => _expenses;
  List<dynamic>      get expensesReportByCategory => _expensesReportByCategory;
  bool               get isLoading               => _isLoading;
  String?            get errorMessage           => _errorMessage;
  double             get totalMonth             => _totalMonth;

  // ── Ambil daftar pengeluaran ──────────────────────────
  Future<void> fetchExpenses({String? bulan, String? tahun}) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final params = <String, String>{};
    if (bulan != null)  params['bulan']  = bulan;
    if (tahun != null)  params['tahun']  = tahun;

    final result = await ApiService.get(
      ApiConstants.expenses,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw  = result['data'];
      final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
      _expenses = list
          .map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _totalMonth = _expenses.fold(0.0, (s, e) => s + e.amount);
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat pengeluaran';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Tambah pengeluaran baru ───────────────────────────
  Future<String?> addExpense(Map<String, dynamic> data) async {
    final result = await ApiService.post(ApiConstants.expenses, data);
    if (result['success'] == true) {
      await fetchExpenses();
      return null;
    }
    return result['message'] as String? ?? 'Gagal menambah pengeluaran';
  }

  // ── Update pengeluaran ────────────────────────────────
  Future<String?> updateExpense(int id, Map<String, dynamic> data) async {
    final result = await ApiService.put(ApiConstants.expenseDetail(id), data);
    if (result['success'] == true) {
      await fetchExpenses();
      return null;
    }
    return result['message'] as String? ?? 'Gagal memperbarui pengeluaran';
  }

  // ── Hapus pengeluaran ─────────────────────────────────
  Future<String?> deleteExpense(int id) async {
    final result = await ApiService.delete(ApiConstants.expenseDetail(id));
    if (result['success'] == true) {
      _expenses.removeWhere((e) => e.id == id);
      _totalMonth = _expenses.fold(0.0, (s, e) => s + e.amount);
      notifyListeners();
      return null;
    }
    return result['message'] as String? ?? 'Gagal menghapus pengeluaran';
  }

  // ── Ambil laporan pengeluaran per periode ────────────
  Future<void> fetchExpensesReportByPeriod({
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
      ApiConstants.expensesReportPeriod,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw = result['data'];
      final list = (raw is List) ? raw : (raw is Map ? raw['data'] : []);
      _expensesReportByCategory = list as List<dynamic>;
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat laporan pengeluaran';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil laporan pengeluaran per kategori ──────────
  Future<void> fetchExpensesReportByCategory({
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
      ApiConstants.expensesReportByCategory,
      queryParams: params.isEmpty ? null : params,
    );

    if (result['success'] == true) {
      final raw = result['data'];
      final list = (raw is List) ? raw : (raw is Map ? raw['data'] : []);
      _expensesReportByCategory = list as List<dynamic>;
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat laporan pengeluaran per kategori';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Clear error message ─────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
