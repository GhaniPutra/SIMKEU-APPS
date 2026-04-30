// lib/widgets/common/error_widget.dart
// Widget tampilan error dengan tombol retry

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AppErrorWidget extends StatelessWidget {
  final String    message;
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color  : AppColors.error.withOpacity(0.1),
                shape  : BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color : AppColors.error,
                size  : 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: GoogleFonts.poppins(
                color      : AppColors.textPrimary,
                fontSize   : 16,
                fontWeight : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color    : AppColors.textSecondary,
                fontSize : 13,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onRetry,
                icon : const Icon(Icons.refresh, color: AppColors.primary),
                label: Text(
                  'Coba Lagi',
                  style: GoogleFonts.poppins(color: AppColors.primary),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
