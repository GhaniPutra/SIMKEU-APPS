// lib/screens/pos/cart_screen.dart
// Layar keranjang — review item, pilih metode bayar, dan checkout

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/pos/cart_item_tile.dart';
import 'receipt_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'tunai';
  final _noteCtrl = TextEditingController();

  final _methods = [
    {'value': 'tunai',    'label': 'Tunai',    'icon': Icons.money},
    {'value': 'transfer', 'label': 'Transfer', 'icon': Icons.account_balance},
    {'value': 'ewallet',  'label': 'E-Wallet', 'icon': Icons.phone_android},
  ];

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    final cart  = context.read<CartProvider>();
    final sales = context.read<SaleProvider>();
    if (cart.isEmpty) return;

    final error = await sales.createSale(
      items         : cart.toApiItems(),
      paymentMethod : _paymentMethod,
      notes         : _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content         : Text(error, style: GoogleFonts.poppins()),
        backgroundColor : AppColors.error,
        behavior        : SnackBarBehavior.floating,
      ));
      return;
    }
    cart.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptScreen(sale: sales.lastSale!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final sales = context.watch<SaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Keranjang',
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: () => _confirmClear(context, cart),
              child: Text('Kosongkan',
                  style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13)),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, color: AppColors.textHint, size: 64),
                  const SizedBox(height: 16),
                  Text('Keranjang kosong',
                      style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 15)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      ...cart.items.map((item) => CartItemTile(
                            item       : item,
                            onIncrease : () => cart.increaseQuantity(item.product.id),
                            onDecrease : () => cart.decreaseQuantity(item.product.id),
                            onRemove   : () => cart.removeItem(item.product.id),
                          )),
                      const SizedBox(height: 20),
                      Text('Metode Pembayaran',
                          style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      Row(
                        children: _methods.map((m) {
                          final isSel = _paymentMethod == m['value'];
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _paymentMethod = m['value'] as String),
                              child: Container(
                                margin  : const EdgeInsets.only(right: 8),
                                padding : const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                decoration: BoxDecoration(
                                  color       : isSel ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border      : Border.all(
                                      color: isSel ? AppColors.primary : AppColors.border,
                                      width: isSel ? 1.5 : 1),
                                ),
                                child: Column(children: [
                                  Icon(m['icon'] as IconData,
                                      color: isSel ? AppColors.primary : AppColors.textHint, size: 22),
                                  const SizedBox(height: 4),
                                  Text(m['label'] as String,
                                      style: GoogleFonts.poppins(
                                          color: isSel ? AppColors.primary : AppColors.textHint,
                                          fontSize: 11, fontWeight: FontWeight.w500)),
                                ]),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      Text('Catatan (opsional)',
                          style: GoogleFonts.poppins(
                              color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _noteCtrl,
                        maxLines: 2,
                        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
                        decoration: InputDecoration(
                          hintText : 'Tambahkan catatan...',
                          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                          filled   : true, fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.all(14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color : AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: Column(children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('Total (${cart.itemCount} item)',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
                      Text(CurrencyFormatter.format(cart.total),
                          style: GoogleFonts.poppins(
                              color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 14),
                    AppButton(
                      label: 'Bayar Sekarang',
                      icon : Icons.payment_rounded,
                      isLoading: sales.isLoading,
                      onPressed: _checkout,
                    ),
                  ]),
                ),
              ],
            ),
    );
  }

  void _confirmClear(BuildContext ctx, CartProvider cart) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title  : Text('Kosongkan Keranjang?',
            style: GoogleFonts.poppins(color: AppColors.textPrimary)),
        content: Text('Semua item akan dihapus.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () { cart.clearCart(); Navigator.pop(ctx); Navigator.pop(ctx); },
            child: Text('Kosongkan', style: GoogleFonts.poppins(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
