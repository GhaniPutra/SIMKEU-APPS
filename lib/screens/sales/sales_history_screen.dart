import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sale_model.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/kasir/kasir_ui.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});
  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchCtrl = TextEditingController();
  int _range = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.read<SaleProvider>().fetchSales());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SaleModel> _filtered(List<SaleModel> sales) {
    final now = DateTime.now();
    DateTime? since;
    if (_range == 1) {
      since = DateTime(now.year, now.month, now.day);
    } else if (_range == 2) {
      since = now.subtract(const Duration(days: 7));
    } else if (_range == 3) {
      since = now.subtract(const Duration(days: 30));
    }
    final q = _searchCtrl.text.trim().toLowerCase();
    return sales.where((s) {
      if (q.isNotEmpty && !s.invoiceNumber.toLowerCase().contains(q)) {
        return false;
      }
      if (since == null) return true;
      try {
        return DateTime.parse(s.createdAt).toLocal().isAfter(since);
      } catch (_) {
        return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final saleProv = context.watch<SaleProvider>();
    final items = _filtered(saleProv.sales);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Riwayat Transaksi',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: CategoryChips(
              labels: const ['Semua', 'Hari Ini', '7 Hari', '30 Hari'],
              selectedIndex: _range,
              onSelected: (i) => setState(() => _range = i),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: KasirSearchField(
              controller: _searchCtrl,
              hint: 'Cari nomor transaksi...',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: saleProv.isLoading
                ? const LoadingWidget()
                : saleProv.errorMessage != null
                    ? AppErrorWidget(
                        message: saleProv.errorMessage!,
                        onRetry: () => saleProv.fetchSales())
                    : items.isEmpty
                        ? Center(
                            child: Text('Tidak ada transaksi',
                                style: GoogleFonts.inter(
                                    color: AppColors.textHint)))
                        : RefreshIndicator(
                            color: AppColors.navy,
                            onRefresh: () => saleProv.fetchSales(),
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                              itemCount: items.length,
                              itemBuilder: (_, i) =>
                                  _HistoryRow(sale: items[i]),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final SaleModel sale;
  const _HistoryRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final invoice = sale.invoiceNumber.startsWith('#')
        ? sale.invoiceNumber
        : '#${sale.invoiceNumber}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  _formatDate(sale.createdAt),
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.textHint),
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
                    fontWeight: FontWeight.w700, fontSize: 13),
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
      return DateFormat('dd MMM yyyy • HH:mm')
          .format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}
