// lib/core/services/register_service.dart
// Service untuk registrasi user baru

import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import 'api_service.dart';

class RegisterService {
  // ── Register user baru ────────────────────────────────
  // Mengirim data registrasi & menyimpan token jika berhasil
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Validasi input
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return {
        'success': false,
        'message': 'Nama, email, dan password tidak boleh kosong',
      };
    }

    if (password.length < 6) {
      return {
        'success': false,
        'message': 'Password minimal 6 karakter',
      };
    }

    if (password != passwordConfirmation) {
      return {
        'success': false,
        'message': 'Konfirmasi password tidak sesuai',
      };
    }

    final result = await ApiService.post(
      ApiConstants.register,
      {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
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
          userName: user['name']?.toString() ?? 'User',
          userEmail: user['email']?.toString() ?? '',
        );

        return result;
      } catch (e) {
        return {
          'success': false,
          'message': 'Error memproses respons registrasi: ${e.toString()}',
        };
      }
    }

    return result;
  }

  // ── Simpan sesi registrasi ───────────────────────────
  static Future<void> _saveSession({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token',    token);
    await prefs.setString('user_id',       userId);
    await prefs.setString('user_name',     userName);
    await prefs.setString('user_email',    userEmail);
  }
}
