// lib/providers/product_provider.dart
// State management untuk data produk (fetch, search, CRUD)

import 'package:flutter/material.dart';
import '../core/constants/api_constants.dart';
import '../core/services/api_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ProductProvider extends ChangeNotifier {
  List<ProductModel>   _products   = [];
  List<CategoryModel>  _categories = [];
  List<ProductModel>   _filtered   = [];

  bool    _isLoading    = false;
  String? _errorMessage;
  String  _searchQuery  = '';
  int?    _selectedCategoryId;

  List<ProductModel>  get products   => _filtered;
  List<CategoryModel> get categories => _categories;
  bool                get isLoading  => _isLoading;
  String?             get errorMessage => _errorMessage;

  // ── Ambil semua produk dari API ───────────────────────
  Future<void> fetchProducts() async {
    _isLoading    = true;
    _errorMessage = null;
    notifyListeners();

    final result = await ApiService.get(ApiConstants.posItems);

    if (result['success'] == true) {
      final raw = result['data'];
      // Pagination response: data ada di raw['data'], atau langsung list
      final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
      _products = list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _applyFilter();
    } else {
      _errorMessage = result['message'] as String? ?? 'Gagal memuat produk';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Ambil semua kategori ──────────────────────────────
  Future<void> fetchCategories() async {
    final result = await ApiService.get(ApiConstants.categories);
    if (result['success'] == true) {
      final raw  = result['data'];
      final list = (raw is Map ? raw['data'] : raw) as List<dynamic>? ?? [];
      _categories = list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  // ── Filter berdasarkan search & kategori ──────────────
  void setSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilter();
  }

  void setCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    _applyFilter();
  }

  void _applyFilter() {
    _filtered = _products.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery);
      final matchesCategory = _selectedCategoryId == null ||
          p.categoryId == _selectedCategoryId;
      return matchesSearch && matchesCategory;
    }).toList();
    notifyListeners();
  }

  // ── Tambah produk baru ────────────────────────────────
  Future<String?> addProduct(Map<String, dynamic> data) async {
    final result = await ApiService.post(ApiConstants.products, data);
    if (result['success'] == true) {
      await fetchProducts();
      return null; // null = sukses
    }
    return result['message'] as String? ?? 'Gagal menambah produk';
  }

  // ── Update produk ─────────────────────────────────────
  Future<String?> updateProduct(int id, Map<String, dynamic> data) async {
    final result = await ApiService.put(ApiConstants.productDetail(id), data);
    if (result['success'] == true) {
      await fetchProducts();
      return null;
    }
    return result['message'] as String? ?? 'Gagal memperbarui produk';
  }

  // ── Hapus produk ──────────────────────────────────────
  Future<String?> deleteProduct(int id) async {
    final result = await ApiService.delete(ApiConstants.productDetail(id));
    if (result['success'] == true) {
      _products.removeWhere((p) => p.id == id);
      _applyFilter();
      return null;
    }
    return result['message'] as String? ?? 'Gagal menghapus produk';
  }
}
