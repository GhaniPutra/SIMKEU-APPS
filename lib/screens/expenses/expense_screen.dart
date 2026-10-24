import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/expense_model.dart';
import '../../providers/expense_provider.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  static const _categories = <String>[
    'beli_stok',
    'gaji',
    'listrik',
    'air',
    'sewa',
    'transport',
    'lainnya',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ExpenseProvider>().fetchExpenses(),
    );
  }

  Future<void> _showForm({ExpenseModel? existing}) async {
    final amountController = TextEditingController(
      text: existing?.amount.toStringAsFixed(0) ?? '',
    );
    final descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    final dateController = TextEditingController(
      text: existing?.date.isNotEmpty == true
          ? existing!.date
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final formKey = GlobalKey<FormState>();
    var selectedCategory = existing?.category;
    var isSaving = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.pastelOrange,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.receipt_long_rounded,
                                color: AppColors.warning),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  existing == null
                                      ? 'Catat pengeluaran'
                                      : 'Ubah pengeluaran',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Simpan biaya operasional dengan rapi.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _ExpenseFormField(
                        controller: amountController,
                        label: 'Nominal pengeluaran',
                        hint: 'Contoh: 50000',
                        prefix: 'Rp',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          final amount = double.tryParse(
                            (value ?? '').replaceAll(RegExp(r'[^0-9]'), ''),
                          );
                          return amount == null || amount <= 0
                              ? 'Masukkan nominal lebih dari Rp0.'
                              : null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Kategori',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        isExpanded: true,
                        validator: (value) => value == null
                            ? 'Pilih kategori pengeluaran.'
                            : null,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded),
                        style: GoogleFonts.inter(color: AppColors.textPrimary),
                        decoration: _fieldDecoration('Pilih kategori'),
                        items: _categories
                            .map(
                              (category) => DropdownMenuItem(
                                value: category,
                                child: Row(
                                  children: [
                                    Icon(_categoryIcon(category),
                                        size: 19, color: AppColors.navy),
                                    const SizedBox(width: 10),
                                    Text(_categoryLabel(category)),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: isSaving
                            ? null
                            : (value) => setSheetState(
                                  () => selectedCategory = value,
                                ),
                      ),
                      const SizedBox(height: 16),
                      _DateField(
                        controller: dateController,
                        onPick: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate:
                                DateTime.tryParse(dateController.text) ??
                                    DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(picked);
                            setSheetState(() {});
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      _ExpenseFormField(
                        controller: descriptionController,
                        label: 'Catatan',
                        hint: 'Tambahkan keterangan bila diperlukan',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }
                                  setSheetState(() => isSaving = true);
                                  final data = <String, dynamic>{
                                    'amount': double.tryParse(amountController
                                            .text
                                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                                        0,
                                    'category': selectedCategory,
                                    'expense_date': dateController.text,
                                    'description': descriptionController.text.trim(),
                                  };
                                  final provider =
                                      context.read<ExpenseProvider>();
                                  final error = existing == null
                                      ? await provider.addExpense(data)
                                      : await provider.updateExpense(
                                          existing.id,
                                          data,
                                        );
                                  if (!sheetContext.mounted) return;
                                  if (error == null) {
                                    Navigator.pop(sheetContext);
                                    if (mounted) {
                                      _showToast(
                                        existing == null
                                            ? 'Pengeluaran berhasil dicatat.'
                                            : 'Pengeluaran berhasil diperbarui.',
                                        AppColors.success,
                                      );
                                    }
                                  } else {
                                    setSheetState(() => isSaving = false);
                                    if (mounted) _showToast(error, AppColors.error);
                                  }
                                },
                          icon: isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.check_rounded),
                          label: Text(isSaving
                              ? 'Menyimpan'
                              : existing == null
                                  ? 'Simpan pengeluaran'
                                  : 'Simpan perubahan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    amountController.dispose();
    descriptionController.dispose();
    dateController.dispose();
  }

  Future<void> _confirmDelete(ExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Hapus pengeluaran?',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '${_categoryLabel(expense.category)} sebesar ${CurrencyFormatter.format(expense.amount)} akan dihapus permanen.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(88, 48),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error =
        await context.read<ExpenseProvider>().deleteExpense(expense.id);
    if (!mounted) return;
    _showToast(
      error ?? 'Pengeluaran berhasil dihapus.',
      error == null ? AppColors.success : AppColors.error,
    );
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Text(message),
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('d MMM y', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw.isEmpty ? 'Tanggal belum tersedia' : raw;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _ExpenseHero(
              totalMonth: provider.totalMonth,
              totalToday: provider.totalToday,
              count: provider.expenses.length,
              onBack: () => Navigator.maybePop(context),
              onRefresh: () => provider.fetchExpenses(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _showForm,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Catat pengeluaran'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                children: [
                  Text(
                    'Riwayat pengeluaran',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.expenses.length} catatan',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildExpenseBody(provider)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseBody(ExpenseProvider provider) {
    if (provider.isLoading && provider.expenses.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy),
      );
    }
    if (provider.errorMessage != null && provider.expenses.isEmpty) {
      return _ExpenseState(
        icon: Icons.cloud_off_rounded,
        title: 'Data belum dapat dimuat',
        message: provider.errorMessage!,
        actionLabel: 'Coba lagi',
        onAction: provider.fetchExpenses,
      );
    }
    if (provider.expenses.isEmpty) {
      return _ExpenseState(
        icon: Icons.receipt_long_outlined,
        title: 'Belum ada pengeluaran',
        message: 'Catat biaya operasional agar laporan keuangan tetap akurat.',
        actionLabel: 'Catat sekarang',
        onAction: _showForm,
      );
    }

    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: provider.fetchExpenses,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        itemCount: provider.expenses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final expense = provider.expenses[index];
          return _ExpenseCard(
            expense: expense,
            formattedDate: _formatDate(expense.date),
            onEdit: () => _showForm(existing: expense),
            onDelete: () => _confirmDelete(expense),
          );
        },
      ),
    );
  }
}

class _ExpenseHero extends StatelessWidget {
  final double totalMonth;
  final double totalToday;
  final int count;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;

  const _ExpenseHero({
    required this.totalMonth,
    required this.totalToday,
    required this.count,
    required this.onBack,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengeluaran',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kontrol biaya operasional usaha',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang pengeluaran',
                onPressed: onRefresh,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'TOTAL BULAN INI',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.68),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(totalMonth),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _HeroMetric(
                label: 'Hari ini',
                value: CurrencyFormatter.format(totalToday),
              ),
              Container(
                width: 1,
                height: 34,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              _HeroMetric(label: 'Catatan', value: '$count transaksi'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;
  final String formattedDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseCard({
    required this.expense,
    required this.formattedDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = expense.category;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _categoryColor(category),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(_categoryIcon(category), color: _categoryIconColor(category)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _categoryLabel(category),
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (expense.description?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Text(
                    expense.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(expense.amount),
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              PopupMenuButton<String>(
                tooltip: 'Aksi pengeluaran',
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.more_horiz_rounded,
                    color: AppColors.textSecondary),
                onSelected: (action) {
                  if (action == 'edit') onEdit();
                  if (action == 'delete') onDelete();
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Ubah'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline, color: AppColors.error),
                      title: Text('Hapus',
                          style: TextStyle(color: AppColors.error)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ExpenseState({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.pastelOrange,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: AppColors.warning),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? prefix;
  final TextInputType keyboardType;
  final int maxLines;
  final String? Function(String?)? validator;

  const _ExpenseFormField({
    required this.controller,
    required this.label,
    required this.hint,
    this.prefix,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: _fieldDecoration(hint).copyWith(
            prefixText: prefix == null ? null : '$prefix  ',
            alignLabelWithHint: maxLines > 1,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function() onPick;

  const _DateField({required this.controller, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal pengeluaran',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onPick,
          validator: (value) => (value ?? '').isEmpty
              ? 'Pilih tanggal pengeluaran.'
              : null,
          style: GoogleFonts.inter(color: AppColors.textPrimary),
          decoration: _fieldDecoration('Pilih tanggal').copyWith(
            prefixIcon: const Icon(Icons.calendar_today_outlined,
                size: 20, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    );

String _categoryLabel(String category) {
  const labels = <String, String>{
    'beli_stok': 'Beli stok',
    'gaji': 'Gaji',
    'listrik': 'Listrik',
    'air': 'Air',
    'sewa': 'Sewa',
    'transport': 'Transport',
    'lainnya': 'Lainnya',
  };
  return labels[category] ?? category.replaceAll('_', ' ');
}

IconData _categoryIcon(String category) {
  switch (category) {
    case 'beli_stok':
      return Icons.inventory_2_outlined;
    case 'gaji':
      return Icons.groups_2_outlined;
    case 'listrik':
      return Icons.bolt_outlined;
    case 'air':
      return Icons.water_drop_outlined;
    case 'sewa':
      return Icons.home_work_outlined;
    case 'transport':
      return Icons.local_shipping_outlined;
    default:
      return Icons.more_horiz_rounded;
  }
}

Color _categoryColor(String category) {
  switch (category) {
    case 'listrik':
      return AppColors.pastelYellow;
    case 'air':
      return AppColors.pastelBlue;
    case 'gaji':
      return AppColors.pastelPink;
    case 'transport':
      return AppColors.pastelOrange;
    default:
      return AppColors.navySoft;
  }
}

Color _categoryIconColor(String category) {
  switch (category) {
    case 'listrik':
      return AppColors.warning;
    case 'air':
      return AppColors.info;
    case 'gaji':
      return const Color(0xFFBE185D);
    case 'transport':
      return const Color(0xFFC2410C);
    default:
      return AppColors.navy;
  }
}
