import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../models/stock_allocation_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/stock_allocation_provider.dart';

class StockAllocationScreen extends StatefulWidget {
  const StockAllocationScreen({super.key});

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
    final auth = context.read<AuthProvider>();
    final employeeId = auth.currentUser?.id ?? 0;
    if (employeeId > 0) {
      await context.read<StockAllocationProvider>().fetchPendingAllocations(
        employeeId: employeeId,
      );
    }
  }

  Future<void> _acceptAllocation(StockAllocationModel allocation) async {
    final provider = context.read<StockAllocationProvider>();
    final result = await provider.reviewAllocation(
      allocationId: allocation.id,
      decision: 'accept',
      confirmedQuantity: allocation.requestedQuantity,
    );

    if (!mounted) return;
    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alokasi stok diterima.'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((result['message'] as String?) ?? 'Gagal menerima alokasi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _declineAllocation(StockAllocationModel allocation) async {
    final actualController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Decline alokasi stok'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: actualController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Jumlah aktual',
                  hintText: 'Masukkan jumlah fisik yang diterima',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: reasonController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Alasan',
                  hintText: 'Tulis alasan selisih / ketidaksesuaian',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              final parsed = int.tryParse(actualController.text.trim());
              final reason = reasonController.text.trim();
              if (parsed == null || parsed < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jumlah aktual harus berupa angka >= 0.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan wajib diisi saat decline.'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pop(context, {
                'actual_received_quantity': parsed,
                'decline_reason': reason,
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (!mounted || result == null) return;

    final provider = context.read<StockAllocationProvider>();
    final reviewResult = await provider.reviewAllocation(
      allocationId: allocation.id,
      decision: 'decline',
      confirmedQuantity: allocation.requestedQuantity,
      actualReceivedQuantity: result['actual_received_quantity'] as int?,
      declineReason: result['decline_reason'] as String?,
    );

    if (!mounted) return;
    if (reviewResult['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Alokasi stok ditolak.'),
          backgroundColor: AppColors.warning,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text((reviewResult['message'] as String?) ?? 'Gagal menolak alokasi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alokasi Stok'),
      ),
      body: Consumer<StockAllocationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.allocations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 56, color: AppColors.textHint),
                    const SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.allocations.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Tidak ada alokasi stok pending.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAllocations,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: provider.allocations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final allocation = provider.allocations[index];
                return _AllocationCard(
                  allocation: allocation,
                  onAccept: () => _acceptAllocation(allocation),
                  onDecline: () => _declineAllocation(allocation),
                );
              },
            ),
          );
        },
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  allocation.productName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pastelOrange,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Pending',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Jumlah diminta: ${allocation.requestedQuantity} ${allocation.productUnit}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Status stok: belum masuk stok aktif; pending tidak boleh dijual.',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.85), fontSize: 12),
          ),
          if (allocation.declineReason != null && allocation.declineReason!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan sebelumnya: ${allocation.declineReason}',
              style: const TextStyle(color: AppColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Accept'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onDecline,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Decline'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
