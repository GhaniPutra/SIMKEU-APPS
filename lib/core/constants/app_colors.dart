// lib/core/constants/app_colors.dart
// Palet warna premium dark mode untuk aplikasi SIMKEU POS

import 'package:flutter/material.dart';

class AppColors {
  // ── Background ────────────────────────────────────────
  static const Color background     = Color(0xFF0F1117); // Hitam kebiruan
  static const Color surface        = Color(0xFF1A1D2E); // Card dark navy
  static const Color surfaceLight   = Color(0xFF252840); // Elevated surface

  // ── Accent / Primary ──────────────────────────────────
  static const Color primary        = Color(0xFF6C63FF); // Indigo violet
  static const Color primaryLight   = Color(0xFF8B85FF);
  static const Color primaryDark    = Color(0xFF4A42CC);

  // ── Secondary / Teal ──────────────────────────────────
  static const Color secondary      = Color(0xFF00D4AA); // Teal mint
  static const Color secondaryDark  = Color(0xFF00A884);

  // ── Status ────────────────────────────────────────────
  static const Color success        = Color(0xFF4CAF82); // Hijau soft
  static const Color warning        = Color(0xFFFFC107); // Kuning amber
  static const Color error          = Color(0xFFFF5252); // Merah soft
  static const Color info           = Color(0xFF42A5F5); // Biru info

  // ── Text ──────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFFF1F1F9);
  static const Color textSecondary  = Color(0xFF9CA3C4);
  static const Color textHint       = Color(0xFF5A6080);

  // ── Border / Divider ──────────────────────────────────
  static const Color border         = Color(0xFF2D3155);
  static const Color divider        = Color(0xFF1E2240);

  // ── Gradient POS card ─────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4A42CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00D4AA), Color(0xFF0097A7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1D2E), Color(0xFF252840)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
