// lib/providers/auth_provider.dart
// State management untuk autentikasi pengguna

import 'dart:async';

import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  // Status loading saat proses login
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Pesan error dari API
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Status login
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  // Data user yang sedang login
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool _isRefreshingUser = false;

  // ── Cek sesi saat app dibuka ──────────────────────────
  Future<void> checkSession() async {
    _isLoggedIn = await AuthService.isLoggedIn();
    if (_isLoggedIn) {
      final saved = await AuthService.getSavedUser();
      _currentUser = UserModel(
        id    : int.tryParse(saved['id'] ?? '0') ?? 0,
        name  : saved['name'] ?? 'Pegawai',
        email : saved['email'] ?? '',
        storeId: int.tryParse(saved['store_id'] ?? '0') ?? 0,
        role: saved['role'] ?? '',
        permissions: (saved['permissions'] ?? '')
            .split(',')
            .where((permission) => permission.isNotEmpty)
            .toList(),
      );
    }
    notifyListeners();
    if (_isLoggedIn && (_currentUser?.storeId ?? 0) == 0) {
      unawaited(refreshCurrentUser());
    }
  }

  Future<void> refreshCurrentUser() async {
    if (_isRefreshingUser) return;
    _isRefreshingUser = true;
    try {
      final user = await AuthService.refreshSavedUser();
      if (user != null) {
        _currentUser = UserModel.fromJson(user);
        notifyListeners();
      }
    } catch (error) {
      debugPrint('Unable to refresh the saved user profile: $error');
    } finally {
      _isRefreshingUser = false;
    }
  }

  // ── Login ─────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading     = true;
    _errorMessage  = null;  // Clear error sebelum attempt login
    notifyListeners();

    // Validasi input dasar
    if (email.isEmpty || password.isEmpty) {
      _isLoading = false;
      _errorMessage = 'Email dan password harus diisi';
      notifyListeners();
      return false;
    }

    final result = await AuthService.login(email.trim(), password);

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      _errorMessage = null;
      final user = result['data']?['user'] as Map<String, dynamic>?;
      if (user != null) {
        _currentUser = UserModel.fromJson(user);
      }
      notifyListeners();
      return true;
    } else {
      // Handle berbagai jenis error dari API
      final message = result['message'] as String?;
      final statusCode = result['statusCode'] as int?;
      
      if (statusCode == 401) {
        _errorMessage = 'Email atau password salah';
      } else if (statusCode == 422) {
        _errorMessage = 'Data tidak valid. Periksa kembali email & password Anda';
      } else if (statusCode == 500) {
        _errorMessage = 'Server sedang bermasalah. Coba lagi nanti';
      } else if (message != null && message.contains('koneksi')) {
        _errorMessage = 'Tidak ada koneksi internet. Periksa WiFi atau mobile data Anda';
      } else if (message != null && message.contains('timeout')) {
        _errorMessage = 'Koneksi terlalu lambat. Coba lagi';
      } else {
        _errorMessage = message ?? 'Login gagal. Coba lagi';
      }
      notifyListeners();
      return false;
    }
  }

  // ── Logout ────────────────────────────────────────────
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn  = false;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Reset error ───────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
