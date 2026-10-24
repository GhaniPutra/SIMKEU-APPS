import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/stock_allocation_provider.dart';
import '../../widgets/kasir/kasir_ui.dart';
import '../home/home_screen.dart';
import '../more/more_screen.dart';
import '../pos/pos_screen.dart';
import '../sales/sales_history_screen.dart';

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
    if (!mounted || _isRefreshing) return;
    setState(() => _isRefreshing = true);
    final employeeId = context.read<AuthProvider>().currentUser?.id ?? 0;
    await Future.wait([
      context.read<SaleProvider>().fetchDashboard(),
      context.read<SaleProvider>().fetchSales(),
      if (employeeId > 0)
        context
            .read<StockAllocationProvider>()
            .fetchPendingAllocations(employeeId: employeeId),
    ]);
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        isRefreshing: _isRefreshing,
        onRefresh: _loadData,
        onOpenProducts: () => setState(() => _selectedIndex = 2),
        onOpenTransactions: () => setState(() => _selectedIndex = 1),
      ),
      const SalesHistoryScreen(),
      const POSScreen(),
      MoreScreen(
        onGoTab: (i) => setState(() => _selectedIndex = i),
      ),
    ];

    return Scaffold(
      backgroundColor: _selectedIndex == 3
          ? AppColors.navyDeep
          : AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: KasirBottomNav(
        index: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }
}
