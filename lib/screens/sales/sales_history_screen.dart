// lib/screens/sales/sales_history_screen.dart
// Riwayat penjualan — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});
  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final _searchCtrl = TextEditingController();
  String? _filterMetode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<SaleProvider>().fetchSales());
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  void _applyFilter() {
    context.read<SaleProvider>().fetchSales(
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      metode: _filterMetode,
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(DateTime.parse(raw).toLocal());
    } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    final saleProv = context.watch<SaleProvider>();

    return SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Riwayat Penjualan', style: GoogleFonts.poppins(
              color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            Text('Semua transaksi yang telah dilakukan', style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 12)),
          ])),
        ])),
      const SizedBox(height: 16),

      // Search
      Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          controller: _searchCtrl, onSubmitted: (_) => _applyFilter(),
          style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Cari invoice...', hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: AppColors.textHint),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary, size: 20),
              onPressed: _applyFilter),
            filled: true, fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        )),
      const SizedBox(height: 12),

      // Filter Metode
      SizedBox(height: 40, child: ListView(
        scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 20),
        children: ['Semua', 'tunai', 'transfer', 'ewallet'].map((m) {
          final isSel = (m == 'Semua' && _filterMetode == null) || _filterMetode == m;
          return GestureDetector(
            onTap: () { setState(() => _filterMetode = m == 'Semua' ? null : m); _applyFilter(); },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSel ? AppColors.primary : AppColors.border),
                boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 6)] : null,
              ),
              child: Text(m[0].toUpperCase() + m.substring(1), style: GoogleFonts.poppins(
                color: isSel ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          );
        }).toList(),
      )),
      const SizedBox(height: 8),

      // List
      Expanded(
        child: saleProv.isLoading ? const LoadingWidget()
          : saleProv.errorMessage != null
            ? AppErrorWidget(message: saleProv.errorMessage!, onRetry: () => saleProv.fetchSales())
            : saleProv.sales.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
                    child: const Icon(Icons.receipt_long_outlined, color: AppColors.textHint, size: 40)),
                  const SizedBox(height: 12),
                  Text('Tidak ada transaksi ditemukan', style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13)),
                ]))
              : RefreshIndicator(
                  color: AppColors.primary, backgroundColor: AppColors.surface,
                  onRefresh: () => saleProv.fetchSales(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: saleProv.sales.length,
                    itemBuilder: (_, i) => _SaleTile(sale: saleProv.sales[i], formatDate: _formatDate),
                  )),
      ),
    ]));
  }
}

class _SaleTile extends StatelessWidget {
  final SaleModel sale;
  final String Function(String) formatDate;
  const _SaleTile({required this.sale, required this.formatDate});

  Color get _methodColor {
    switch (sale.paymentMethod.toLowerCase()) {
      case 'transfer': return AppColors.info;
      case 'ewallet':  return AppColors.warning;
      default:         return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.pastelTeal, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.receipt_long_rounded, color: AppColors.secondary, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sale.invoiceNumber, style: GoogleFonts.poppins(
            color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(formatDate(sale.createdAt), style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 11)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: _methodColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(sale.paymentMethod.toUpperCase(), style: GoogleFonts.poppins(
              color: _methodColor, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
        ])),
        Text(CurrencyFormatter.format(sale.totalAmount), style: GoogleFonts.poppins(
          color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
