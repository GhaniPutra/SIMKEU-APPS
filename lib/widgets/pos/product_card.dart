// lib/widgets/pos/product_card.dart
// Kartu produk untuk grid view di layar POS — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel  product;
  final VoidCallback  onTap;
  final int           cartQty; // qty produk ini di keranjang

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.cartQty = 0,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock == 0;

    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color        : outOfStock
              ? AppColors.surfaceLight.withOpacity(0.7)
              : AppColors.surface,
          borderRadius : BorderRadius.circular(18),
          border       : Border.all(
            color: cartQty > 0 ? AppColors.primary : Colors.transparent,
            width: cartQty > 0 ? 2 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color     : Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset    : const Offset(0, 4),
            ),
            BoxShadow(
              color     : Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset    : const Offset(0, 1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Konten utama
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ikon produk
                  Container(
                    height     : 48,
                    width      : 48,
                    decoration : BoxDecoration(
                      color        : AppColors.pastelIndigo,
                      borderRadius : BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.inventory_2_rounded,
                      color: outOfStock
                          ? AppColors.textHint
                          : AppColors.primary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Nama produk
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      color      : outOfStock
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                      fontSize   : 13,
                      fontWeight : FontWeight.w600,
                    ),
                    maxLines : 2,
                    overflow : TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // Harga
                  Text(
                    CurrencyFormatter.format(product.sellPrice),
                    style: GoogleFonts.poppins(
                      color      : AppColors.primary,
                      fontSize   : 13,
                      fontWeight : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Stok
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: outOfStock ? AppColors.error : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        outOfStock ? 'Habis' : 'Stok: ${product.stock} ${product.unit}',
                        style: GoogleFonts.poppins(
                          color    : outOfStock ? AppColors.error : AppColors.textHint,
                          fontSize : 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Badge qty di keranjang
            if (cartQty > 0)
              Positioned(
                top   : 10,
                right : 10,
                child : Container(
                  padding    : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration : BoxDecoration(
                    gradient     : AppColors.primaryGradient,
                    borderRadius : BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '$cartQty',
                    style: GoogleFonts.poppins(
                      color      : Colors.white,
                      fontSize   : 11,
                      fontWeight : FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
