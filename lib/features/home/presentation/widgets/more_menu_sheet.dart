import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../documents/presentation/screens/document_submission_screen.dart';
import '../../../profile/presentation/screens/help_support_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';

/// Menu layanan tambahan (tombol **Lainnya** di beranda).
class MoreMenuSheet extends StatelessWidget {
  const MoreMenuSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const MoreMenuSheet(),
    );
  }

  void _go(BuildContext context, String routeName) {
    Navigator.pop(context);
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Menu lainnya',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Layanan RT tambahan di luar menu utama',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedText.withValues(alpha: 0.95),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _MoreMenuTile(
              icon: Icons.person_outline_rounded,
              title: 'Profil saya',
              subtitle: 'Data keluarga & pengaturan akun',
              onTap: () => _go(context, ProfileScreen.routeName),
            ),
            _MoreMenuTile(
              icon: Icons.assignment_outlined,
              title: 'Ajukan permohonan dokumen',
              subtitle: 'Surat keterangan, domisili, dan lainnya',
              onTap: () => _go(context, DocumentSubmissionScreen.routeName),
            ),
            _MoreMenuTile(
              icon: Icons.search_rounded,
              title: 'Pencarian',
              subtitle: 'Cari pengumuman, pengaduan, dokumen',
              onTap: () => _go(context, SearchScreen.routeName),
            ),
            _MoreMenuTile(
              icon: Icons.lock_outline_rounded,
              title: 'Ganti kata sandi',
              subtitle: 'Perbarui sandi akun warga',
              onTap: () => _go(context, ChangePasswordScreen.routeName),
            ),
            _MoreMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Bantuan & dukungan',
              subtitle: 'Hubungi pengurus RT',
              onTap: () => _go(context, HelpSupportScreen.routeName),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreMenuTile extends StatelessWidget {
  const _MoreMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 4,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primaryBlue, size: 24),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.darkBlueText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mutedText.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
