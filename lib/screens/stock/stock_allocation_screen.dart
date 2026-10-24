import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/stock_allocation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stock_allocation_provider.dart';

class StockAllocationScreen extends StatefulWidget {
  final VoidCallback? onOpenPos;

  const StockAllocationScreen({super.key, this.onOpenPos});

  @override
  State<StockAllocationScreen> createState() => _StockAllocationScreenState();
}

class _StockAllocationScreenState extends State<StockAllocationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllocations());
  }

  Future<void> _loadAllocations() async {
    final employeeId = context.read<AuthProvider>().currentUser?.id ?? 0;
    if (employeeId > 0) {
      await context
          .read<StockAllocationProvider>()
          .fetchPendingAllocations(employeeId: employeeId);
    }
  }

  Future<void> _acceptAllocation(StockAllocationModel allocation) async {
    final provider = context.read<StockAllocationProvider>();
    final employeeId = context.read<AuthProvider>().currentUser?.id ?? 0;
    final result = await provider.reviewAllocation(
      allocationId: allocation.id,
      decision: 'accept',
      employeeId: employeeId,
      confirmedQuantity: allocation.requestedQuantity,
    );

    if (!mounted) return;
    _showResult(
      result,
      successMessage: 'Alokasi stok berhasil diterima.',
      successColor: AppColors.success,
    );
  }

  Future<void> _declineAllocation(StockAllocationModel allocation) async {
    final actualController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Text(
          'Laporkan selisih',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stok aktif tidak akan berubah sampai pemilik meninjau laporan ini.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _DialogField(
                controller: actualController,
                label: 'Jumlah fisik diterima',
                hint: 'Contoh: 8',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 14),
              _DialogField(
                controller: reasonController,
                label: 'Keterangan selisih',
                hint: 'Contoh: baru menerima 8 dari 10 barang',
                minLines: 3,
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(112, 48),
              backgroundColor: AppColors.error,
            ),
            onPressed: () {
              final actualQuantity =
                  int.tryParse(actualController.text.trim());
              final reason = reasonController.text.trim();
              if (actualQuantity == null || actualQuantity < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jumlah fisik harus berupa angka 0 atau lebih.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Keterangan selisih wajib diisi.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(dialogContext, {
                'actual_received_quantity': actualQuantity,
                'decline_reason': reason,
              });
            },
            child: const Text('Kirim laporan'),
          ),
        ],
      ),
    );

    actualController.dispose();
    reasonController.dispose();
    if (!mounted || result == null) return;

    final employeeId = context.read<AuthProvider>().currentUser?.id ?? 0;
    final reviewResult = await context
        .read<StockAllocationProvider>()
        .reviewAllocation(
          allocationId: allocation.id,
          decision: 'decline',
          employeeId: employeeId,
          confirmedQuantity: allocation.requestedQuantity,
          actualReceivedQuantity: result['actual_received_quantity'] as int?,
          declineReason: result['decline_reason'] as String?,
        );

    if (!mounted) return;
    _showResult(
      reviewResult,
      successMessage: 'Laporan selisih telah dikirim ke pemilik.',
      successColor: AppColors.warning,
    );
  }

  void _showResult(
    Map<String, dynamic> result, {
    required String successMessage,
    required Color successColor,
  }) {
    final success = result['success'] == true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(success
            ? successMessage
            : (result['message'] as String? ?? 'Permintaan tidak dapat diproses.')),
        backgroundColor: success ? successColor : AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Consumer<StockAllocationProvider>(
          builder: (context, provider, child) {
            return Column(
              children: [
                _AllocationHeader(
                  pendingCount: provider.allocations.length,
                  onBack: () => Navigator.maybePop(context),
                  onRefresh: _loadAllocations,
                  onOpenPos: widget.onOpenPos,
                ),
                Expanded(child: _buildBody(provider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(StockAllocationProvider provider) {
    if (provider.isLoading && provider.allocations.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.navy),
      );
    }

    if (provider.errorMessage != null && provider.allocations.isEmpty) {
      return _AllocationState(
        icon: Icons.cloud_off_rounded,
        title: 'Alokasi belum dapat dimuat',
        message: provider.errorMessage!,
        actionLabel: 'Coba lagi',
        onAction: _loadAllocations,
      );
    }

    if (provider.allocations.isEmpty) {
      return _AllocationState(
        icon: Icons.inventory_2_outlined,
        title: 'Semua stok sudah ditinjau',
        message: 'Alokasi baru dari pemilik akan muncul di sini.',
        actionLabel: 'Muat ulang',
        onAction: _loadAllocations,
      );
    }

    return RefreshIndicator(
      color: AppColors.navy,
      onRefresh: _loadAllocations,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        itemCount: provider.allocations.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _AllocationGuide();
          }
          final allocation = provider.allocations[index - 1];
          return _AllocationCard(
            allocation: allocation,
            onAccept: () => _acceptAllocation(allocation),
            onDecline: () => _declineAllocation(allocation),
          );
        },
      ),
    );
  }
}

class _AllocationHeader extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onBack;
  final Future<void> Function() onRefresh;
  final VoidCallback? onOpenPos;

  const _AllocationHeader({
    required this.pendingCount,
    required this.onBack,
    required this.onRefresh,
    this.onOpenPos,
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
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Alokasi stok',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Periksa barang sebelum stok aktif bertambah',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Muat ulang alokasi',
                onPressed: onRefresh,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.inventory_2_rounded,
                    color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$pendingCount menunggu konfirmasi',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Terima jika jumlah fisik sesuai.',
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (onOpenPos != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onOpenPos?.call();
              },
              style: TextButton.styleFrom(
                minimumSize: const Size(48, 44),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              icon: const Icon(Icons.point_of_sale_rounded, size: 18),
              label: const Text('Buka POS'),
            ),
          ],
        ],
      ),
    );
  }
}

class _AllocationGuide extends StatelessWidget {
  const _AllocationGuide();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pastelBlue,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.navy),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hitung barang fisik terlebih dahulu. Pilih “Terima” untuk jumlah sesuai atau “Laporkan selisih” bila berbeda.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllocationState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final Future<void> Function() onAction;

  const _AllocationState({
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
                  color: AppColors.navySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.navy, size: 30),
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
                  icon: const Icon(Icons.refresh_rounded),
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

class _AllocationCard extends StatelessWidget {
  final StockAllocationModel allocation;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _AllocationCard({
    required this.allocation,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select<StockAllocationProvider, bool>(
      (provider) => provider.isSubmitting,
    );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.navySoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  allocation.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const _StatusPill(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.add_box_outlined,
                    color: AppColors.textSecondary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Barang dialokasikan',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '${allocation.requestedQuantity} ${allocation.productUnit}',
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Stok aktif akan bertambah setelah Anda mengonfirmasi jumlah barang yang diterima.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          if (allocation.declineReason?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pastelRed,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Catatan sebelumnya: ${allocation.declineReason}',
                style: GoogleFonts.inter(
                  color: AppColors.error,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: FilledButton.icon(
                    onPressed: isSubmitting ? null : onAccept,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
                      disabledBackgroundColor:
                          AppColors.success.withValues(alpha: 0.45),
                    ),
                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(isSubmitting ? 'Memproses' : 'Terima'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: isSubmitting ? null : onDecline,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.report_outlined),
                    label: const Text('Laporkan selisih'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.pastelOrange,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        'MENUNGGU',
        style: GoogleFonts.inter(
          color: AppColors.warning,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType keyboardType;
  final int minLines;
  final int maxLines;

  const _DialogField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      style: GoogleFonts.inter(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.navy, width: 1.5),
        ),
      ),
    );
  }
}
