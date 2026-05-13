// lib/core/constants/app_colors.dart
// Palet warna premium LIGHT mode untuk aplikasi SIMKEU POS
// Soft white background dengan aksen colorful yang vibrant

import 'package:flutter/material.dart';

class AppColors {
  // ── Background ────────────────────────────────────────
  static const Color background     = Color(0xFFF7F8FC); // Putih kebiruan soft
  static const Color surface        = Color(0xFFFFFFFF); // Card putih bersih
  static const Color surfaceLight   = Color(0xFFF2F3F8); // Input field bg

  // ── Accent / Primary ──────────────────────────────────
  static const Color primary        = Color(0xFF5B5FE7); // Indigo cerah
  static const Color primaryLight   = Color(0xFF8184F0);
  static const Color primaryDark    = Color(0xFF4346C7);

  // ── Secondary / Teal ──────────────────────────────────
  static const Color secondary      = Color(0xFF00C9A7); // Mint teal
  static const Color secondaryDark  = Color(0xFF00A88B);

  // ── Status ────────────────────────────────────────────
  static const Color success        = Color(0xFF22C55E); // Hijau cerah
  static const Color warning        = Color(0xFFF59E0B); // Amber warm
  static const Color error          = Color(0xFFEF4444); // Merah clean
  static const Color info           = Color(0xFF3B82F6); // Biru info

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF1A1D3B); // Dark navy
  static const Color textSecondary  = Color(0xFF6B7299); // Medium grey
  static const Color textHint       = Color(0xFFA0A5C0); // Light grey

  // ── Border / Divider ──────────────────────────────────
  static const Color border         = Color(0xFFE8EAF0); // Border tipis
  static const Color divider        = Color(0xFFF0F1F5); // Divider halus

  // ── Gradient POS card ─────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF7F8FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Gradient tambahan untuk variasi warna ─────────────
  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Pastel backgrounds untuk ikon ─────────────────────
  static const Color pastelIndigo   = Color(0xFFEEF0FF);
  static const Color pastelTeal     = Color(0xFFE6FBF5);
  static const Color pastelOrange   = Color(0xFFFFF3E6);
  static const Color pastelPink     = Color(0xFFFFF0F6);
  static const Color pastelBlue     = Color(0xFFEFF6FF);
  static const Color pastelGreen    = Color(0xFFECFDF5);
  static const Color pastelRed      = Color(0xFFFEF2F2);
  static const Color pastelYellow   = Color(0xFFFFFBEB);
}
