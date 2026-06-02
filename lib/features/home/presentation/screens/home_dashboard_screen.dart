import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/informasi_model.dart';
import '../../../../core/models/pengaduan_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/dashboard_service.dart';
import '../../../../core/services/informasi_service.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/utils/greeting_helper.dart';
import '../../../complaints/presentation/screens/complaints_list_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../information/presentation/screens/informasi_detail_screen.dart';
import '../../../information/presentation/screens/information_screen.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../widgets/more_menu_sheet.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../../../shared/widgets/parete_network_image.dart';

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
  bool _loading = true;
  String? _error;
  List<InformasiModel> _informasiBanner = [];
  List<PengaduanModel> _pengaduanTerbaru = [];

  static const Color _headerBlue = AppColors.primaryBlue;
  static const Color _headerBlueLight = AppColors.primaryBlueLight;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthService>();
      await auth.refreshWarga();
      final api = auth.api;
      final dash = await DashboardService(api).fetch();
      var informasi = _hanyaPengumuman(dash.informasi);
      if (informasi.isEmpty) {
        try {
          informasi = _hanyaPengumuman(
            await InformasiService(api).fetch(jenis: InformasiJenis.pengumuman),
          );
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _informasiBanner = informasi;
        _pengaduanTerbaru = dash.pengaduan;
        _bannerIndex = 0;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      try {
        final auth = context.read<AuthService>();
        final informasi = _hanyaPengumuman(
          await InformasiService(auth.api).fetch(jenis: InformasiJenis.pengumuman),
        );
        if (!mounted) return;
        setState(() {
          _informasiBanner = informasi;
          _pengaduanTerbaru = [];
          _bannerIndex = 0;
          _loading = false;
          _error = informasi.isEmpty ? e.toString().replaceFirst('Exception: ', '') : null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  List<InformasiModel> _hanyaPengumuman(List<InformasiModel> items) {
    return items.where((e) => e.jenis == InformasiJenis.pengumuman).toList();
  }

  void _openInformasiDetail(InformasiModel item) {
    Navigator.pushNamed(
      context,
      InformasiDetailScreen.routeName,
      arguments: item,
    );
  }

  @override
  Widget build(BuildContext context) {
    final namaWarga = context.watch<AuthService>().warga?.namaKepalaKeluarga ?? 'Warga';

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _HeaderBlock(
                blue: _headerBlue,
                blueLight: _headerBlueLight,
                namaWarga: namaWarga,
                onNotificationTap: () {},
                onSearchTap: () => Navigator.pushNamed(context, SearchScreen.routeName),
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
                            onLainnyaTap: () => MoreMenuSheet.show(context),
                          ),
                        ),
                        if (_loading)
                          const Padding(
                            padding: EdgeInsets.all(AppSpacing.xl),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else ...[
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: Material(
                                color: AppColors.warningBg,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _error!,
                                          style: const TextStyle(
                                            color: AppColors.warningText,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: _loadDashboard,
                                        child: const Text('Muat ulang'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          if (_informasiBanner.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.md),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                              child: _FeaturedBanner(
                                items: _informasiBanner,
                                pageIndex: _bannerIndex,
                                onPageChanged: (i) => setState(() => _bannerIndex = i),
                                onBacaSelengkapnya: _openInformasiDetail,
                              ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            child: _LatestSection(
                              items: _pengaduanTerbaru,
                              onLihatSemua: () => Navigator.pushNamed(
                                context,
                                ComplaintsListScreen.routeName,
                              ),
                            ),
                          ),
                        ],
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
    required this.namaWarga,
    required this.onNotificationTap,
    required this.onSearchTap,
  });

  final Color blue;
  final Color blueLight;
  final String namaWarga;
  final VoidCallback onNotificationTap;
  final VoidCallback onSearchTap;

  @override
  Widget build(BuildContext context) {
    final greeting = greetingForTime();

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
                        Text(
                          greeting.full,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          namaWarga,
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
                  onTap: onSearchTap,
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
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.iconMuted),
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
    required this.onLainnyaTap,
  });

  final VoidCallback onPengaduanTap;
  final VoidCallback onInformasiTap;
  final VoidCallback onDokumenTap;
  final VoidCallback onLainnyaTap;

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
          _QuickActionItem(
            icon: Icons.grid_view_rounded,
            label: 'Lainnya',
            onTap: onLainnyaTap,
          ),
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
  const _FeaturedBanner({
    required this.items,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onBacaSelengkapnya,
  });

  final List<InformasiModel> items;
  final int pageIndex;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<InformasiModel> onBacaSelengkapnya;

  @override
  Widget build(BuildContext context) {
    final count = items.length;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: PageView.builder(
              onPageChanged: onPageChanged,
              itemCount: count,
              itemBuilder: (context, index) => _BannerPage(
                item: items[index],
                onBacaSelengkapnya: () => onBacaSelengkapnya(items[index]),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final active = i == pageIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: active ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.yellow : AppColors.progressInactive,
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
  const _BannerPage({
    required this.item,
    required this.onBacaSelengkapnya,
  });

  final InformasiModel item;
  final VoidCallback onBacaSelengkapnya;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            flex: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const PareteLogo(variant: PareteLogoVariant.light, height: 20),
                const SizedBox(height: 6),
                Text(
                  item.judul,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    item.ringkasan,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton(
                  onPressed: onBacaSelengkapnya,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryBlue,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                  ),
                  child: const Text(
                    'Baca Selengkapnya',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
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
              child: PareteNetworkImage(
                url: item.gambarUrl,
                placeholderIcon: item.jenis == InformasiJenis.kegiatan
                    ? Icons.groups_rounded
                    : Icons.campaign_outlined,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestSection extends StatelessWidget {
  const _LatestSection({
    required this.items,
    required this.onLihatSemua,
  });

  final List<PengaduanModel> items;
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
        if (items.isEmpty)
          Text(
            'Belum ada pengaduan terbaru.',
            style: TextStyle(
              color: AppColors.mutedText.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          )
        else
          ...items.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _LatestCard(pengaduan: p),
            ),
          ),
      ],
    );
  }
}

class _LatestCard extends StatelessWidget {
  const _LatestCard({required this.pengaduan});

  final PengaduanModel pengaduan;

  String get _statusLabel => switch (pengaduan.status) {
        ComplaintStatusUi.terkirim => 'Terkirim',
        ComplaintStatusUi.diterima => 'Diterima',
        ComplaintStatusUi.diproses => 'Diproses',
        ComplaintStatusUi.selesai => 'Selesai',
        ComplaintStatusUi.ditolak => 'Ditolak',
        ComplaintStatusUi.dibatalkan => 'Dibatalkan',
      };

  String get _dateLabel {
    final d = pengaduan.tanggalDibuat;
    if (d == null) return '-';
    return ApiDate.formatDate(d);
  }

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
                Text(
                  pengaduan.judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.darkBlueText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pengaduan • $_dateLabel',
                  style: const TextStyle(
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
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _statusLabel,
              style: const TextStyle(
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

