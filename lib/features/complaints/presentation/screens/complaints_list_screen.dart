import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/pengaduan_model.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/pengaduan_service.dart';
import '../../../shared/widgets/parete_page_header.dart';
import 'create_complaint_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  static const String routeName = '/complaints';

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  int _tabIndex = 0;
  bool _loading = true;
  String? _error;
  List<PengaduanModel> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthService>().api;
      final items = await PengaduanService(api).fetch();
      if (!mounted) return;
      setState(() {
        _all = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  List<PengaduanModel> get _visible {
    switch (_tabIndex) {
      case 1:
        return _all.where((e) => e.isActive).toList();
      case 2:
        return _all
            .where(
              (e) =>
                  e.status == ComplaintStatusUi.selesai ||
                  e.status == ComplaintStatusUi.ditolak ||
                  e.status == ComplaintStatusUi.dibatalkan,
            )
            .toList();
      default:
        return _all;
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.pushNamed(context, CreateComplaintScreen.routeName);
    if (created == true) _load();
  }

  Future<void> _openEdit(PengaduanModel item) async {
    final ok = await Navigator.pushNamed(
      context,
      CreateComplaintScreen.routeName,
      arguments: item,
    );
    if (ok == true) _load();
  }

  Future<void> _batalkan(PengaduanModel item) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pengaduan?'),
        content: const Text(
          'Pengaduan yang dibatalkan tidak dapat diproses oleh Admin RT.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Tidak')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (ya != true || !mounted) return;
    try {
      await PengaduanService(context.read<AuthService>().api).batalkan(item.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaduan berhasil dibatalkan.')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _showDetail(PengaduanModel item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              item.judul,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.nomorPengaduan,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(item.deskripsi, style: const TextStyle(height: 1.4)),
            if (item.alasanDitolak != null && item.alasanDitolak!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Alasan ditolak: ${item.alasanDitolak}',
                style: const TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600),
              ),
            ],
            if (item.canEdit || item.canBatalkan) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  if (item.canEdit)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _openEdit(item);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Ubah'),
                      ),
                    ),
                  if (item.canEdit && item.canBatalkan) const SizedBox(width: AppSpacing.sm),
                  if (item.canBatalkan)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _batalkan(item);
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Batalkan'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PareteTabbedPageHeader(
            title: 'Pengaduan',
            tabLabels: const ['Semua', 'Aktif', 'Selesai'],
            tabIndex: _tabIndex,
            onTabChanged: (i) => setState(() => _tabIndex = i),
            actions: [
              IconButton(
                onPressed: _openCreate,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                tooltip: 'Buat pengaduan',
              ),
            ],
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, textAlign: TextAlign.center),
                              const SizedBox(height: AppSpacing.md),
                              FilledButton(onPressed: _load, child: const Text('Coba lagi')),
                            ],
                          ),
                        ),
                      )
                    : _visible.isEmpty
                        ? const Center(child: Text('Belum ada pengaduan.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              itemCount: _visible.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) => _ComplaintCard(
                                item: _visible[i],
                                onTap: () => _showDetail(_visible[i]),
                              ),
                            ),
                          ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: const MainBottomNavBar(selectedIndex: 2),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.item, this.onTap});

  final PengaduanModel item;
  final VoidCallback? onTap;

  Color get _accent {
    switch (item.status) {
      case ComplaintStatusUi.diproses:
        return AppColors.primaryBlue;
      case ComplaintStatusUi.diterima:
      case ComplaintStatusUi.terkirim:
        return const Color(0xFFE58A00);
      case ComplaintStatusUi.selesai:
        return AppColors.green;
      case ComplaintStatusUi.ditolak:
        return const Color(0xFFE53935);
      case ComplaintStatusUi.dibatalkan:
        return AppColors.mutedText;
    }
  }

  ({Color bg, Color fg}) get _badge {
    switch (item.status) {
      case ComplaintStatusUi.diproses:
        return (bg: AppColors.lightBlueBg, fg: AppColors.primaryBlue);
      case ComplaintStatusUi.diterima:
      case ComplaintStatusUi.terkirim:
        return (bg: const Color(0xFFFFF3D6), fg: const Color(0xFFE58A00));
      case ComplaintStatusUi.selesai:
        return (bg: const Color(0xFFE8F8EB), fg: AppColors.green);
      case ComplaintStatusUi.ditolak:
        return (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFE53935));
      case ComplaintStatusUi.dibatalkan:
        return (bg: const Color(0xFFF0F2F7), fg: AppColors.mutedText);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ComplaintStatusUi.diproses:
        return 'Diproses';
      case ComplaintStatusUi.diterima:
        return 'Diterima';
      case ComplaintStatusUi.terkirim:
        return 'Terkirim';
      case ComplaintStatusUi.selesai:
        return 'Selesai';
      case ComplaintStatusUi.ditolak:
        return 'Ditolak';
      case ComplaintStatusUi.dibatalkan:
        return 'Dibatalkan';
    }
  }

  String get _dateLabel {
    final d = item.tanggalDibuat;
    if (d == null) return '-';
    return ApiDate.formatDate(d);
  }

  IconData get _categoryIcon {
    switch (item.topik) {
      case 'Kebersihan':
        return Icons.cleaning_services_outlined;
      case 'Keamanan':
        return Icons.shield_outlined;
      case 'Sosial':
        return Icons.groups_2_outlined;
      default:
        return Icons.apartment_outlined;
    }
  }

  String get _nomorLabel {
    final n = item.nomorPengaduan.trim();
    if (n.isEmpty) return '#—';
    return n.startsWith('#') ? n : '#$n';
  }

  @override
  Widget build(BuildContext context) {
    final b = _badge;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.cardShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 4,
                    color: _accent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _nomorLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: b.bg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    color: b.fg,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            item.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.darkBlueText,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item.deskripsi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              Icon(
                                _categoryIcon,
                                size: 16,
                                color: AppColors.mutedText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                item.topik,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _dateLabel,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: AppColors.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

