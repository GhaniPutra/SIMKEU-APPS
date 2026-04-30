// lib/providers/auth_provider.dart
// State management untuk autentikasi pengguna

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

  // ── Cek sesi saat app dibuka ──────────────────────────
  Future<void> checkSession() async {
    _isLoggedIn = await AuthService.isLoggedIn();
    if (_isLoggedIn) {
      final saved = await AuthService.getSavedUser();
      _currentUser = UserModel(
        id    : int.tryParse(saved['id'] ?? '0') ?? 0,
        name  : saved['name'] ?? 'Pegawai',
        email : saved['email'] ?? '',
      );
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _isLoading     = true;
    _errorMessage  = null;
    notifyListeners();

    final result = await AuthService.login(email.trim(), password);

    _isLoading = false;

    if (result['success'] == true) {
      _isLoggedIn = true;
      final user = result['data']?['user'] as Map<String, dynamic>?;
      if (user != null) {
        _currentUser = UserModel.fromJson(user);
      }
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'] as String? ?? 'Login gagal';
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
