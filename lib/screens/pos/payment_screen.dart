import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/custom_toast.dart';
import '../../widgets/kasir/kasir_ui.dart';
import 'receipt_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'tunai';
  final _paidCtrl = TextEditingController();

  final _methods = const [
    ('tunai', 'Tunai', Icons.payments_outlined),
    ('ewallet', 'QRIS', Icons.qr_code_2_rounded),
    ('transfer', 'Debit / Kartu', Icons.credit_card_rounded),
    ('ewallet_app', 'E-Wallet (GoPay, OVO, DANA, dll)', Icons.account_balance_wallet_outlined),
  ];

  @override
  void initState() {
    super.initState();
    final total = context.read<CartProvider>().total;
    _paidCtrl.text = total.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _paidCtrl.dispose();
    super.dispose();
  }

  String get _apiMethod => _method == 'ewallet_app' ? 'ewallet' : _method;

  Future<void> _pay() async {
    final cart = context.read<CartProvider>();
    final sales = context.read<SaleProvider>();
    if (cart.isEmpty) return;

    if (_method == 'tunai') {
      final paid = double.tryParse(_paidCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (paid < cart.total) {
        CustomToast.showError(context, 'Nominal bayar kurang dari total belanja');
        return;
      }
    }

    final error = await sales.createSale(
      items: cart.toApiItems(),
      paymentMethod: _apiMethod,
    );
    if (!mounted) return;
    if (error != null) {
      CustomToast.showError(context, error);
      return;
    }
    cart.clearCart();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptScreen(sale: sales.lastSale!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final sales = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Pembayaran'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text('Total Belanja',
              style: GoogleFonts.inter(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(cart.total),
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 24),
          ..._methods.map((m) {
            final selected = _method == m.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _method = m.$1),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected ? AppColors.navy : AppColors.border,
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m.$3, color: AppColors.navy, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m.$2,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _RadioDot(selected: selected),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_method == 'tunai') ...[
            const SizedBox(height: 8),
            Text('Nominal bayar',
                style: GoogleFonts.inter(
                    color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: _paidCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700, fontSize: 16),
              decoration: InputDecoration(
                prefixText: 'Rp ',
                filled: true,
                fillColor: AppColors.surfaceMuted,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Pastikan nominal bayar sesuai dengan total belanja.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
        child: NavyButton(
          label: 'Proses Pembayaran',
          isLoading: sales.isLoading,
          onPressed: _pay,
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool selected;
  const _RadioDot({required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.navy : AppColors.border,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.navy,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
