// lib/widgets/dashboard/stat_card.dart
// Kartu statistik KPI untuk dashboard — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class StatCard extends StatelessWidget {
  final String    title;
  final String    value;
  final IconData  icon;
  final Color     iconColor;
  final Color     iconBg;
  final String?   subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBg    = AppColors.pastelIndigo,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color        : AppColors.surface,
        borderRadius : BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color  : Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset : const Offset(0, 4),
          ),
          BoxShadow(
            color  : Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset : const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ikon
          Container(
            padding     : const EdgeInsets.all(10),
            decoration  : BoxDecoration(
              color        : iconBg,
              borderRadius : BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          // Nilai
          Text(
            value,
            style: GoogleFonts.poppins(
              color      : AppColors.textPrimary,
              fontSize   : 20,
              fontWeight : FontWeight.w700,
            ),
            maxLines  : 1,
            overflow  : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          // Judul
          Text(
            title,
            style: GoogleFonts.poppins(
              color    : AppColors.textSecondary,
              fontSize : 12,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: GoogleFonts.poppins(
                color    : AppColors.success,
                fontSize : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
