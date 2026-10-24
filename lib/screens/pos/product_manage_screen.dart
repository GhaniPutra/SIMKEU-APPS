import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/product_provider.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/kasir/kasir_ui.dart';
import 'product_detail_screen.dart';

class ProductManageScreen extends StatefulWidget {
  const ProductManageScreen({super.key});

  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen> {
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
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final labels = ['Semua', ...provider.categories.map((c) => c.name)];
    final selectedIndex = provider.selectedCategoryId == null
        ? 0
        : provider.categories
                .indexWhere((c) => c.id == provider.selectedCategoryId) +
            1;

    return Scaffold(
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Kelola Produk'),
      ),
      body: Column(
        children: [
          if (labels.length > 1)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 0, 8),
              child: CategoryChips(
                labels: labels,
                selectedIndex: selectedIndex < 0 ? 0 : selectedIndex,
                onSelected: (i) {
                  if (i == 0) {
                    provider.setCategory(null);
                  } else {
                    provider.setCategory(provider.categories[i - 1].id);
                  }
                },
              ),
            ),
          Expanded(
            child: provider.isLoading
                ? const LoadingWidget()
                : provider.errorMessage != null
                    ? AppErrorWidget(
                        message: provider.errorMessage!,
                        onRetry: provider.fetchProducts)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: provider.products.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final p = provider.products[i];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(product: p),
                              ),
                            ),
                            leading:
                                ProductThumb(product: p, size: 48, radius: 12),
                            title: Text(p.name,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              CurrencyFormatter.format(p.sellPrice),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                            trailing: Text(
                              'Stok ${p.stock}',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
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
