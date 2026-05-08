// lib/providers/category_provider.dart
// State management untuk kategori produk (Fetch, CRUD lengkap)

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  bool                _isLoading  = false;
  String?             _errorMessage;

  List<CategoryModel> get categories     => _categories;
  bool                get isLoading      => _isLoading;
  String?             get errorMessage   => _errorMessage;

  // ── Ambil semua kategori dari API ─────────────────────
  Future<void> fetchCategories() async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.get(ApiConstants.categories);

      if (result['success'] == true) {
        final raw  = result['data'];
        final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
        _categories = list
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _errorMessage = null;
      } else {
        _errorMessage = result['message'] as String? ?? 'Gagal memuat kategori';
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Tambah kategori baru ─────────────────────────────
  Future<String?> addCategory(Map<String, dynamic> data) async {
    try {
      final result = await ApiService.post(ApiConstants.categories, data);
      if (result['success'] == true) {
        await fetchCategories();
        return null; // null = sukses
      }
      return result['message'] as String? ?? 'Gagal menambah kategori';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Update kategori ──────────────────────────────────
  Future<String?> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final result = await ApiService.put(
        ApiConstants.categoryDetail(id),
        data,
      );
      if (result['success'] == true) {
        await fetchCategories();
        return null;
      }
      return result['message'] as String? ?? 'Gagal memperbarui kategori';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Hapus kategori ───────────────────────────────────
  Future<String?> deleteCategory(int id) async {
    try {
      final result = await ApiService.delete(ApiConstants.categoryDetail(id));
      if (result['success'] == true) {
        _categories.removeWhere((c) => c.id == id);
        notifyListeners();
        return null;
      }
      return result['message'] as String? ?? 'Gagal menghapus kategori';
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  // ── Clear error message ──────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
