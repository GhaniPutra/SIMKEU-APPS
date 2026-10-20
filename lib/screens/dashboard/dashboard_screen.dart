import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/sale_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/stock_allocation_provider.dart';
import '../auth/login_screen.dart';
import '../expenses/expense_screen.dart';
import '../pos/pos_screen.dart';
import '../sales/sales_history_screen.dart';
import '../stock/stock_allocation_screen.dart';

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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Text('Konfirmasi Logout',
            style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        content: Text('Apakah kamu yakin ingin keluar?',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Logout',
                  style: GoogleFonts.poppins(
                      color: AppColors.error, fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        isRefreshing: _isRefreshing,
        onRefresh: _loadData,
        onSwitchToPos: () => setState(() => _selectedIndex = 1),
        onSwitchToSales: () => setState(() => _selectedIndex = 2),
        onOpenStockAllocations: () =>
            Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => StockAllocationScreen(
            onOpenPos: () => setState(() => _selectedIndex = 1),
          ),
        )),
        onLogout: _handleLogout,
      ),
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
      BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
      BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_rounded), label: 'POS'),
      BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long_rounded), label: 'Penjualan'),
      BottomNavigationBarItem(
          icon: Icon(Icons.money_off_rounded), label: 'Pengeluaran'),
    ];
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4))
      ]),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        selectedLabelStyle:
            GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: items,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final VoidCallback onSwitchToPos;
  final VoidCallback onSwitchToSales;
  final VoidCallback onOpenStockAllocations;
  final VoidCallback onLogout;

  const _HomeTab(
      {required this.isRefreshing,
      required this.onRefresh,
      required this.onSwitchToPos,
      required this.onSwitchToSales,
      required this.onOpenStockAllocations,
      required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sales = context.watch<SaleProvider>();
    final stocks = context.watch<StockAllocationProvider>();
    final name = auth.currentUser?.name ?? 'Pegawai';
    final dashboardPending = isRefreshing &&
        sales.dashboardError == null &&
        sales.trendLabels.isEmpty &&
        sales.todayTotal == 0 &&
        sales.todayCount == 0;
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final dateLabel = '${now.day} ${months[now.month - 1]} ${now.year}';

    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        final horizontal = constraints.maxWidth >= 700 ? 32.0 : 20.0;
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: onRefresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: Center(
                      child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text('Selamat bekerja,',
                                    style: _text(
                                        color: AppColors.textSecondary,
                                        size: 12)),
                                const SizedBox(height: 2),
                                Text(name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: _text(
                                        color: AppColors.textPrimary,
                                        size: 20,
                                        weight: FontWeight.w700)),
                                Text(dateLabel,
                                    style: _text(
                                        color: AppColors.textSecondary,
                                        size: 12)),
                              ])),
                          IconButton(
                            tooltip: 'Akun dan logout',
                            onPressed: onLogout,
                            style: IconButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: const BorderSide(
                                        color: AppColors.border))),
                            icon: const Icon(Icons.person_outline,
                                color: AppColors.primary),
                          ),
                        ]),
                        const SizedBox(height: 20),
                        Row(children: [
                          Expanded(
                              child: Text('Ringkasan hari ini',
                                  style: _text(
                                      color: AppColors.textPrimary,
                                      size: 15,
                                      weight: FontWeight.w600))),
                          if (isRefreshing)
                            const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                        ]),
                        const SizedBox(height: 10),
                        if (sales.dashboardError != null &&
                            sales.trendLabels.isEmpty &&
                            sales.todayTotal == 0)
                          _InlineError(
                              message: sales.dashboardError!,
                              onRetry: onRefresh)
                        else
                          GridView.count(
                            crossAxisCount: columns,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: columns == 4 ? 1.5 : 1.35,
                            children: [
                              _MetricCard(
                                  title: 'Penjualan hari ini',
                                  value: dashboardPending
                                      ? '—'
                                      : CurrencyFormatter.formatShort(
                                          sales.todayTotal),
                                  icon: Icons.trending_up,
                                  color: AppColors.primary),
                              _MetricCard(
                                  title: 'Jumlah transaksi',
                                  value: dashboardPending
                                      ? '—'
                                      : '${sales.todayCount}',
                                  icon: Icons.receipt_long_outlined,
                                  color: AppColors.info),
                              _MetricCard(
                                  title: 'Pengeluaran tercatat',
                                  value: dashboardPending
                                      ? '—'
                                      : CurrencyFormatter.formatShort(
                                          sales.todayExpenseTotal),
                                  icon: Icons.south_west,
                                  color: AppColors.warning),
                              _MetricCard(
                                  title: 'Selisih penjualan & pengeluaran',
                                  value: dashboardPending
                                      ? '—'
                                      : CurrencyFormatter.formatShort(
                                          sales.todayTotal -
                                              sales.todayExpenseTotal),
                                  icon: Icons.compare_arrows,
                                  color: AppColors.secondaryDark),
                            ],
                          ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                            title: 'Pemasukan vs pengeluaran',
                            trailing: Text('30 hari terakhir',
                                style: _text(
                                    color: AppColors.textSecondary, size: 10))),
                        const SizedBox(height: 8),
                        _TrendCard(sales: sales, isLoading: isRefreshing),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: onSwitchToPos,
                            style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.point_of_sale_outlined,
                                size: 20),
                            label: Text('Mulai transaksi POS',
                                style: _text(
                                    color: Colors.white,
                                    size: 14,
                                    weight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionTitle(
                            title: 'Konfirmasi alokasi stok',
                            trailing: stocks.allocations.isNotEmpty
                                ? Text('${stocks.allocations.length} pending',
                                    style: _text(
                                        color: AppColors.warning,
                                        size: 11,
                                        weight: FontWeight.w600))
                                : null),
                        const SizedBox(height: 8),
                        _AllocationPreview(
                            provider: stocks,
                            onOpen: onOpenStockAllocations,
                            onRetry: onRefresh),
                        const SizedBox(height: 20),
                        _SectionTitle(
                            title: 'Penjualan terbaru',
                            trailing: TextButton(
                                onPressed: onSwitchToSales,
                                child: Text('Lihat semua',
                                    style: _text(
                                        color: AppColors.primary,
                                        size: 12,
                                        weight: FontWeight.w600)))),
                        const SizedBox(height: 4),
                        _RecentSales(sales: sales, isLoading: isRefreshing),
                        const SizedBox(height: 28),
                      ]),
                ),
              ))),
            ],
          ),
        );
      }),
    );
  }
}

TextStyle _text(
        {required Color color,
        required double size,
        FontWeight weight = FontWeight.w400}) =>
    GoogleFonts.poppins(color: color, fontSize: size, fontWeight: weight);

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _MetricCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 18),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _text(
                        color: AppColors.textPrimary,
                        size: 17,
                        weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _text(color: AppColors.textSecondary, size: 10)),
              ]),
            ]),
      );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const _SectionTitle({required this.title, this.trailing});
  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: Text(title,
                style: _text(
                    color: AppColors.textPrimary,
                    size: 14,
                    weight: FontWeight.w600))),
        if (trailing != null) trailing!
      ]);
}

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) => const Row(children: [
        _LegendItem(color: AppColors.info, label: 'Pemasukan'),
        SizedBox(width: 10),
        _LegendItem(color: AppColors.error, label: 'Pengeluaran'),
      ]);
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: _text(color: AppColors.textSecondary, size: 9))
      ]);
}

class _TrendCard extends StatefulWidget {
  final SaleProvider sales;
  final bool isLoading;
  const _TrendCard({required this.sales, required this.isLoading});

  @override
  State<_TrendCard> createState() => _TrendCardState();
}

class _TrendCardState extends State<_TrendCard> {
  static const double _desiredCategoryWidth = 38;
  static const double _axisWidth = 64;

  final ScrollController _horizontalController = ScrollController();
  bool _didInitialScroll = false;

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sales = widget.sales;
    final valid = sales.trendLabels.isNotEmpty &&
        sales.revenueTrend.length == sales.trendLabels.length &&
        sales.expenseTrend.length == sales.trendLabels.length;
    final hasFinancialData = [...sales.revenueTrend, ...sales.expenseTrend]
        .any((value) => value > 0);
    return Container(
      height: 280,
      padding: const EdgeInsets.fromLTRB(10, 12, 14, 10),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10)),
      child: widget.isLoading && !valid
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : !valid
              ? Center(
                  child: Text(
                      sales.dashboardError ?? 'Data tren belum tersedia',
                      style: _text(color: AppColors.textSecondary, size: 12)))
              : !hasFinancialData
                  ? Center(
                      child: Text(
                          'Belum ada data keuangan pada 30 hari terakhir.',
                          textAlign: TextAlign.center,
                          style:
                              _text(color: AppColors.textSecondary, size: 12)))
                  : _buildChart(sales),
    );
  }

  Widget _buildChart(SaleProvider sales) {
    _scrollToLatest();
    final labels = sales.trendLabels;
    final revenue = sales.revenueTrend;
    final expenses = sales.expenseTrend;
    final maxValue = [...revenue, ...expenses]
        .fold<double>(0, (max, value) => value > max ? value : max);
    final interval = _interval(maxValue);
    final maxY = maxValue <= 0 ? 1.0 : maxValue * 1.15;
    final count = labels.length;
    final categoryPercentage = _categoryPercentage(count);
    final tickStep = (count / 8).ceil().clamp(1, count).toInt();

    return LayoutBuilder(builder: (context, constraints) {
      final plotViewportWidth = (constraints.maxWidth - _axisWidth)
          .clamp(1.0, double.infinity)
          .toDouble();
      final plotWidth =
          math.max(plotViewportWidth, count * _desiredCategoryWidth).toDouble();
      final categoryWidth = plotWidth / count;
      final barWidth = (categoryWidth * categoryPercentage * .7 / 2)
          .clamp(1.0, 32.0)
          .toDouble();
      final groupsSpace = (categoryWidth - (barWidth * 2 + 3))
          .clamp(0.0, double.infinity)
          .toDouble();

      return Column(children: [
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            SizedBox(
              width: _axisWidth,
              child: BarChart(_axisData(maxY, interval)),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: SizedBox(
                  width: plotWidth,
                  child: BarChart(BarChartData(
                    minY: 0,
                    maxY: maxY,
                    alignment: BarChartAlignment.center,
                    groupsSpace: groupsSpace,
                    barGroups: List.generate(
                        count,
                        (index) => BarChartGroupData(
                              x: index,
                              barsSpace: 3,
                              barRods: [
                                _financialBar(
                                    revenue[index], AppColors.info, barWidth),
                                _financialBar(
                                    expenses[index], AppColors.error, barWidth),
                              ],
                            )),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: interval,
                      getDrawingHorizontalLine: (_) =>
                          const FlLine(color: AppColors.border, strokeWidth: 1),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 ||
                              index >= count ||
                              (index % tickStep != 0 && index != count - 1)) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(labels[index],
                                  style: _text(
                                      color: AppColors.textSecondary,
                                      size: 8)));
                        },
                      )),
                    ),
                    barTouchData: BarTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 6,
                        tooltipPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 6),
                        tooltipMargin: 6,
                        maxContentWidth: 180,
                        fitInsideHorizontally: true,
                        fitInsideVertically: true,
                        getTooltipColor: (_) => AppColors.textPrimary,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final incomeValue =
                              CurrencyFormatter.format(revenue[groupIndex]);
                          final expenseValue =
                              CurrencyFormatter.format(expenses[groupIndex]);
                          return BarTooltipItem(
                            '${labels[groupIndex]}\nPemasukan: $incomeValue\nPengeluaran: $expenseValue',
                            _text(
                                color: Colors.white,
                                size: 9,
                                weight: FontWeight.w500),
                          );
                        },
                      ),
                    ),
                  )),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        const _Legend(),
      ]);
    });
  }

  BarChartData _axisData(double maxY, double interval) => BarChartData(
        minY: 0,
        maxY: maxY,
        barGroups: const [],
        alignment: BarChartAlignment.center,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _axisWidth,
            interval: interval,
            getTitlesWidget: (value, _) => Text(_formatChartTick(value),
                maxLines: 1,
                style: _text(color: AppColors.textSecondary, size: 8)),
          )),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            getTitlesWidget: (_, __) => const SizedBox.shrink(),
          )),
        ),
        barTouchData: BarTouchData(enabled: false),
      );

  void _scrollToLatest() {
    if (_didInitialScroll) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_horizontalController.hasClients) return;
      _horizontalController
          .jumpTo(_horizontalController.position.maxScrollExtent);
      _didInitialScroll = true;
    });
  }

  double _interval(double highest) {
    if (highest <= 0) return 1;
    return highest / 4;
  }

  BarChartRodData _financialBar(double value, Color color, double width) =>
      BarChartRodData(
        toY: value,
        color: color,
        width: width,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      );

  double _categoryPercentage(int count) {
    if (count <= 1) return .10;
    if (count <= 3) return .20;
    if (count <= 7) return .30;
    if (count <= 14) return .40;
    return .60;
  }

  String _formatChartTick(double value) {
    if (value >= 1000000) {
      return 'Rp ${NumberFormat('#,##0.#', 'id_ID').format(value / 1000000)} jt';
    }
    if (value >= 1000) {
      return 'Rp ${NumberFormat('#,##0', 'id_ID').format(value / 1000)} rb';
    }
    return CurrencyFormatter.format(value);
  }
}

class _AllocationPreview extends StatelessWidget {
  final StockAllocationProvider provider;
  final VoidCallback onOpen;
  final Future<void> Function() onRetry;
  const _AllocationPreview(
      {required this.provider, required this.onOpen, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    if (provider.isLoading && provider.allocations.isEmpty) {
      return const _SimpleState(text: 'Memuat alokasi stok…', loading: true);
    }
    if (provider.errorMessage != null && provider.allocations.isEmpty) {
      return _InlineError(message: provider.errorMessage!, onRetry: onRetry);
    }
    if (provider.allocations.isEmpty) {
      return const _SimpleState(
          text: 'Tidak ada alokasi yang menunggu konfirmasi.');
    }
    final shown = provider.allocations.take(2).toList();
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        if (provider.errorMessage != null)
          Padding(
              padding: const EdgeInsets.all(8),
              child: _InlineError(
                  message: provider.errorMessage!, onRetry: onRetry)),
        ...shown.map((item) => ListTile(
              dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              leading: const Icon(Icons.inventory_2_outlined,
                  color: AppColors.warning, size: 19),
              title: Text(item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _text(
                      color: AppColors.textPrimary,
                      size: 12,
                      weight: FontWeight.w600)),
              subtitle: Text(
                  '${item.requestedQuantity} ${item.productUnit} menunggu konfirmasi',
                  style: _text(color: AppColors.textSecondary, size: 10)),
              trailing: const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 18),
              onTap: onOpen,
            )),
        if (provider.allocations.length > 2)
          Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('+${provider.allocations.length - 2} alokasi lainnya',
                  style: _text(color: AppColors.textSecondary, size: 10))),
        const Divider(height: 1, color: AppColors.divider),
        Align(
            alignment: Alignment.centerRight,
            child: TextButton(
                onPressed: onOpen,
                child: Text('Tinjau alokasi',
                    style: _text(
                        color: AppColors.primary,
                        size: 11,
                        weight: FontWeight.w600)))),
      ]),
    );
  }
}

class _RecentSales extends StatelessWidget {
  final SaleProvider sales;
  final bool isLoading;
  const _RecentSales({required this.sales, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    if (isLoading && sales.sales.isEmpty) {
      return const _SimpleState(text: 'Memuat penjualan…', loading: true);
    }
    if (sales.errorMessage != null && sales.sales.isEmpty) {
      return _InlineError(
          message: sales.errorMessage!, onRetry: () => sales.fetchSales());
    }
    if (sales.sales.isEmpty) {
      return const _SimpleState(text: 'Belum ada penjualan pada periode ini.');
    }
    return Column(children: [
      if (sales.errorMessage != null)
        Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _InlineError(
                message: sales.errorMessage!,
                onRetry: () => sales.fetchSales())),
      ...sales.sales.take(5).map((sale) => _SaleRow(sale: sale)),
    ]);
  }
}

class _SaleRow extends StatelessWidget {
  final SaleModel sale;
  const _SaleRow({required this.sale});

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(sale.createdAt);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.receipt_long_outlined,
            color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(sale.invoiceNumber,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _text(
                  color: AppColors.textPrimary,
                  size: 12,
                  weight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('$time  ·  ${_paymentLabel(sale.paymentMethod)}',
              style: _text(color: AppColors.textSecondary, size: 10)),
        ])),
        const SizedBox(width: 8),
        Text(CurrencyFormatter.format(sale.totalAmount),
            maxLines: 1,
            style: _text(
                color: AppColors.textPrimary,
                size: 12,
                weight: FontWeight.w600)),
      ]),
    );
  }

  String _formatTime(String raw) {
    try {
      return DateFormat('HH:mm').format(DateTime.parse(raw).toLocal());
    } catch (_) {
      return raw.length >= 16 ? raw.substring(11, 16) : 'Waktu tidak tersedia';
    }
  }

  String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'ewallet':
        return 'QRIS';
      case 'transfer':
        return 'Transfer';
      default:
        return 'Tunai';
    }
  }
}

class _SimpleState extends StatelessWidget {
  final String text;
  final bool loading;
  const _SimpleState({required this.text, this.loading = false});
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (loading) ...[
            const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 9)
          ],
          Text(text,
              textAlign: TextAlign.center,
              style: _text(color: AppColors.textSecondary, size: 11))
        ]),
      );
}

class _InlineError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _InlineError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Expanded(
              child: Text(message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _text(color: AppColors.error, size: 10))),
          TextButton(
              onPressed: onRetry,
              child: Text('Coba lagi',
                  style: _text(
                      color: AppColors.primary,
                      size: 10,
                      weight: FontWeight.w600)))
        ]),
      );
}
