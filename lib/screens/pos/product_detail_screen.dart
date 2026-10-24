import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/custom_toast.dart';
import '../../widgets/kasir/kasir_ui.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  bool _liked = false;

  @override
  void initState() {
    super.initState();
    final existing =
        context.read<CartProvider>().quantityOf(widget.product.id);
    if (existing > 0) _qty = existing;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _liked = !_liked),
            icon: Icon(
              _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: _liked ? AppColors.error : AppColors.textPrimary,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Center(
                  child: ProductThumb(product: p, size: 180, radius: 28),
                ),
                const SizedBox(height: 24),
                Text(
                  p.name,
                  style: GoogleFonts.inter(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.format(p.sellPrice),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Stok Tersedia',
                        style: GoogleFonts.inter(
                            color: AppColors.textSecondary, fontSize: 13)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Stok: ${p.stock}',
                        style: GoogleFonts.inter(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: QtyStepper(
                    value: _qty,
                    onMinus: () {
                      if (_qty > 1) setState(() => _qty--);
                    },
                    onPlus: () {
                      if (_qty < p.stock) setState(() => _qty++);
                    },
                  ),
                ),
                const SizedBox(height: 28),
                NavyButton(
                  label: 'Tambah ke Keranjang',
                  icon: Icons.shopping_bag_outlined,
                  onPressed: p.stock == 0
                      ? null
                      : () {
                          context.read<CartProvider>().addProduct(p, quantity: _qty);
                          CustomToast.showSuccess(
                              context, '${p.name} ditambahkan');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const CartScreen()),
                          );
                        },
                ),
                const SizedBox(height: 24),
                _meta('Kategori', p.categoryName ?? 'Umum', Icons.sell_outlined),
                _meta('Satuan', p.unit, Icons.straighten_outlined),
                _meta('Kode Produk', productSku(p), Icons.qr_code_2_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textHint),
          const SizedBox(width: 12),
          Text(label,
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
