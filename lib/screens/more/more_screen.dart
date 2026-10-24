import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../auth/login_screen.dart';
import '../expenses/expense_screen.dart';
import '../pos/product_manage_screen.dart';
import '../settings/settings_screen.dart';
import '../stock/stock_allocation_screen.dart';

class MoreScreen extends StatelessWidget {
  final ValueChanged<int>? onGoTab;

  const MoreScreen({super.key, this.onGoTab});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.navyDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.point_of_sale_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SIMKEU',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16)),
                        Text('Kasir',
                            style: GoogleFonts.inter(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.notifications_none_rounded,
                      color: Colors.white70),
                ],
              ),
              const SizedBox(height: 18),
              Text(user?.name ?? 'Kasir',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16)),
              Text(user?.email ?? 'kasir@simkeu.id',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 28),
              _nav(context, Icons.home_rounded, 'Beranda',
                  selected: true, onTap: () => onGoTab?.call(0)),
              _nav(context, Icons.receipt_long_rounded, 'Transaksi',
                  onTap: () => onGoTab?.call(1)),
              _nav(context, Icons.grid_view_rounded, 'Produk',
                  onTap: () => onGoTab?.call(2)),
              _nav(context, Icons.history_rounded, 'Riwayat',
                  onTap: () => onGoTab?.call(1)),
              _nav(context, Icons.settings_outlined, 'Pengaturan', onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()));
              }),
              _nav(context, Icons.inventory_2_outlined, 'Kelola Produk',
                  onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductManageScreen()));
              }),
              _nav(context, Icons.payments_outlined, 'Pengeluaran', onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const _ExpensePage()));
              }),
              _nav(context, Icons.inventory_outlined, 'Alokasi Stok', onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const StockAllocationScreen()));
              }),
              const Spacer(),
              _nav(context, Icons.logout_rounded, 'Keluar', onTap: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (_) => false,
                  );
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _nav(BuildContext context, IconData icon, String label,
      {required VoidCallback onTap, bool selected = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.navyMid : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Text(label,
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpensePage extends StatelessWidget {
  const _ExpensePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Pengeluaran'),
      ),
      body: const ExpenseScreen(),
    );
  }
}
