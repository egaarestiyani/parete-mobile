import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_contact.dart';
import '../../../../core/constants/app_spacing.dart';

/// Bantuan & dukungan — kontak admin RT dan FAQ.
class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String routeName = '/help-support';

  static final Uri _waUri = AppContact.adminWhatsApp;
  static final Uri _emailUri = AppContact.adminEmail;
  static final Uri _instagramUri = Uri.parse('https://instagram.com/rt05_malabar');
  static final Uri _facebookUri = Uri.parse('https://facebook.com');

  Future<void> _launch(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!context.mounted) return;
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka tautan.')),
        );
      }
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka tautan.')),
      );
    }
  }

  void _showFaqAnswer(BuildContext context, String q, String a) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(q, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        content: Text(a, style: const TextStyle(height: 1.35)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Bantuan & Dukungan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Butuh bantuan? Hubungi kami',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      height: 1.25,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: () => _launch(context, _waUri),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.green,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: const Text('Chat Sekarang', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Masih bingung atau ada masalah dengan aplikasi? Jangan ragu untuk menghubungi kami ya. '
              'Admin Parete akan merespons pesanmu secepatnya 😊',
              style: TextStyle(
                color: AppColors.darkBlueText,
                fontWeight: FontWeight.w500,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Kontak',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _ContactTile(
                  icon: Icons.chat_rounded,
                  iconColor: const Color(0xFF25D366),
                  title: 'WhatsApp',
                  subtitle: '+62 890 7654 321',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EC),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Cepat',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  onTap: () => _launch(context, _waUri),
                ),
                const Divider(height: 1),
                _ContactTile(
                  icon: Icons.email_outlined,
                  iconColor: AppColors.primaryBlue,
                  title: 'Email',
                  subtitle: 'rt05.malabar@email.com',
                  onTap: () => _launch(context, _emailUri),
                ),
                const Divider(height: 1),
                _ContactTile(
                  icon: Icons.camera_alt_outlined,
                  iconColor: const Color(0xFFE1306C),
                  title: 'Instagram',
                  subtitle: '@rt05_malabar',
                  onTap: () => _launch(context, _instagramUri),
                ),
                const Divider(height: 1),
                _ContactTile(
                  icon: Icons.public_rounded,
                  iconColor: AppColors.primaryBlue,
                  title: 'Facebook',
                  subtitle: 'RT 05 Malabar Ujung',
                  onTap: () => _launch(context, _facebookUri),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warningText.withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.warningText, size: 20),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Pesan akan dibalas di jam operasional pada hari kerja.',
                    style: TextStyle(
                      color: AppColors.warningText,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Pertanyaan Umum',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.darkBlueText,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _FaqTile(
                  question: 'Bagaimana cara mendapatkan ID?',
                  onTap: () => _showFaqAnswer(
                    context,
                    'Bagaimana cara mendapatkan ID?',
                    'ID Keluarga diberikan saat pendaftaran warga di admin RT. Silakan hubungi pengurus RT jika belum memiliki ID.',
                  ),
                ),
                const Divider(height: 1),
                _FaqTile(
                  question: 'Lupa password, apa yang harus dilakukan?',
                  onTap: () => _showFaqAnswer(
                    context,
                    'Lupa password, apa yang harus dilakukan?',
                    'Gunakan fitur reset kata sandi di layar masuk, atau hubungi admin RT untuk bantuan verifikasi.',
                  ),
                ),
                const Divider(height: 1),
                _FaqTile(
                  question: 'Berapa lama pengaduan ditanggapi?',
                  onTap: () => _showFaqAnswer(
                    context,
                    'Berapa lama pengaduan ditanggapi?',
                    'Target tanggapan awal 1–3 hari kerja, tergantung jenis dan beban pengaduan.',
                  ),
                ),
                const Divider(height: 1),
                _FaqTile(
                  question: 'Apakah data saya aman di Parete?',
                  onTap: () => _showFaqAnswer(
                    context,
                    'Apakah data saya aman di Parete?',
                    'Data warga digunakan hanya untuk keperluan administrasi RT sesai kebijakan privasi aplikasi.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Center(
            child: Text(
              'Parete v1.0.0',
              style: TextStyle(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      leading: Icon(icon, color: iconColor, size: 26),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          if (trailing != null) const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.onTap});

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, height: 1.3),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
      onTap: onTap,
    );
  }
}
