// lib/core/services/api_service.dart
// HTTP client wrapper untuk semua request ke API SIMKEU
// Otomatis menyisipkan token Bearer dari SharedPreferences

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Waktu timeout request (detik)
  static const int _timeoutSeconds = 30;

  // ── Ambil token dari storage ───────────────────────────
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ── Header standar dengan Bearer token ───────────────
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (withAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ── Parsing response dengan HTTP status handling ────────
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      // Handle HTTP status codes
      if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email atau password salah',
          'statusCode': 401,
        };
      } else if (response.statusCode == 422) {
        // Validation error
        final data = json.decode(response.body) as Map<String, dynamic>;
        final errors = data['errors'] as Map<String, dynamic>? ?? {};
        String errorMessage = 'Data tidak valid';
        if (errors.isNotEmpty) {
          final firstKey = errors.keys.first;
          final firstErrorList = errors[firstKey] as List<dynamic>;
          if (firstErrorList.isNotEmpty) {
            errorMessage = firstErrorList.first.toString();
          }
        }
        return {
          'success': false,
          'message': errorMessage,
          'errors': errors,
          'statusCode': 422,
        };
      } else if (response.statusCode == 500) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan pada server',
          'statusCode': 500,
        };
      } else if (response.statusCode != 200 && response.statusCode != 201) {
        return {
          'success': false,
          'message': 'Terjadi kesalahan: ${response.statusCode}',
          'statusCode': response.statusCode,
        };
      }

      // Parse successful response
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } on FormatException {
      return {
        'success': false,
        'message': 'Format respons dari server tidak valid',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ── GET ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? queryParams,
    bool withAuth = true,
  }) async {
    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http
          .get(uri, headers: await _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet (${e.message})',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Waktu koneksi habis. Cek koneksi internet Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ── POST ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: await _headers(withAuth: withAuth),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet (${e.message})',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Waktu koneksi habis. Cek koneksi internet Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ── PUT ───────────────────────────────────────────────
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse(url),
            headers: await _headers(),
            body: json.encode(body),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet (${e.message})',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Waktu koneksi habis. Cek koneksi internet Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  // ── DELETE ────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on SocketException catch (e) {
      return {
        'success': false,
        'message': 'Tidak ada koneksi internet (${e.message})',
      };
    } on TimeoutException {
      return {
        'success': false,
        'message': 'Waktu koneksi habis. Cek koneksi internet Anda.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}
