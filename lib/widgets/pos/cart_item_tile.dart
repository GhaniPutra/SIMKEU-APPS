// lib/widgets/pos/cart_item_tile.dart
// Baris item di keranjang POS dengan stepper qty — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItem         item;
  final VoidCallback     onIncrease;
  final VoidCallback     onDecrease;
  final VoidCallback     onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin  : const EdgeInsets.only(bottom: 12),
      padding : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color        : AppColors.surface,
        borderRadius : BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color     : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset    : const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ikon
          Container(
            padding    : const EdgeInsets.all(10),
            decoration : BoxDecoration(
              color        : AppColors.pastelIndigo,
              borderRadius : BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Info produk
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: GoogleFonts.poppins(
                    color      : AppColors.textPrimary,
                    fontSize   : 13,
                    fontWeight : FontWeight.w600,
                  ),
                  maxLines : 1,
                  overflow : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  CurrencyFormatter.format(item.product.sellPrice),
                  style: GoogleFonts.poppins(
                    color    : AppColors.textSecondary,
                    fontSize : 12,
                  ),
                ),
              ],
            ),
          ),
          // Stepper qty
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                _QtyButton(
                  icon    : Icons.remove,
                  onTap   : onDecrease,
                  color   : AppColors.error,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.poppins(
                      color      : AppColors.textPrimary,
                      fontSize   : 14,
                      fontWeight : FontWeight.w700,
                    ),
                  ),
                ),
                _QtyButton(
                  icon    : Icons.add,
                  onTap   : onIncrease,
                  color   : AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: GoogleFonts.poppins(
                  color      : AppColors.primary,
                  fontSize   : 12,
                  fontWeight : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap : onRemove,
                child : Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.pastelRed,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    color : AppColors.error,
                    size  : 16,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  final Color        color;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding    : const EdgeInsets.all(6),
        decoration : BoxDecoration(
          color        : color.withOpacity(0.1),
          borderRadius : BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
