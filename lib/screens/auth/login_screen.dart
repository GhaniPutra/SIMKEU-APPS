// lib/screens/auth/login_screen.dart
// Layar login pegawai — desain light mode premium

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../dashboard/dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!mounted) return;
    if (success) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const DashboardScreen(),
          transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildLogo(),
                    const SizedBox(height: 28),
                    Text('SIMKEU POS', style: GoogleFonts.poppins(
                      color: AppColors.textPrimary, fontSize: 28,
                      fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                    const SizedBox(height: 6),
                    Text('Sistem Informasi Keuangan', style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 14)),
                    const SizedBox(height: 48),
                    _buildFormCard(),
                    const SizedBox(height: 32),
                    Text('SIMKEU v1.0 • Hanya untuk Pegawai',
                      style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 48),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Masuk ke Akun', style: GoogleFonts.poppins(
            color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          Text('Silakan login dengan akun pegawai Anda', style: GoogleFonts.poppins(
            color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 24),
          Consumer<AuthProvider>(builder: (_, auth, __) => AppTextField(
            label: 'Email', hint: 'pegawai@simkeu.com', controller: _emailCtrl,
            prefixIcon: Icons.email_outlined, keyboardType: TextInputType.emailAddress,
            enabled: !auth.isLoading,
            onChanged: (_) { if (auth.errorMessage != null) auth.clearError(); },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Email wajib diisi';
              if (!v.contains('@')) return 'Format email tidak valid';
              return null;
            },
          )),
          const SizedBox(height: 16),
          Consumer<AuthProvider>(builder: (_, auth, __) => AppTextField(
            label: 'Password', hint: '••••••••', controller: _passwordCtrl,
            prefixIcon: Icons.lock_outline, obscureText: true, enabled: !auth.isLoading,
            onChanged: (_) { if (auth.errorMessage != null) auth.clearError(); },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Password wajib diisi';
              if (v.length < 6) return 'Password minimal 6 karakter';
              return null;
            },
          )),
          const SizedBox(height: 24),
          _buildErrorMessage(),
          Consumer<AuthProvider>(builder: (_, auth, __) => AppButton(
            label: 'Masuk', icon: Icons.login_rounded,
            isLoading: auth.isLoading, onPressed: _handleLogin,
          )),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Consumer<AuthProvider>(builder: (_, auth, __) {
      if (auth.errorMessage == null) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.pastelRed,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withOpacity(0.2)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), shape: BoxShape.circle),
            child: const Icon(Icons.error_outline, color: AppColors.error, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(auth.errorMessage!, style: GoogleFonts.poppins(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500)),
            if (auth.errorMessage!.contains('koneksi') || auth.errorMessage!.contains('server'))
              Padding(padding: const EdgeInsets.only(top: 6),
                child: Text('Pastikan WiFi/data aktif atau coba lagi',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 11))),
          ])),
        ]),
      );
    });
  }
}
