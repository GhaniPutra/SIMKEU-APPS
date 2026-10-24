import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sale_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../pos/cart_screen.dart';
import '../stock/stock_allocation_screen.dart';

class HomeScreen extends StatelessWidget {
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenProducts;
  final VoidCallback onOpenTransactions;

  const HomeScreen({
    super.key,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenProducts,
    required this.onOpenTransactions,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sales = context.watch<SaleProvider>();
    final name = auth.currentUser?.name ?? 'Kasir';
    final soldCount = sales.sales.fold<int>(
      0,
      (sum, sale) =>
          sum + sale.items.fold<int>(0, (s, item) => s + item.quantity),
    );

    String? changeLabel;
    if (sales.revenueTrend.length >= 2) {
      final prev = sales.revenueTrend[sales.revenueTrend.length - 2];
      final curr = sales.revenueTrend.last;
      if (prev > 0) {
        final pct = ((curr - prev) / prev) * 100;
        final sign = pct >= 0 ? '+' : '';
        changeLabel = '$sign${pct.toStringAsFixed(0)}% dari kemarin';
      }
    }

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.navy,
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${name.split(' ').first}',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Selamat datang di SIMKEU Kasir',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _roundIcon(Icons.notifications_none_rounded, () {}),
              ],
            ),
            const SizedBox(height: 20),
            SoftCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Penjualan Hari Ini',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          CurrencyFormatter.format(sales.todayTotal),
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.6,
                          ),
                        ),
                        if (changeLabel != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            changeLabel,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.successSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.trending_up_rounded,
                        color: AppColors.success),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _miniStat('Transaksi', '${sales.todayCount}'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat('Produk Terjual', '$soldCount'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _miniStat(
                    'Kembalian',
                    CurrencyFormatter.formatShort(0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: NavyButton(
                    label: 'Alokasi Stok',
                    icon: Icons.inventory_2_outlined,
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const StockAllocationScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NavyButton(
                    label: 'Pilih Produk',
                    icon: Icons.grid_view_rounded,
                    outlined: true,
                    onPressed: onOpenProducts,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(
                  'Transaksi Terakhir',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onOpenTransactions,
                  child: Text(
                    'Lihat Semua',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            if (isRefreshing && sales.sales.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (sales.sales.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Belum ada transaksi hari ini.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
              )
            else
              ...sales.sales.take(5).map((sale) => _SaleRow(sale: sale)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
              child: Text(
                'Buka keranjang aktif',
                style: GoogleFonts.inter(
                  color: AppColors.navy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.softShadow,
        ),
        child: Icon(icon, color: AppColors.navy, size: 20),
      ),
    );
  }
}

class _SaleRow extends StatelessWidget {
  final SaleModel sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale.invoiceNumber.startsWith('#')
                      ? sale.invoiceNumber
                      : '#${sale.invoiceNumber}',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(sale.createdAt),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(sale.totalAmount),
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const LunasBadge(),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy • HH:mm').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}
