// lib/providers/employee_provider.dart
// State management untuk manajemen karyawan (CRUD lengkap)

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/user_model.dart';

class EmployeeProvider extends ChangeNotifier {
  List<UserModel> _employees   = [];
  UserModel?      _selectedEmployee;
  bool            _isLoading   = false;
  String?         _errorMessage;

  List<UserModel> get employees           => _employees;
  UserModel?      get selectedEmployee    => _selectedEmployee;
  bool            get isLoading           => _isLoading;
  String?         get errorMessage        => _errorMessage;

  // ── Ambil daftar semua karyawan ──────────────────────
  Future<void> fetchEmployees({String? search}) async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final params = <String, String>{};
      if (search != null && search.isNotEmpty) params['search'] = search;

      final result = await ApiService.get(
        ApiConstants.employees,
        queryParams: params.isEmpty ? null : params,
      );

      if (result['success'] == true) {
        final raw  = result['data'];
        final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
        _employees = list
            .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] as String? ?? 'Gagal memuat karyawan';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil detail satu karyawan ───────────────────────
  Future<String?> fetchEmployeeDetail(int id) async {
    try {
      final result = await ApiService.get(ApiConstants.employeeDetail(id));

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        _selectedEmployee = UserModel.fromJson(data);
        notifyListeners();
        return null;
      }
      return result['message'] as String? ?? 'Gagal memuat detail karyawan';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Tambah karyawan baru ─────────────────────────────
  Future<String?> addEmployee(Map<String, dynamic> data) async {
    try {
      final result = await ApiService.post(ApiConstants.employees, data);
      if (result['success'] == true) {
        await fetchEmployees();
        return null;
      }
      return result['message'] as String? ?? 'Gagal menambah karyawan';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Update karyawan ──────────────────────────────────
  Future<String?> updateEmployee(int id, Map<String, dynamic> data) async {
    try {
      final result = await ApiService.put(
        ApiConstants.employeeDetail(id),
        data,
      );
      if (result['success'] == true) {
        await fetchEmployees();
        return null;
      }
      return result['message'] as String? ?? 'Gagal memperbarui karyawan';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Hapus karyawan ───────────────────────────────────
  Future<String?> deleteEmployee(int id) async {
    try {
      final result = await ApiService.delete(ApiConstants.employeeDetail(id));
      if (result['success'] == true) {
        _employees.removeWhere((e) => e.id == id);
        notifyListeners();
        return null;
      }
      return result['message'] as String? ?? 'Gagal menghapus karyawan';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Ambil data penjualan karyawan ────────────────────
  Future<Map<String, dynamic>> getEmployeeSalesData(
    int id, {
    String? startDate,
    String? endDate,
  }) async {
    try {
      final params = <String, String>{};
      if (startDate != null) params['start_date'] = startDate;
      if (endDate != null) params['end_date'] = endDate;

      final result = await ApiService.get(
        ApiConstants.employeeSales(id),
        queryParams: params.isEmpty ? null : params,
      );

      if (result['success'] == true) {
        return {
          'success': true,
          'sales': result['data'],
          'stats': result['stats'],
        };
      }
      return {
        'success': false,
        'message': result['message'] ?? 'Gagal memuat data penjualan',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // ── Clear error message ──────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
