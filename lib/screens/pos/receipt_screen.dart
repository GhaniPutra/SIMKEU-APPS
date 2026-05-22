// lib/screens/pos/receipt_screen.dart
// Layar struk digital — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sale_model.dart';
import '../../widgets/common/app_button.dart';
import '../dashboard/dashboard_screen.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleModel sale;
  const ReceiptScreen({super.key, required this.sale});

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
    } catch (_) { return raw; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Column(children: [
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 16),
            // Ikon sukses
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.pastelGreen, shape: BoxShape.circle,
                border: Border.all(color: AppColors.success, width: 2)),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 48)),
            const SizedBox(height: 16),
            Text('Transaksi Berhasil!', style: GoogleFonts.poppins(
              color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Pembayaran telah dikonfirmasi', style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 28),

            // Struk
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))]),
              child: Column(children: [
                Text('SIMKEU POS', style: GoogleFonts.poppins(
                  color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w800)),
                Text('Struk Pembelian', style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                _ReceiptRow(label: 'No. Invoice', value: sale.invoiceNumber),
                _ReceiptRow(label: 'Tanggal', value: _formatDate(sale.createdAt)),
                _ReceiptRow(label: 'Metode Bayar', value: sale.paymentMethod.toUpperCase()),
                if (sale.notes != null && sale.notes!.isNotEmpty)
                  _ReceiptRow(label: 'Catatan', value: sale.notes!),
                const SizedBox(height: 8),
                const Divider(color: AppColors.border),
                const SizedBox(height: 8),
                if (sale.items.isNotEmpty) ...[
                  Align(alignment: Alignment.centerLeft,
                    child: Text('Barang Terjual', style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600))),
                  const SizedBox(height: 10),
                  ...sale.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(
                          child: Text(item.productName,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Text('x${item.quantity}',
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
                      ]),
                      const SizedBox(height: 4),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(CurrencyFormatter.format(item.price),
                          style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11)),
                        Text(CurrencyFormatter.format(item.subtotal),
                          style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ]))),
                  const Divider(color: AppColors.border),
                ],
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('TOTAL', style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(CurrencyFormatter.format(sale.totalAmount), style: GoogleFonts.poppins(
                    color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 12),
                Text('Terima kasih! 🙏', style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12)),
              ]),
            ),
          ]),
        )),

        // Tombol Aksi
        Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          AppButton(label: 'Transaksi Baru', icon: Icons.add_shopping_cart_rounded,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false)),
          const SizedBox(height: 10),
          AppButton(label: 'Kembali ke Dashboard', icon: Icons.dashboard_rounded,
            color: AppColors.surfaceLight, textColor: AppColors.textPrimary,
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const DashboardScreen()), (_) => false)),
        ])),
      ])),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label; final String value;
  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(bottom: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12)),
        Text(value, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
      ]));
  }
}
