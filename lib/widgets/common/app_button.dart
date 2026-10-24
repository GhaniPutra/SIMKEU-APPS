import 'package:flutter/material.dart';

import '../kasir/kasir_ui.dart';
import '../../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color color;
  final Color textColor;
  final IconData? icon;
  final double width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.color = AppColors.primary,
    this.textColor = Colors.white,
    this.icon,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: NavyButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        outlined: color != AppColors.primary && color != AppColors.navy,
      ),
    );
  }
}
