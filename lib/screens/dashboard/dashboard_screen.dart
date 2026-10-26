import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/realtime_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/employee_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/product_provider.dart';
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

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isRefreshing = false;
  final _realtime = RealtimeService();
  StreamSubscription<StoreChange>? _changeSubscription;
  StreamSubscription<bool>? _connectionSubscription;
  Timer? _fallbackTimer;
  bool _hasConnected = false;
  bool _realtimeStarted = false;
  bool _realtimeStarting = false;
  late final AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authProvider = context.read<AuthProvider>();
    _authProvider.addListener(_handleAuthChanged);
    _fallbackTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!_realtimeStarted) {
        unawaited(_authProvider.refreshCurrentUser());
      } else if (!_realtime.isConnected) {
        unawaited(_syncResources(_realtime.resources));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _connectRealtime();
    });
  }

  Future<void> _connectRealtime() async {
    if (_realtimeStarted || _realtimeStarting) return;
    _realtimeStarting = true;
    final user = context.read<AuthProvider>().currentUser;
    final token = await AuthService.getAuthToken();
    if (!mounted || user == null || token == null || user.storeId <= 0) {
      _realtimeStarting = false;
      return;
    }
    _realtimeStarted = true;
    _realtimeStarting = false;

    _changeSubscription = _realtime.changes.listen(
      (change) => _syncResources({change.resource}),
      onError: (Object error) =>
          debugPrint('Realtime event stream failed: $error'),
    );
    _connectionSubscription = _realtime.connectionChanges.listen((connected) {
      if (!connected) return;
      if (_hasConnected) unawaited(_syncResources(_realtime.resources));
      _hasConnected = true;
    });

    await _realtime.connect(
      storeId: user.storeId,
      token: token,
      permissions: user.permissions,
    );
  }

  Future<void> _syncResources(Set<String> resources) async {
    if (!mounted) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final permissions = user.permissions.toSet();
    final canViewDashboard = permissions.contains('dashboard.view') ||
        permissions.contains('dashboard.mobile.view');
    final canViewSales = permissions.contains('sales.view') ||
        permissions.contains('sales.mobile.view');
    final canViewExpenses = permissions.contains('expenses.view') ||
        permissions.contains('expenses.mobile.view');
    final refreshDashboard = canViewDashboard &&
        (resources.contains('sales') || resources.contains('expenses'));

    await Future.wait([
      if (refreshDashboard) context.read<SaleProvider>().fetchDashboard(),
      if (resources.contains('sales') && canViewSales)
        context.read<SaleProvider>().refreshSales(),
      if (resources.contains('expenses') && canViewExpenses)
        context.read<ExpenseProvider>().refreshExpenses(),
      if (resources.contains('inventory') &&
          permissions.contains('pos.mobile.use'))
        context.read<ProductProvider>().fetchProducts(),
      if (resources.contains('employees') &&
          permissions.contains('employees.view'))
        context.read<EmployeeProvider>().refreshEmployees(),
      if (resources.contains('stock-allocations') &&
          user.role == 'pegawai' &&
          permissions.contains('stock_allocations.view'))
        context
            .read<StockAllocationProvider>()
            .fetchPendingAllocations(employeeId: user.id),
    ]);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    unawaited(_realtime.reconnect());
    unawaited(_syncResources(_realtime.resources));
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authProvider.removeListener(_handleAuthChanged);
    _fallbackTimer?.cancel();
    unawaited(_changeSubscription?.cancel());
    unawaited(_connectionSubscription?.cancel());
    unawaited(_realtime.dispose());
    super.dispose();
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
      backgroundColor:
          _selectedIndex == 3 ? AppColors.navyDeep : AppColors.background,
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: KasirBottomNav(
        index: _selectedIndex,
        onChanged: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  void _handleAuthChanged() {
    if ((_authProvider.currentUser?.storeId ?? 0) > 0) {
      unawaited(_connectRealtime());
    }
  }
}
