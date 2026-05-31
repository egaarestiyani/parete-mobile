import 'package:flutter/material.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';

enum _InfoKind { kegiatan, pengumuman }

class _InfoItem {
  const _InfoItem({
    required this.kind,
    required this.title,
    required this.description,
    required this.dateLabel,
  });

  final _InfoKind kind;
  final String title;
  final String description;
  final String dateLabel;
}

/// Pengumuman & kegiatan warga.
class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  static const String routeName = '/information';

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  static const Color _headerBlue = Color(0xFF2E7DBC);

  static const List<String> _filters = ['Semua', 'Pengumuman', 'Kegiatan'];
  int _filterIndex = 0;

  static const List<_InfoItem> _all = [
    _InfoItem(
      kind: _InfoKind.kegiatan,
      title: 'Kerja Bakti Massal',
      description: 'Warga dihimbau hadir pada 5 Maret 2026 pukul 07.00 di area RT 05.',
      dateLabel: '5 Mar 2026',
    ),
    _InfoItem(
      kind: _InfoKind.pengumuman,
      title: 'Waspada Demam Berdarah',
      description: 'Himbauan pencegahan DBD: kosongkan bak mandi, gunakan obat nyamuk, dan segera ke puskesmas jika demam.',
      dateLabel: '3 Mar 2026',
    ),
    _InfoItem(
      kind: _InfoKind.pengumuman,
      title: 'Pemutihan PBB Dini Hari',
      description: 'Informasi jadwal pemutihan pajak untuk warga yang belum melunasi tahun berjalan.',
      dateLabel: '28 Feb 2026',
    ),
    _InfoItem(
      kind: _InfoKind.kegiatan,
      title: 'Senam Sehat Lansia',
      description: 'Setiap Sabtu pukul 08.00 di balai RT. Peserta membawa matras sendiri.',
      dateLabel: '20 Feb 2026',
    ),
    _InfoItem(
      kind: _InfoKind.pengumuman,
      title: 'Distribusi Air Bersih',
      description: 'Truk tangki tersedia di pos RT pada 12 Mar 2026 pukul 09.00–11.00.',
      dateLabel: '18 Feb 2026',
    ),
  ];

  List<_InfoItem> get _visible {
    switch (_filterIndex) {
      case 1:
        return _all.where((e) => e.kind == _InfoKind.pengumuman).toList();
      case 2:
        return _all.where((e) => e.kind == _InfoKind.kegiatan).toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            color: _headerBlue,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 8, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  children: [
                    const Text(
                      'Informasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        for (var i = 0; i < _filters.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(
                            child: Material(
                              color: i == _filterIndex
                                  ? AppColors.yellow
                                  : Colors.white.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                onTap: () => setState(() => _filterIndex = i),
                                borderRadius: BorderRadius.circular(20),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    _filters[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                      color: i == _filterIndex ? AppColors.darkBlueText : Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
              itemCount: _visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _InfoCard(item: _visible[i]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: const MainBottomNavBar(selectedIndex: 1),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});

  final _InfoItem item;

  Color get _accent {
    return item.kind == _InfoKind.kegiatan ? const Color(0xFFE53935) : AppColors.primaryBlue;
  }

  String get _categoryLabel => item.kind == _InfoKind.kegiatan ? 'KEGIATAN' : 'PENGUMUMAN';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categoryLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.darkBlueText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        item.dateLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.chevron_right_rounded, color: Color(0xFFB0B8C9)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
