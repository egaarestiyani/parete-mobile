import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/pengaduan_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/pengaduan_service.dart';
import 'create_complaint_screen.dart';

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  static const String routeName = '/complaints';

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  static const Color _headerBlue = Color(0xFF3A8FD9);

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
            .where((e) => e.status == ComplaintStatusUi.selesai || e.status == ComplaintStatusUi.ditolak)
            .toList();
      default:
        return _all;
    }
  }

  Future<void> _openCreate() async {
    final created = await Navigator.pushNamed(context, CreateComplaintScreen.routeName);
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _headerBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Pengaduan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: _openCreate,
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Buat pengaduan',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _headerBlue,
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            child: _ComplaintTabs(
              index: _tabIndex,
              onChanged: (i) => setState(() => _tabIndex = i),
            ),
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
                              itemBuilder: (context, i) => _ComplaintCard(item: _visible[i]),
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

class _ComplaintTabs extends StatelessWidget {
  const _ComplaintTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = ['Semua', 'Aktif', 'Selesai'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final selected = i == index;
          return Expanded(
            child: Material(
              color: selected ? AppColors.yellow : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              child: InkWell(
                onTap: () => onChanged(i),
                borderRadius: BorderRadius.circular(11),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: selected ? AppColors.darkBlueText : Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ComplaintCard extends StatelessWidget {
  const _ComplaintCard({required this.item});

  final PengaduanModel item;

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
    }
  }

  ({Color bg, Color fg}) get _badge {
    switch (item.status) {
      case ComplaintStatusUi.diproses:
        return (bg: const Color(0xFFE8F3FC), fg: AppColors.primaryBlue);
      case ComplaintStatusUi.diterima:
      case ComplaintStatusUi.terkirim:
        return (bg: const Color(0xFFFFF3D6), fg: const Color(0xFFE58A00));
      case ComplaintStatusUi.selesai:
        return (bg: const Color(0xFFE8F8EB), fg: AppColors.green);
      case ComplaintStatusUi.ditolak:
        return (bg: const Color(0xFFFFEBEE), fg: const Color(0xFFE53935));
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
    }
  }

  String get _dateLabel {
    final d = item.tanggalDibuat;
    if (d == null) return '-';
    return DateFormat('d MMM yyyy', 'id_ID').format(d);
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

  @override
  Widget build(BuildContext context) {
    final b = _badge;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.nomorPengaduan,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      style: TextStyle(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(_categoryIcon, size: 16, color: AppColors.mutedText),
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
    );
  }
}

