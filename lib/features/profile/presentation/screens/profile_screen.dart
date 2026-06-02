import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/pengaduan_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/pengaduan_service.dart';
import '../../../../core/utils/phone_number.dart';
import '../../../../core/utils/warga_display.dart';
import '../../../shared/widgets/parete_phone_field.dart';
import '../../../auth/presentation/screens/change_password_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'help_support_screen.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../../../shared/widgets/parete_page_header.dart';

/// Profil warga / kepala keluarga.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loadingStats = true;
  int _totalPengaduan = 0;
  int _pengaduanAktif = 0;
  int _pengaduanSelesai = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await context.read<AuthService>().refreshWarga();
    await _loadPengaduanStats();
  }

  Future<void> _editNomorHp() async {
    final auth = context.read<AuthService>();
    final controller = TextEditingController(
      text: PhoneNumberUtil.localPartFromStored(auth.warga?.nomorHp),
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nomor HP'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Nomor akan disimpan format +62 dan tampil sama di web admin.',
                style: TextStyle(fontSize: 12, color: AppColors.mutedText, height: 1.35),
              ),
              const SizedBox(height: AppSpacing.md),
              ParetePhoneField(
                controller: controller,
                hint: '81291497170',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Simpan')),
        ],
      ),
    );
    if (saved != true || !mounted) return;
    try {
      await auth.updateNomorHp(controller.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor HP diperbarui dan tersimpan di data RT.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
    controller.dispose();
  }

  Future<void> _loadPengaduanStats() async {
    setState(() => _loadingStats = true);
    try {
      final api = context.read<AuthService>().api;
      final all = await PengaduanService(api).fetch();
      if (!mounted) return;
      final stats = PengaduanStats.fromList(all);
      setState(() {
        _totalPengaduan = stats.total;
        _pengaduanAktif = stats.aktif;
        _pengaduanSelesai = stats.selesai;
        _loadingStats = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStats = false);
    }
  }

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
      await context.read<AuthService>().logout();
      if (!context.mounted) return;
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
      applicationIcon: const PareteLogo(variant: PareteLogoVariant.dark, height: 40),
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
    final warga = context.watch<AuthService>().warga;
    final nama = warga?.namaKepalaKeluarga ?? 'Warga';
    final idKeluarga = warga?.idKeluarga ?? '-';
    final nomorHp = PhoneNumberUtil.formatDisplay(warga?.nomorHp);
    final rtLabel = WargaDisplay.rtLabel(idKeluarga);
    final noRumahLabel = WargaDisplay.nomorRumahLabel(warga?.nomorRumah ?? '-');
    final statusAkun = warga?.statusAkun ?? 'Aktif';
    final statusAktif = statusAkun.toLowerCase() == 'aktif';
    final alamat = warga?.alamatLengkap ?? '';
    final alamatLabel = alamat.isEmpty ? '-' : alamat;

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PareteProfilePageHeader(
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
                Text(
                  nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BadgeChip(label: rtLabel),
                    const SizedBox(width: 8),
                    _BadgeChip(label: noRumahLabel),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _bootstrap,
              child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatMini(
                            value: _loadingStats ? '…' : '$_totalPengaduan',
                            label: 'Pengaduan',
                            valueColor: AppColors.primaryBlue,
                          ),
                        ),
                        Expanded(
                          child: _StatMini(
                            value: _loadingStats ? '…' : '$_pengaduanSelesai',
                            label: 'Selesai',
                            valueColor: AppColors.green,
                          ),
                        ),
                        Expanded(
                          child: _StatMini(
                            value: _loadingStats ? '…' : '$_pengaduanAktif',
                            label: 'Aktif',
                            valueColor: const Color(0xFFE58A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: 'Informasi Pribadi',
                    children: [
                      _InfoRow(label: 'Nama Kepala Keluarga', value: nama),
                      const Divider(height: 1),
                      _InfoRow(label: 'No. Rumah', value: warga?.nomorRumah ?? '-'),
                      const Divider(height: 1),
                      _InfoRow(
                        label: 'No. HP',
                        value: nomorHp,
                        trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
                        onTap: _editNomorHp,
                      ),
                      const Divider(height: 1),
                      _InfoRow(label: 'Alamat', value: alamatLabel),
                      const Divider(height: 1),
                      _InfoRow(
                        label: 'ID Keluarga',
                        value: idKeluarga,
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F8EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            statusAkun,
                            style: TextStyle(
                              color: statusAktif ? AppColors.green : AppColors.mutedText,
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
                        subtitle: statusAkun,
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
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: MainBottomNavBar(
          selectedIndex: 4,
          onWillNavigate: (index) {
            if (index == 4) _loadPengaduanStats();
          },
        ),
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
