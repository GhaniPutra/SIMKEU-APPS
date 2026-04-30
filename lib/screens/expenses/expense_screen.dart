// lib/screens/expenses/expense_screen.dart
// Layar pengeluaran — daftar + tambah/edit/hapus (CRUD lengkap)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/expense_provider.dart';
import '../../models/expense_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/common/app_button.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<ExpenseProvider>().fetchExpenses(),
    );
  }

  String _formatDate(String raw) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) {
      return raw;
    }
  }

  // ── Modal form tambah/edit ────────────────────────────
  void _showForm({ExpenseModel? existing}) {
    final nameCtrl  = TextEditingController(text: existing?.name ?? '');
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final catCtrl   = TextEditingController(text: existing?.category ?? '');
    final descCtrl  = TextEditingController(text: existing?.description ?? '');
    final dateCtrl  = TextEditingController(
        text: existing?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final formKey   = GlobalKey<FormState>();

    showModalBottomSheet(
      context      : context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          bool isLoading = false;
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
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
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(existing == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                        style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    _FormField(label: 'Nama Pengeluaran', ctrl: nameCtrl,
                        hint: 'Beli bahan baku...', validator: (v) =>
                            v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    _FormField(label: 'Jumlah (Rp)', ctrl: amountCtrl,
                        hint: '50000', keyboard: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    _FormField(label: 'Kategori', ctrl: catCtrl,
                        hint: 'operasional, gaji, dll',
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    _FormField(label: 'Tanggal', ctrl: dateCtrl,
                        hint: 'YYYY-MM-DD',
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                    const SizedBox(height: 12),
                    _FormField(label: 'Keterangan (opsional)', ctrl: descCtrl,
                        hint: 'Detail tambahan...', maxLines: 2),
                    const SizedBox(height: 20),
                    StatefulBuilder(builder: (_, ss) => AppButton(
                      label    : existing == null ? 'Simpan' : 'Perbarui',
                      isLoading: isLoading,
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        ss(() => isLoading = true);
                        final data = {
                          'name'       : nameCtrl.text.trim(),
                          'amount'     : double.tryParse(amountCtrl.text) ?? 0,
                          'category'   : catCtrl.text.trim(),
                          'date'       : dateCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                        };
                        final provider = context.read<ExpenseProvider>();
                        final error = existing == null
                            ? await provider.addExpense(data)
                            : await provider.updateExpense(existing.id, data);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(error, style: GoogleFonts.poppins()),
                            backgroundColor: AppColors.error,
                            behavior: SnackBarBehavior.floating,
                          ));
                        }
                      },
                    )),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // ── Konfirmasi hapus ──────────────────────────────────
  void _confirmDelete(ExpenseModel expense) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Pengeluaran?',
            style: GoogleFonts.poppins(color: AppColors.textPrimary)),
        content: Text('${expense.name} akan dihapus permanen.',
            style: GoogleFonts.poppins(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final error = await context.read<ExpenseProvider>().deleteExpense(expense.id);
              if (error != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(error, style: GoogleFonts.poppins()),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();

    return SafeArea(
      child: Column(children: [
        // ── Header ──────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Pengeluaran',
                    style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 22, fontWeight: FontWeight.w700)),
                Text('Catat & kelola pengeluaran operasional',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 12)),
              ]),
            ),
            GestureDetector(
              onTap: () => _showForm(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient    : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ]),
        ),

        // ── Total bulan ini ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient    : AppColors.tealGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const Icon(Icons.summarize_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Total Pengeluaran Bulan Ini',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                Text(CurrencyFormatter.format(expProv.totalMonth),
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 12),

        // ── List ─────────────────────────────────────────
        Expanded(
          child: expProv.isLoading
              ? const LoadingWidget()
              : expProv.errorMessage != null
                  ? AppErrorWidget(
                      message: expProv.errorMessage!,
                      onRetry: () => expProv.fetchExpenses())
                  : expProv.expenses.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.money_off_rounded,
                                  color: AppColors.textHint, size: 56),
                              const SizedBox(height: 12),
                              Text('Belum ada pengeluaran',
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textHint, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () => _showForm(),
                                icon : const Icon(Icons.add, color: AppColors.primary),
                                label: Text('Tambah Sekarang',
                                    style: GoogleFonts.poppins(color: AppColors.primary)),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          color: AppColors.primary,
                          onRefresh: () => expProv.fetchExpenses(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                            itemCount: expProv.expenses.length,
                            itemBuilder: (_, i) {
                              final exp = expProv.expenses[i];
                              return Dismissible(
                                key      : Key('expense_${exp.id}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding  : const EdgeInsets.only(right: 16),
                                  margin   : const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color       : AppColors.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(Icons.delete, color: AppColors.error),
                                ),
                                confirmDismiss: (_) async {
                                  _confirmDelete(exp);
                                  return false;
                                },
                                child: _ExpenseTile(
                                  expense   : exp,
                                  formatDate: _formatDate,
                                  onEdit    : () => _showForm(existing: exp),
                                  onDelete  : () => _confirmDelete(exp),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ]),
    );
  }
}

// ── Tile item pengeluaran ─────────────────────────────
class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final String Function(String) formatDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ExpenseTile({
    required this.expense,
    required this.formatDate,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin  : const EdgeInsets.only(bottom: 10),
      padding : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color       : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border      : Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color       : AppColors.warning.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.money_off_rounded,
              color: AppColors.warning, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(expense.name,
                style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(expense.category,
                    style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 10, fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 6),
              Text(formatDate(expense.date),
                  style: GoogleFonts.poppins(
                      color: AppColors.textHint, fontSize: 11)),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(CurrencyFormatter.format(expense.amount),
              style: GoogleFonts.poppins(
                  color: AppColors.error,
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Row(children: [
            GestureDetector(
              onTap: onEdit,
              child: const Icon(Icons.edit_outlined,
                  color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: const Icon(Icons.delete_outline,
                  color: AppColors.error, size: 18),
            ),
          ]),
        ]),
      ]),
    );
  }
}

// ── Form field sederhana ─────────────────────────────
class _FormField extends StatelessWidget {
  final String               label;
  final TextEditingController ctrl;
  final String               hint;
  final TextInputType         keyboard;
  final String? Function(String?)? validator;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.ctrl,
    required this.hint,
    this.keyboard  = TextInputType.text,
    this.validator,
    this.maxLines  = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label,
          style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
              fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(
        controller  : ctrl,
        keyboardType: keyboard,
        maxLines    : maxLines,
        validator   : validator,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText : hint,
          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
          filled: true, fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error)),
        ),
      ),
    ]);
  }
}
