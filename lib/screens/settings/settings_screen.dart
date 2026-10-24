import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/kasir/kasir_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        leading: BackCircleButton(onPressed: () => Navigator.pop(context)),
        title: const Text('Pengaturan'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _section('Akun'),
          _tile(Icons.person_outline_rounded, 'Profil Kasir',
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint),
              subtitle: user?.email),
          _tile(Icons.lock_outline_rounded, 'Ganti Password',
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint)),
          const SizedBox(height: 20),
          _section('Aplikasi'),
          _tile(Icons.print_outlined, 'Printer',
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint)),
          _tile(
            Icons.volume_up_outlined,
            'Suara Notifikasi',
            trailing: Switch(
              value: _sound,
              onChanged: (v) => setState(() => _sound = v),
            ),
          ),
          _tile(Icons.contrast_outlined, 'Tema', trailing: Text('Terang',
              style: GoogleFonts.inter(color: AppColors.textSecondary))),
          const SizedBox(height: 20),
          _section('Tentang'),
          _tile(Icons.info_outline_rounded, 'Versi Aplikasi',
              trailing: Text('1.0.0',
                  style: GoogleFonts.inter(color: AppColors.textSecondary))),
          _tile(Icons.help_outline_rounded, 'Bantuan & Dukungan',
              trailing: const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textHint)),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _tile(IconData icon, String title,
      {Widget? trailing, String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.navy),
        title: Text(title,
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: subtitle == null
            ? null
            : Text(subtitle,
                style: GoogleFonts.inter(
                    fontSize: 12, color: AppColors.textSecondary)),
        trailing: trailing,
      ),
    );
  }
}
