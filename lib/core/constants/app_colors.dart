import 'package:flutter/material.dart';

/// Palet SIMKEU Kasir — navy gelap, permukaan putih, aksen hijau lunas.
class AppColors {
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F4F8);
  static const Color surfaceLight = Color(0xFFF1F4F8);

  static const Color navy = Color(0xFF1A2B45);
  static const Color navyDeep = Color(0xFF122033);
  static const Color navyMid = Color(0xFF243656);
  static const Color navySoft = Color(0xFFE8EEF6);

  static const Color primary = navy;
  static const Color primaryLight = Color(0xFF3A4F70);
  static const Color primaryDark = navyDeep;
  static const Color secondary = Color(0xFF2F9E6A);
  static const Color secondaryDark = Color(0xFF217A50);

  static const Color success = Color(0xFF22C55E);
  static const Color successSoft = Color(0xFFE8F8EE);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  static const Color textPrimary = Color(0xFF1A2B45);
  static const Color textSecondary = Color(0xFF7B8498);
  static const Color textHint = Color(0xFFA8B0C0);
  static const Color onNavy = Color(0xFFF4F7FB);

  static const Color border = Color(0xFFE6EAF1);
  static const Color divider = Color(0xFFEEF1F6);

  static const Color pastelIndigo = Color(0xFFE8EEF6);
  static const Color pastelTeal = Color(0xFFE8F8EE);
  static const Color pastelOrange = Color(0xFFFFF4E5);
  static const Color pastelPink = Color(0xFFFFEEF4);
  static const Color pastelBlue = Color(0xFFEEF4FF);
  static const Color pastelGreen = Color(0xFFE8F8EE);
  static const Color pastelRed = Color(0xFFFEECEC);
  static const Color pastelYellow = Color(0xFFFFF8E8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [navy, navyMid],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF2F9E6A), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFFF7FAFD), Color(0xFFEAF0F8), Color(0xFFF8FBFE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: navy.withValues(alpha: 0.05),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: navy.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
}
