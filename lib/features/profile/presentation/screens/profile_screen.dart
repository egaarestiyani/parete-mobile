import 'package:flutter/material.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'help_support_screen.dart';

/// Profil warga / kepala keluarga.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  Future<void> _confirmLogout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda yakin ingin keluar?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkBlueText,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    height: 1.35,
                  ),
                ),
                const Divider(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Ya',
                    style: TextStyle(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Divider(height: 1),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (ok == true && context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        LoginScreen.routeName,
        (route) => false,
      );
    }
  }

  void _showAboutParete(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Parete',
      applicationVersion: 'v1.0.0',
      applicationIcon: const Icon(Icons.apartment_rounded, size: 40, color: AppColors.primaryBlue),
      children: const [
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Aplikasi layanan warga RT untuk pengumuman, pengaduan, dan dokumen resmi.',
            style: TextStyle(height: 1.35),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const headerBlue = Color(0xFF2E7DBC);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: headerBlue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 28),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white.withValues(alpha: 0.95),
                          child: const Icon(Icons.person_rounded, size: 48, color: AppColors.primaryBlue),
                        ),
                        Positioned(
                          child: Material(
                            color: AppColors.yellow,
                            shape: const CircleBorder(),
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () {},
                              child: const Padding(
                                padding: EdgeInsets.all(6),
                                child: Icon(Icons.camera_alt_rounded, size: 16, color: AppColors.darkBlueText),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Yulian Adiprana',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _BadgeChip(label: 'RT. 05'),
                        const SizedBox(width: 8),
                        _BadgeChip(label: 'No. 87'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cardShadow,
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: _StatMini(value: '5', label: 'Pengaduan', valueColor: AppColors.primaryBlue),
                        ),
                        Expanded(
                          child: _StatMini(value: '3', label: 'Selesai', valueColor: AppColors.green),
                        ),
                        Expanded(
                          child: _StatMini(value: '2', label: 'Aktif', valueColor: Color(0xFFE58A00)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: 'Informasi Pribadi',
                    children: [
                      _InfoRow(label: 'Nama Kepala Keluarga', value: 'Yulian Adiprana'),
                      const Divider(height: 1),
                      _InfoRow(label: 'No. Rumah', value: '87'),
                      const Divider(height: 1),
                      _InfoRow(
                        label: 'No. HP',
                        value: '+62 812 3456 7890',
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _InfoRow(
                        label: 'ID Keluarga',
                        value: 'RT05-2026-087',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Aktif',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: 'Pengaturan Akun',
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Ubah Password',
                        onTap: () => Navigator.pushNamed(context, ChangePasswordScreen.routeName),
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notifikasi',
                        subtitle: 'Aktif',
                        onTap: () {},
                      ),
                      const Divider(height: 1),
                      _SettingsTile(
                        icon: Icons.headset_mic_outlined,
                        title: 'Bantuan & Dukungan',
                        onTap: () => Navigator.pushNamed(context, HelpSupportScreen.routeName),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: 'Tentang',
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Tentang Parete',
                        subtitle: 'v1.0.0',
                        onTap: () => _showAboutParete(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: () => _confirmLogout(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: const MainBottomNavBar(selectedIndex: 4),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({required this.value, required this.label, required this.valueColor});

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.darkBlueText,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlueText,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryBlue, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
      onTap: onTap,
    );
  }
}
