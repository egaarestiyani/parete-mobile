import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../app/main_tab_navigation.dart';
import '../../../complaints/presentation/screens/complaints_list_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../information/presentation/screens/information_screen.dart';
import '../../../shared/widgets/parete_logo.dart';

/// Beranda setelah pengguna menyelesaikan ganti kata sandi / data awal.
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _bannerIndex = 0;
  int _navIndex = 0;

  static const Color _headerBlue = Color(0xFF3A8FD9);
  static const Color _headerBlueLight = Color(0xFF5CB4F0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          Column(
            children: [
              _HeaderBlock(
                blue: _headerBlue,
                blueLight: _headerBlueLight,
                onNotificationTap: () {},
              ),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -18),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: _QuickActionsCard(
                            onPengaduanTap: () => Navigator.pushNamed(
                              context,
                              ComplaintsListScreen.routeName,
                            ),
                            onInformasiTap: () => Navigator.pushNamed(
                              context,
                              InformationScreen.routeName,
                            ),
                            onDokumenTap: () => Navigator.pushNamed(
                              context,
                              DocumentsScreen.routeName,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: _FeaturedBanner(
                            pageIndex: _bannerIndex,
                            onPageChanged: (i) => setState(() => _bannerIndex = i),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: _LatestSection(
                            onLihatSemua: () => Navigator.pushNamed(
                              context,
                              ComplaintsListScreen.routeName,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.md + 4,
            child: MainBottomNavBar(
              selectedIndex: _navIndex,
              onWillNavigate: (i) => setState(() => _navIndex = i),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.blue,
    required this.blueLight,
    required this.onNotificationTap,
  });

  final Color blue;
  final Color blueLight;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [blue, blueLight],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Pagi ☀️',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Yulian Adiprana',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onNotificationTap,
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.notifications_none_rounded, color: AppColors.primaryBlue, size: 22),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: TextField(
                  readOnly: true,
                  onTap: () {},
                  style: const TextStyle(
                    color: AppColors.darkBlueText,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Cari pengumuman, kegiatan, dll.',
                    hintStyle: TextStyle(
                      color: AppColors.mutedText.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF8C96AB)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({
    required this.onPengaduanTap,
    required this.onInformasiTap,
    required this.onDokumenTap,
  });

  final VoidCallback onPengaduanTap;
  final VoidCallback onInformasiTap;
  final VoidCallback onDokumenTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickActionItem(
            icon: Icons.edit_note_rounded,
            label: 'Pengaduan',
            onTap: onPengaduanTap,
          ),
          _QuickActionItem(
            icon: Icons.calendar_month_rounded,
            label: 'Informasi',
            onTap: onInformasiTap,
          ),
          _QuickActionItem(
            icon: Icons.description_rounded,
            label: 'Dokumen',
            onTap: onDokumenTap,
          ),
          const _QuickActionItem(icon: Icons.grid_view_rounded, label: 'Lainnya'),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.yellow,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 28),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlueText,
          ),
        ),
      ],
    );

    if (onTap == null) return child;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: child,
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.pageIndex, required this.onPageChanged});

  final int pageIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView(
              onPageChanged: onPageChanged,
              children: List.generate(3, (_) => const _BannerPage()),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final active = i == pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.yellow : const Color(0xFFD0D7E4),
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerPage extends StatelessWidget {
  const _BannerPage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryBlue,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PareteLogo(variant: PareteLogoVariant.light, height: 22),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Kerja Bakti Massal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Warga dihimbau hadir pada 5 Maret 2026 pukul 07.00 di area RT 05.',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text(
                    'Baca Selengkapnya',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            flex: 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ColoredBox(
                color: Colors.white.withValues(alpha: 0.15),
                child: const Center(
                  child: Icon(Icons.groups_rounded, color: Colors.white70, size: 56),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestSection extends StatelessWidget {
  const _LatestSection({required this.onLihatSemua});

  final VoidCallback onLihatSemua;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Terbaru',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
            ),
            TextButton(
              onPressed: onLihatSemua,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _LatestCard(),
          ),
        ),
      ],
    );
  }
}

class _LatestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lampu Jalan Gang Mawar Mati',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.darkBlueText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pengaduan • 5 Mar 2025',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Diproses',
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

