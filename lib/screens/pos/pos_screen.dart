import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../../widgets/pos/product_card.dart';
import '../stock/stock_allocation_screen.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

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
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProv = context.watch<ProductProvider>();
    final cartProv = context.watch<CartProvider>();
    final labels = ['Semua', ...productProv.categories.map((c) => c.name)];
    final selectedIndex = productProv.selectedCategoryId == null
        ? 0
        : productProv.categories
                .indexWhere((c) => c.id == productProv.selectedCategoryId) +
            1;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Produk',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Alokasi stok',
                  child: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StockAllocationScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.inventory_2_outlined),
                  ),
                ),
                Badge(
                  isLabelVisible: cartProv.itemCount > 0,
                  label: Text('${cartProv.itemCount}'),
                  child: IconButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    ),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: KasirSearchField(
              controller: _searchCtrl,
              hint: 'Cari produk...',
              onChanged: productProv.setSearch,
            ),
          ),
          if (labels.length > 1)
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 8),
              child: CategoryChips(
                labels: labels,
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                onSelected: (i) {
                  if (i == 0) {
                    productProv.setCategory(null);
                  } else {
                    productProv.setCategory(productProv.categories[i - 1].id);
                  }
                },
              ),
            ),
          Expanded(
            child: productProv.isLoading
                ? const LoadingWidget(message: 'Memuat produk...')
                : productProv.errorMessage != null
                    ? AppErrorWidget(
                        message: productProv.errorMessage!,
                        onRetry: () {
                          productProv.fetchProducts();
                          productProv.fetchCategories();
                        },
                      )
                    : productProv.products.isEmpty
                        ? Center(
                            child: Text('Produk tidak ditemukan',
                                style: GoogleFonts.inter(
                                    color: AppColors.textHint)))
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.82,
                            ),
                            itemCount: productProv.products.length,
                            itemBuilder: (_, i) {
                              final product = productProv.products[i];
                              return ProductCard(
                                product: product,
                                cartQty: cartProv.quantityOf(product.id),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ProductDetailScreen(product: product),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
