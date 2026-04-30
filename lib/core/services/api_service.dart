// lib/core/services/api_service.dart
// HTTP client wrapper untuk semua request ke API SIMKEU
// Otomatis menyisipkan token Bearer dari SharedPreferences

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

  // ── Parsing response menjadi Map ──────────────────────
  static Map<String, dynamic> _parseResponse(http.Response response) {
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (_) {
      return {
        'success': false,
        'message': 'Gagal memproses respons dari server',
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
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
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
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
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
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ── DELETE ────────────────────────────────────────────
  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await http
          .delete(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }
}
