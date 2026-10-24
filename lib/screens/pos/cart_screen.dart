import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../../widgets/pos/cart_item_tile.dart';
import 'payment_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        title: Column(
          children: [
            Text('Keranjang',
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 18)),
            Text(
              '${cart.itemCount} item',
              style: GoogleFonts.inter(
                  fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: cart.isEmpty
          ? Center(
              child: Text('Keranjang kosong',
                  style: GoogleFonts.inter(color: AppColors.textHint)))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      ...cart.items.map(
                        (item) => CartItemTile(
                          item: item,
                          onIncrease: () => context
                              .read<CartProvider>()
                              .increaseQuantity(item.product.id),
                          onDecrease: () => context
                              .read<CartProvider>()
                              .decreaseQuantity(item.product.id),
                          onRemove: () => context
                              .read<CartProvider>()
                              .removeItem(item.product.id),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                      20, 16, 20, 16 + MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _row('Subtotal', CurrencyFormatter.format(cart.total)),
                      const SizedBox(height: 8),
                      _row('Diskon', CurrencyFormatter.format(0)),
                      const SizedBox(height: 12),
                      _row('Total', CurrencyFormatter.format(cart.total),
                          bold: true),
                      const SizedBox(height: 16),
                      NavyButton(
                        label: 'Bayar  →',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PaymentScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color: bold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: bold ? 16 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
