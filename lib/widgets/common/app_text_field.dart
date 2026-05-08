// lib/widgets/common/app_text_field.dart
// Input field reusable dengan styling dark mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String         label;
  final String?        hint;
  final TextEditingController controller;
  final bool           obscureText;
  final TextInputType  keyboardType;
  final IconData?      prefixIcon;
  final String?        Function(String?)? validator;
  final int            maxLines;
  final bool           enabled;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.obscureText    = false,
    this.keyboardType   = TextInputType.text,
    this.prefixIcon,
    this.validator,
    this.maxLines       = 1,
    this.enabled        = true,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller   : widget.controller,
          obscureText  : widget.obscureText && !_showPassword,
          keyboardType : widget.keyboardType,
          maxLines     : widget.obscureText ? 1 : widget.maxLines,
          enabled      : widget.enabled,
          validator    : widget.validator,
          onChanged    : widget.onChanged,
          style: GoogleFonts.poppins(
            color    : AppColors.textPrimary,
            fontSize : 14,
          ),
          decoration: InputDecoration(
            hintText : widget.hint,
            hintStyle: GoogleFonts.poppins(
              color    : AppColors.textHint,
              fontSize : 14,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.textHint, size: 20)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _showPassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  )
                : null,
            filled      : true,
            fillColor   : AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: AppColors.border, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
