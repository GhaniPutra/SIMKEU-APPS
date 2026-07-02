// lib/screens/expenses/expense_screen.dart
// Layar pengeluaran — light mode premium (CRUD lengkap)

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
import '../../widgets/common/custom_toast.dart';

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
      (_) => context.read<ExpenseProvider>().fetchExpenses());
  }

  String _formatDate(String raw) {
    try { return DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(raw));
    } catch (_) { return raw; }
  }

  void _showForm({ExpenseModel? existing}) {
    final amountCtrl = TextEditingController(
        text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final catCtrl   = TextEditingController(text: existing?.category ?? '');
    final descCtrl  = TextEditingController(text: existing?.description ?? '');
    final dateCtrl  = TextEditingController(
        text: existing?.date ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final formKey   = GlobalKey<FormState>();

    const List<String> categories = [
      'beli_stok', 'gaji', 'listrik', 'air', 'sewa', 'transport', 'lainnya'];

    final Map<String, String> categoryLabels = {
      'beli_stok': 'Beli Stok', 'gaji': 'Gaji', 'listrik': 'Listrik',
      'air': 'Air', 'sewa': 'Sewa', 'transport': 'Transport', 'lainnya': 'Lainnya'};

    final Map<String, IconData> categoryIcons = {
      'beli_stok': Icons.inventory, 'gaji': Icons.people, 'listrik': Icons.bolt,
      'air': Icons.water_drop, 'sewa': Icons.home, 'transport': Icons.local_shipping,
      'lainnya': Icons.more_horiz};

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setModalState) {
          bool isLoading = false;
          return Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Form(key: formKey, child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                Text(existing == null ? 'Tambah Pengeluaran' : 'Edit Pengeluaran',
                  style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                // Tanggal
                GestureDetector(
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.tryParse(dateCtrl.text) ?? DateTime.now(),
                      firstDate: DateTime(2000), lastDate: DateTime(2100),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(
                          primary: AppColors.primary, onPrimary: Colors.white, onSurface: AppColors.textPrimary)),
                        child: child!),
                    );
                    if (picked != null) dateCtrl.text = DateFormat('yyyy-MM-dd').format(picked);
                  },
                  child: AbsorbPointer(child: _FormField(
                    label: 'Tanggal Pengeluaran', ctrl: dateCtrl, hint: 'YYYY-MM-DD',
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                ),
                const SizedBox(height: 12),
                _FormField(label: 'Jumlah (Rp)', ctrl: amountCtrl, hint: '50000',
                  keyboard: TextInputType.number, validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                const SizedBox(height: 12),
                // Dropdown Kategori
                FormField<String>(
                  initialValue: catCtrl.text.isEmpty ? null : catCtrl.text,
                  validator: (v) => v == null || v.isEmpty ? 'Pilih kategori' : null,
                  builder: (field) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Kategori', style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: catCtrl.text.isEmpty ? null : catCtrl.text,
                      decoration: InputDecoration(
                        hintText: 'Pilih kategori',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
                        filled: true, fillColor: AppColors.surfaceLight,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border, width: 1)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.error, width: 1)),
                      ),
                      items: categories.map((cat) => DropdownMenuItem(
                        value: cat,
                        child: Row(children: [
                          Icon(categoryIcons[cat] ?? Icons.category, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(categoryLabels[cat] ?? cat, style: GoogleFonts.poppins(color: AppColors.textPrimary)),
                        ]),
                      )).toList(),
                      onChanged: (val) { if (val != null) { catCtrl.text = val; field.didChange(val); } },
                    ),
                    if (field.hasError) Padding(padding: const EdgeInsets.only(top: 8),
                      child: Text(field.errorText ?? '', style: GoogleFonts.poppins(color: AppColors.error, fontSize: 12))),
                  ]),
                ),
                const SizedBox(height: 12),
                _FormField(label: 'Keterangan (opsional)', ctrl: descCtrl, hint: 'Detail tambahan...', maxLines: 2),
                const SizedBox(height: 20),
                StatefulBuilder(builder: (_, ss) => AppButton(
                  label: existing == null ? 'Simpan' : 'Perbarui', isLoading: isLoading,
                  onPressed: () async {
                    if (!formKey.currentState!.validate()) return;
                    ss(() => isLoading = true);
                    final data = {
                      'amount': double.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
                      'category': catCtrl.text.trim(),
                      'expense_date': dateCtrl.text.trim(),
                      'description': descCtrl.text.trim(),
                    };
                    final provider = context.read<ExpenseProvider>();
                    final error = existing == null
                      ? await provider.addExpense(data) : await provider.updateExpense(existing.id, data);
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    if (error != null) {
                      CustomToast.showError(context, error);
                    } else {
                      CustomToast.showSuccess(
                        context,
                        existing == null
                            ? 'Pengeluaran berhasil ditambahkan'
                            : 'Pengeluaran berhasil diperbarui',
                      );
                    }
                  },
                )),
              ]),
            )),
          );
        });
      },
    );
  }

  void _confirmDelete(ExpenseModel expense) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Hapus Pengeluaran?', style: GoogleFonts.poppins(
        color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      content: Text('Pengeluaran ${expense.category} (Rp ${expense.amount.toStringAsFixed(0)}) akan dihapus permanen.',
        style: GoogleFonts.poppins(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
        TextButton(onPressed: () async {
          Navigator.pop(context);
          final error = await context.read<ExpenseProvider>().deleteExpense(expense.id);
          if (error != null) {
            if (mounted) CustomToast.showError(context, error);
          } else {
            if (mounted) CustomToast.showSuccess(context, 'Pengeluaran berhasil dihapus');
          }
        }, child: Text('Hapus', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600))),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    final expProv = context.watch<ExpenseProvider>();

    return SafeArea(child: Column(children: [
      // Header
      Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pengeluaran', style: GoogleFonts.poppins(
              color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w700)),
            Text('Catat & kelola pengeluaran operasional', style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 12)),
          ])),
          GestureDetector(onTap: () => _showForm(),
            child: Container(padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))]),
              child: const Icon(Icons.add, color: Colors.white, size: 22))),
        ])),

      // Total bulan
      Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppColors.tealGradient, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.summarize_rounded, color: Colors.white, size: 24)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total Pengeluaran Bulan Ini', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
              Text(CurrencyFormatter.format(expProv.totalMonth), style: GoogleFonts.poppins(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            ]),
          ]),
        )),
      const SizedBox(height: 12),

      // List
      Expanded(
        child: expProv.isLoading ? const LoadingWidget()
          : expProv.errorMessage != null
            ? AppErrorWidget(message: expProv.errorMessage!, onRetry: () => expProv.fetchExpenses())
            : expProv.expenses.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(color: AppColors.pastelYellow, shape: BoxShape.circle),
                    child: const Icon(Icons.money_off_rounded, color: AppColors.warning, size: 40)),
                  const SizedBox(height: 12),
                  Text('Belum ada pengeluaran', style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextButton.icon(onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, color: AppColors.primary),
                    label: Text('Tambah Sekarang', style: GoogleFonts.poppins(color: AppColors.primary))),
                ]))
              : RefreshIndicator(color: AppColors.primary, backgroundColor: AppColors.surface,
                  onRefresh: () => expProv.fetchExpenses(),
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: expProv.expenses.length,
                    itemBuilder: (_, i) {
                      final exp = expProv.expenses[i];
                      return Dismissible(
                        key: Key('expense_${exp.id}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(color: AppColors.pastelRed, borderRadius: BorderRadius.circular(16)),
                          child: const Icon(Icons.delete, color: AppColors.error)),
                        confirmDismiss: (_) async { _confirmDelete(exp); return false; },
                        child: _ExpenseTile(expense: exp, formatDate: _formatDate,
                          onEdit: () => _showForm(existing: exp), onDelete: () => _confirmDelete(exp)),
                      );
                    })),
      ),
    ]));
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseModel expense;
  final String Function(String) formatDate;
  final VoidCallback onEdit, onDelete;
  const _ExpenseTile({required this.expense, required this.formatDate, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppColors.pastelOrange, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.money_off_rounded, color: AppColors.warning, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(CurrencyFormatter.format(expense.amount), style: GoogleFonts.poppins(
            color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.pastelIndigo, borderRadius: BorderRadius.circular(4)),
              child: Text(expense.category.replaceAll('_', ' '), style: GoogleFonts.poppins(
                color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w500))),
            const SizedBox(width: 6),
            Text(formatDate(expense.date), style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 11)),
          ]),
          if (expense.description != null && expense.description!.isNotEmpty)
            Padding(padding: const EdgeInsets.only(top: 4),
              child: Text(expense.description!, style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ])),
        Column(children: [
          GestureDetector(onTap: onEdit, child: Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.pastelIndigo, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 16))),
          const SizedBox(height: 6),
          GestureDetector(onTap: onDelete, child: Container(padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppColors.pastelRed, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 16))),
        ]),
      ]),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label; final TextEditingController ctrl; final String hint;
  final TextInputType keyboard; final String? Function(String?)? validator; final int maxLines;
  const _FormField({required this.label, required this.ctrl, required this.hint,
    this.keyboard = TextInputType.text, this.validator, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
      const SizedBox(height: 6),
      TextFormField(controller: ctrl, keyboardType: keyboard, maxLines: maxLines,
        validator: validator,
        style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint, hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
          filled: true, fillColor: AppColors.surfaceLight,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.error)),
        )),
    ]);
  }
}
