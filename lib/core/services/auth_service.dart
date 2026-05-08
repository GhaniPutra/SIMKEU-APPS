// lib/core/services/auth_service.dart
// Mengelola login, logout, dan penyimpanan token auth

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class AuthService {
  // Key untuk SharedPreferences
  static const String _tokenKey   = 'auth_token';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userIdKey  = 'user_id';

  // ── Login ─────────────────────────────────────────────
  // Mengirim email & password, menyimpan token jika berhasil
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    // Validasi input
    if (email.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Email dan password tidak boleh kosong',
      };
    }

    final result = await ApiService.post(
      ApiConstants.login,
      {'email': email, 'password': password},
      withAuth: false,
    );

    if (result['success'] == true) {
      try {
        final data = result['data'] as Map<String, dynamic>?;
        
        if (data == null) {
          return {
            'success': false,
            'message': 'Format respons dari server tidak valid',
          };
        }

        final token = data['token'] as String?;
        final user  = data['user']  as Map<String, dynamic>?;

        // Validasi token
        if (token == null || token.isEmpty) {
          return {
            'success': false,
            'message': 'Token tidak diterima dari server',
          };
        }

        // Validasi user data
        if (user == null) {
          return {
            'success': false,
            'message': 'Data user tidak diterima dari server',
          };
        }

        // Simpan session
        await _saveSession(
          token: token,
          userId: user['id']?.toString() ?? '',
          userName: user['name']?.toString() ?? 'Pegawai',
          userEmail: user['email']?.toString() ?? '',
        );

        return result;
      } catch (e) {
        return {
          'success': false,
          'message': 'Error memproses respons login: ${e.toString()}',
        };
      }
    }

    return result;
  }

  // ── Logout ────────────────────────────────────────────
  static Future<void> logout() async {
    // Beritahu server untuk revoke token
    try {
      await ApiService.post(ApiConstants.logout, {});
    } catch (_) {
      // Lanjut hapus lokal meskipun server error
    }
    await _clearSession();
  }

  // ── Cek apakah sudah login ────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Ambil data user yang tersimpan ───────────────────
  static Future<Map<String, String>> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id'    : prefs.getString(_userIdKey)    ?? '',
      'name'  : prefs.getString(_userNameKey)  ?? 'Pegawai',
      'email' : prefs.getString(_userEmailKey) ?? '',
    };
  }

  // ── Simpan sesi login ─────────────────────────────────
  static Future<void> _saveSession({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey,    token);
    await prefs.setString(_userIdKey,   userId);
    await prefs.setString(_userNameKey, userName);
    await prefs.setString(_userEmailKey, userEmail);
  }

  // ── Hapus sesi login ──────────────────────────────────
  static Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
