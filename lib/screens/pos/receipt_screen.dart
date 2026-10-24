import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sale_model.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../dashboard/dashboard_screen.dart';

class ReceiptScreen extends StatelessWidget {
  final SaleModel sale;
  const ReceiptScreen({super.key, required this.sale});

  @override
  Widget build(BuildContext context) {
    final invoice = sale.invoiceNumber.startsWith('#')
        ? sale.invoiceNumber
        : '#${sale.invoiceNumber}';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.successSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.success, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                'Pembayaran Berhasil!',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                invoice,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),
              _row('Total Belanja', CurrencyFormatter.format(sale.totalAmount)),
              const SizedBox(height: 12),
              _row('Bayar', CurrencyFormatter.format(sale.totalAmount),
                  valueColor: AppColors.success),
              const SizedBox(height: 12),
              _row('Kembalian', CurrencyFormatter.format(0)),
              const Spacer(),
              NavyButton(
                label: 'Cetak Struk',
                icon: Icons.print_outlined,
                outlined: true,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Struk $invoice • ${_formatDate(sale.createdAt)}',
                        style: GoogleFonts.inter(),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              NavyButton(
                label: 'Selesai',
                onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                  (_) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(label,
            style: GoogleFonts.inter(
                color: AppColors.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw;
    }
  }
}
