// lib/screens/pos/pos_screen.dart
// Layar POS utama — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/product_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/pos/product_card.dart';
import 'cart_screen.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});
  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<ProductProvider>();
      p.fetchProducts();
      p.fetchCategories();
    });
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cartProv    = context.watch<CartProvider>();

    return SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Point of Sale', style: GoogleFonts.poppins(
              color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            Text('Pilih produk untuk ditambahkan', style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 12)),
          ])),
          GestureDetector(
            onTap: cartProv.isEmpty ? null : () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cartProv.isEmpty ? AppColors.surfaceLight : AppColors.pastelIndigo,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cartProv.isEmpty ? AppColors.border : AppColors.primary.withOpacity(0.3)),
              ),
              child: Stack(clipBehavior: Clip.none, children: [
                Icon(Icons.shopping_cart_rounded,
                  color: cartProv.isEmpty ? AppColors.textHint : AppColors.primary, size: 24),
                if (cartProv.itemCount > 0)
                  Positioned(top: -8, right: -8, child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 4)]),
                    child: Text('${cartProv.itemCount}', style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                  )),
              ]),
            ),
          ),
        ]),
      ),

      // Search Bar
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => productProv.setSearch(v),
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari produk...', hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, color: AppColors.textHint),
                  onPressed: () { _searchCtrl.clear(); productProv.setSearch(''); })
              : null,
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ),

      // Filter Kategori
      if (productProv.categories.isNotEmpty)
        SizedBox(height: 44, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: productProv.categories.length + 1,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            if (i == 0) return _CategoryChip(label: 'Semua', isSelected: true,
              onTap: () => productProv.setCategory(null));
            final cat = productProv.categories[i - 1];
            return _CategoryChip(label: cat.name, isSelected: false,
              onTap: () => productProv.setCategory(cat.id));
          },
        )),
      const SizedBox(height: 8),

      // Grid Produk
      Expanded(
        child: productProv.isLoading
          ? const LoadingWidget(message: 'Memuat produk...')
          : productProv.errorMessage != null
            ? AppErrorWidget(message: productProv.errorMessage!,
                onRetry: () { productProv.fetchProducts(); productProv.fetchCategories(); })
            : productProv.products.isEmpty
              ? Center(child: Text('Produk tidak ditemukan',
                  style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13)))
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.78),
                  itemCount: productProv.products.length,
                  itemBuilder: (_, i) {
                    final product = productProv.products[i];
                    final cartItem = cartProv.items.where((c) => c.product.id == product.id).toList();
                    final qty = cartItem.isEmpty ? 0 : cartItem.first.quantity;
                    return ProductCard(product: product, cartQty: qty, onTap: () {
                      cartProv.addProduct(product);
                      ScaffoldMessenger.of(context)..clearSnackBars()..showSnackBar(SnackBar(
                        content: Text('${product.name} ditambahkan', style: GoogleFonts.poppins(fontSize: 13, color: Colors.white)),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ));
                    });
                  }),
      ),

      // Floating Cart Bar
      if (!cartProv.isEmpty)
        Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 4))],
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(8)),
                  child: Text('${cartProv.itemCount}', style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text('Lihat Keranjang', style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600))),
                Text('Rp ${cartProv.total.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ),
    ]));
  }
}

class _CategoryChip extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
        boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6)] : null,
      ),
      child: Text(label, style: GoogleFonts.poppins(
        color: isSelected ? Colors.white : AppColors.textSecondary,
        fontSize: 12, fontWeight: FontWeight.w500)),
    ));
  }
}
