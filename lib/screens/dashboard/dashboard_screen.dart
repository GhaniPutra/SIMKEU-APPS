// lib/screens/dashboard/dashboard_screen.dart
// Dashboard utama pegawai — light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/dashboard/stat_card.dart';
import '../../widgets/common/loading_widget.dart';
import '../auth/login_screen.dart';
import '../pos/pos_screen.dart';
import '../sales/sales_history_screen.dart';
import '../expenses/expense_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isRefreshing = true);
    await Future.wait([
      context.read<SaleProvider>().fetchDashboard(),
      context.read<SaleProvider>().fetchSales(),
      context.read<ExpenseProvider>().fetchExpenses(),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Konfirmasi Logout',
            style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(onPressed: () => Navigator.pop(context, true),
            child: Text('Logout', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(isRefreshing: _isRefreshing, onRefresh: _loadData,
        onSwitchToPos: () => setState(() => _selectedIndex = 1),
        onSwitchToSales: () => setState(() => _selectedIndex = 2)),
      const POSScreen(),
      const SalesHistoryScreen(),
      const ExpenseScreen(),
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      BottomNavigationBarItem(icon: Icon(Icons.point_of_sale_rounded), label: 'POS'),
      BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Penjualan'),
      BottomNavigationBarItem(icon: Icon(Icons.money_off_rounded), label: 'Pengeluaran'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: items,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final VoidCallback onSwitchToPos;
  final VoidCallback onSwitchToSales;

  const _HomeTab({required this.isRefreshing, required this.onRefresh,
    required this.onSwitchToPos, required this.onSwitchToSales});

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final sales   = context.watch<SaleProvider>();
    final expense = context.watch<ExpenseProvider>();
    final name    = auth.currentUser?.name ?? 'Pegawai';

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        onRefresh: () async => onRefresh(),
        child: CustomScrollView(slivers: [
          // App Bar
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Selamat Datang 👋', style: GoogleFonts.poppins(
                  color: AppColors.textSecondary, fontSize: 13)),
                Text(name, style: GoogleFonts.poppins(
                  color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
              ])),
              GestureDetector(
                onTap: () => _showLogoutMenu(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.pastelIndigo,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
                ),
              ),
            ]),
          )),

          // Quick Action POS
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: GestureDetector(
              onTap: onSwitchToPos,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20, offset: const Offset(0, 6))],
                ),
                child: Row(children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Mulai Transaksi POS', style: GoogleFonts.poppins(
                      color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('Tap untuk membuka kasir', style: GoogleFonts.poppins(
                      color: Colors.white70, fontSize: 12)),
                  ]),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 18),
                ]),
              ),
            ),
          )),

          // Stat Cards
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ringkasan Hari Ini', style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              isRefreshing ? const LoadingWidget() : GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
                children: [
                  StatCard(title: 'Penjualan Hari Ini',
                    value: CurrencyFormatter.formatShort(sales.todayTotal),
                    icon: Icons.trending_up_rounded,
                    iconColor: AppColors.secondary, iconBg: AppColors.pastelTeal),
                  StatCard(title: 'Transaksi', value: '${sales.todayCount}',
                    icon: Icons.receipt_rounded,
                    iconColor: AppColors.primary, iconBg: AppColors.pastelIndigo,
                    subtitle: 'transaksi hari ini'),
                  StatCard(title: 'Penjualan Bulan',
                    value: CurrencyFormatter.formatShort(sales.monthTotal),
                    icon: Icons.bar_chart_rounded,
                    iconColor: AppColors.info, iconBg: AppColors.pastelBlue),
                  StatCard(title: 'Pengeluaran',
                    value: CurrencyFormatter.formatShort(expense.totalMonth),
                    icon: Icons.money_off_rounded,
                    iconColor: AppColors.warning, iconBg: AppColors.pastelYellow),
                ],
              ),
            ]),
          )),

          // Transaksi Terbaru Header
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Transaksi Terbaru', style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              TextButton(onPressed: onSwitchToSales, child: Text('Lihat Semua',
                style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12))),
            ]),
          )),

          // List transaksi terbaru
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            sliver: sales.isLoading
              ? const SliverToBoxAdapter(child: LoadingWidget())
              : sales.sales.isEmpty
                ? SliverToBoxAdapter(child: Center(child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text('Belum ada transaksi hari ini',
                      style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13)))))
                : SliverList(delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _RecentSaleTile(sale: sales.sales[i]),
                    childCount: sales.sales.length > 5 ? 5 : sales.sales.length)),
          ),
        ]),
      ),
    );
  }

  void _showLogoutMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        final auth = context.read<AuthProvider>();
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(
              color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            CircleAvatar(radius: 32, backgroundColor: AppColors.pastelIndigo,
              child: const Icon(Icons.person, color: AppColors.primary, size: 32)),
            const SizedBox(height: 12),
            Text(auth.currentUser?.name ?? 'Pegawai', style: GoogleFonts.poppins(
              color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            Text(auth.currentUser?.email ?? '', style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.pastelRed, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.logout, color: AppColors.error, size: 20)),
              title: Text('Logout', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w500)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () {
                Navigator.pop(context);
                context.findAncestorStateOfType<_DashboardScreenState>()?._handleLogout();
              },
            ),
          ]),
        );
      },
    );
  }
}

class _RecentSaleTile extends StatelessWidget {
  final dynamic sale;
  const _RecentSaleTile({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.pastelTeal, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.receipt_rounded, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sale.invoiceNumber, style: GoogleFonts.poppins(
            color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          Text(sale.paymentMethod.toUpperCase(), style: GoogleFonts.poppins(
            color: AppColors.textHint, fontSize: 11)),
        ])),
        Text(CurrencyFormatter.format(sale.totalAmount), style: GoogleFonts.poppins(
          color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
