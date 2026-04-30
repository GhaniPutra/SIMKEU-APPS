// lib/widgets/pos/cart_item_tile.dart
// Baris item di keranjang POS dengan stepper qty

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
      margin  : const EdgeInsets.only(bottom: 10),
      padding : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color        : AppColors.surface,
        borderRadius : BorderRadius.circular(14),
        border       : Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Ikon
          Container(
            padding    : const EdgeInsets.all(10),
            decoration : BoxDecoration(
              color        : AppColors.primary.withOpacity(0.12),
              borderRadius : BorderRadius.circular(10),
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
          Row(
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
          const SizedBox(width: 10),
          // Subtotal
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(item.subtotal),
                style: GoogleFonts.poppins(
                  color      : AppColors.secondary,
                  fontSize   : 12,
                  fontWeight : FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap : onRemove,
                child : const Icon(
                  Icons.delete_outline,
                  color : AppColors.error,
                  size  : 18,
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
        padding    : const EdgeInsets.all(4),
        decoration : BoxDecoration(
          color        : color.withOpacity(0.15),
          borderRadius : BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}
