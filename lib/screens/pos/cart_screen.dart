// lib/screens/pos/cart_screen.dart
// Layar keranjang — light mode premium

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/sale_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/custom_toast.dart';
import '../../widgets/pos/cart_item_tile.dart';
import 'receipt_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});
  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'tunai';
  final _noteCtrl = TextEditingController();

  final _methods = [
    {'value': 'tunai',    'label': 'Tunai',    'icon': Icons.money},
    {'value': 'transfer', 'label': 'Transfer', 'icon': Icons.account_balance},
    {'value': 'ewallet',  'label': 'E-Wallet', 'icon': Icons.phone_android},
  ];

  @override
  void dispose() { _noteCtrl.dispose(); super.dispose(); }

  void _onPayPressed() {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;

    if (_paymentMethod == 'transfer') {
      _showTransferPaymentSheet();
    } else if (_paymentMethod == 'ewallet') {
      _showEwalletPaymentSheet();
    } else {
      _checkout();
    }
  }

  Future<void> _checkout() async {
    final cart  = context.read<CartProvider>();
    final sales = context.read<SaleProvider>();
    if (cart.isEmpty) return;
    final error = await sales.createSale(
      items: cart.toApiItems(), paymentMethod: _paymentMethod,
      notes: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
    );
    if (!mounted) return;
    if (error != null) {
      CustomToast.showError(context, error);
      return;
    }
    cart.clearCart();
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => ReceiptScreen(sale: sales.lastSale!)));
  }

  void _showTransferPaymentSheet() {
    final cart = context.read<CartProvider>();
    final formattedTotal = CurrencyFormatter.format(cart.total);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pembayaran Transfer',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              Text(
                'TOTAL PEMBAYARAN',
                style: GoogleFonts.poppins(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedTotal,
                    style: GoogleFonts.poppins(
                      color: AppColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: cart.total.toInt().toString()));
                      CustomToast.showSuccess(context, 'Total disalin!');
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                    label: Text(
                      'Salin',
                      style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.pastelIndigo.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'BANK BCA',
                          style: GoogleFonts.poppins(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No. Rekening:',
                      style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '8620-4829-11',
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(const ClipboardData(text: '8620482911'));
                            CustomToast.showSuccess(context, 'No. Rekening disalin!');
                          },
                          icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.primary),
                          label: Text(
                            'Salin',
                            style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Atas Nama: SIMKEU APPS',
                      style: GoogleFonts.poppins(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Petunjuk Transfer:',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildStepRow('1', 'Transfer sesuai nominal tagihan.'),
              _buildStepRow('2', 'Pastikan nama penerima adalah SIMKEU APPS.'),
              _buildStepRow('3', 'Setelah berhasil, klik tombol Konfirmasi di bawah.'),
              const SizedBox(height: 24),
              AppButton(
                label: 'Konfirmasi Pembayaran',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  _checkout();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Kembali',
                color: AppColors.surfaceLight,
                textColor: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEwalletPaymentSheet() {
    final cart = context.read<CartProvider>();
    final formattedTotal = CurrencyFormatter.format(cart.total);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pembayaran E-Wallet / QRIS',
                    style: GoogleFonts.poppins(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textHint),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: AppColors.border, height: 24),
              Text(
                'TOTAL PEMBAYARAN',
                style: GoogleFonts.poppins(
                  color: AppColors.textHint,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formattedTotal,
                style: GoogleFonts.poppins(
                  color: AppColors.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(176, 176),
                        painter: _QRISMockPainter(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          'QRIS',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Tunjukkan kode QRIS di atas kepada pelanggan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Petunjuk Pembayaran:',
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildStepRow('1', 'Buka aplikasi e-wallet (GoPay, OVO, Dana, LinkAja, dll).'),
              _buildStepRow('2', 'Pindai kode QRIS di atas.'),
              _buildStepRow('3', 'Setelah pembayaran berhasil terkonfirmasi, klik tombol di bawah.'),
              const SizedBox(height: 24),
              AppButton(
                label: 'Konfirmasi Pembayaran',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  Navigator.pop(context);
                  _checkout();
                },
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Kembali',
                color: AppColors.surfaceLight,
                textColor: AppColors.textPrimary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 2, right: 8),
            decoration: const BoxDecoration(
              color: AppColors.pastelIndigo,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: AppColors.primary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    final cart  = context.watch<CartProvider>();
    final sales = context.watch<SaleProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0, surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context)),
        title: Text('Keranjang', style: GoogleFonts.poppins(
          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
        actions: [
          if (!cart.isEmpty) TextButton(
            onPressed: () => _confirmClear(context, cart),
            child: Text('Kosongkan', style: GoogleFonts.poppins(color: AppColors.error, fontSize: 13))),
        ],
      ),
      body: cart.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(color: AppColors.surfaceLight, shape: BoxShape.circle),
              child: const Icon(Icons.shopping_cart_outlined, color: AppColors.textHint, size: 48)),
            const SizedBox(height: 16),
            Text('Keranjang kosong', style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 15)),
          ]))
        : Column(children: [
            Expanded(child: ListView(padding: const EdgeInsets.all(20), children: [
              ...cart.items.map((item) => CartItemTile(item: item,
                onIncrease: () => cart.increaseQuantity(item.product.id),
                onDecrease: () => cart.decreaseQuantity(item.product.id),
                onRemove: () => cart.removeItem(item.product.id))),
              const SizedBox(height: 20),
              Text('Metode Pembayaran', style: GoogleFonts.poppins(
                color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: _methods.map((m) {
                final isSel = _paymentMethod == m['value'];
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _paymentMethod = m['value'] as String),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.pastelIndigo : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? AppColors.primary : AppColors.border, width: isSel ? 1.5 : 1),
                      boxShadow: isSel ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 8)] : null,
                    ),
                    child: Column(children: [
                      Icon(m['icon'] as IconData, color: isSel ? AppColors.primary : AppColors.textHint, size: 22),
                      const SizedBox(height: 4),
                      Text(m['label'] as String, style: GoogleFonts.poppins(
                        color: isSel ? AppColors.primary : AppColors.textHint, fontSize: 11, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 16),
              Text('Catatan (opsional)', style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(controller: _noteCtrl, maxLines: 2,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Tambahkan catatan...', hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
                  filled: true, fillColor: AppColors.surfaceLight,
                  contentPadding: const EdgeInsets.all(14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                )),
            ])),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.surface,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -4))]),
              child: Column(children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Total (${cart.itemCount} item)', style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 13)),
                  Text(CurrencyFormatter.format(cart.total), style: GoogleFonts.poppins(
                    color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                const SizedBox(height: 14),
                AppButton(label: 'Bayar Sekarang', icon: Icons.payment_rounded,
                  isLoading: sales.isLoading, onPressed: _onPayPressed),
              ]),
            ),
          ]),
    );
  }

  void _confirmClear(BuildContext ctx, CartProvider cart) {
    showDialog(context: ctx, builder: (_) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Kosongkan Keranjang?', style: GoogleFonts.poppins(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      content: Text('Semua item akan dihapus.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx),
          child: Text('Batal', style: GoogleFonts.poppins(color: AppColors.textSecondary))),
        TextButton(onPressed: () { cart.clearCart(); Navigator.pop(ctx); Navigator.pop(ctx); },
          child: Text('Kosongkan', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600))),
      ],
    ));
  }
}

class _QRISMockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textPrimary.withOpacity(0.85)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    _drawFinderPattern(canvas, paint, 0, 0, 45);
    _drawFinderPattern(canvas, paint, w - 45, 0, 45);
    _drawFinderPattern(canvas, paint, 0, h - 45, 45);

    final rand = [
      Rect.fromLTWH(w - 30, 60, 10, 10),
      Rect.fromLTWH(w - 20, 80, 8, 12),
      Rect.fromLTWH(60, h - 30, 10, 10),
      Rect.fromLTWH(80, h - 20, 12, 8),
      Rect.fromLTWH(60, 60, 15, 15),
      Rect.fromLTWH(90, 60, 8, 8),
      Rect.fromLTWH(60, 90, 8, 8),
      Rect.fromLTWH(110, 75, 10, 15),
      Rect.fromLTWH(75, 110, 15, 10),
      Rect.fromLTWH(100, 100, 15, 15),
      Rect.fromLTWH(w - 60, h - 60, 20, 20),
      Rect.fromLTWH(w - 80, 90, 10, 15),
      Rect.fromLTWH(90, h - 80, 15, 10),
    ];

    for (final rect in rand) {
      canvas.drawRect(rect, paint);
    }
  }

  void _drawFinderPattern(Canvas canvas, Paint paint, double x, double y, double size) {
    canvas.drawRect(Rect.fromLTWH(x, y, size, size), paint);
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(x + 6, y + 6, size - 12, size - 12), whitePaint);
    canvas.drawRect(Rect.fromLTWH(x + 12, y + 12, size - 24, size - 24), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
