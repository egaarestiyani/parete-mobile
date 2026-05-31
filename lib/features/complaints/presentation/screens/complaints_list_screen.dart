import 'package:flutter/material.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'create_complaint_screen.dart';

enum ComplaintStatus { diproses, diterima, selesai }

class ComplaintItem {
  const ComplaintItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.dateLabel,
    required this.status,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String dateLabel;
  final ComplaintStatus status;

  bool get isActive => status == ComplaintStatus.diproses || status == ComplaintStatus.diterima;
}

class ComplaintsListScreen extends StatefulWidget {
  const ComplaintsListScreen({super.key});

  static const String routeName = '/complaints';

  @override
  State<ComplaintsListScreen> createState() => _ComplaintsListScreenState();
}

class _ComplaintsListScreenState extends State<ComplaintsListScreen> {
  static const Color _headerBlue = Color(0xFF3A8FD9);

  int _tabIndex = 0; // 0 Semua, 1 Aktif, 2 Selesai

  static final List<ComplaintItem> _all = [
    ComplaintItem(
      id: '#ADU-031',
      title: 'Lampu Jalan Gang Mawar Mati',
      description: 'Lampu penerangan di gang Mawar padam sejak dua malam lalu, mohon segera ditindaklanjuti.',
      category: 'Infrastruktur',
      dateLabel: '5 Mar 2025',
      status: ComplaintStatus.diproses,
    ),
    ComplaintItem(
      id: '#ADU-028',
      title: 'Sampah Menumpuk di Ujung Gang',
      description: 'Tumpukan sampah tidak diangkut dan mulai menimbulkan bau tidak sedap di ujung gang.',
      category: 'Kebersihan',
      dateLabel: '4 Mar 2025',
      status: ComplaintStatus.diterima,
    ),
    ComplaintItem(
      id: '#ADU-019',
      title: 'Pintu Pos RT Rusak',
      description: 'Engsel pintu pos RT longgar dan sulit ditutup, dikhawatirkan rawan keamanan malam hari.',
      category: 'Keamanan',
      dateLabel: '28 Feb 2025',
      status: ComplaintStatus.selesai,
    ),
    ComplaintItem(
      id: '#ADU-015',
      title: 'Got Mampet Depan Rumah Pak RT',
      description: 'Air meluap saat hujan deras karena saluran got tersumbat dedaunan dan plastik.',
      category: 'Infrastruktur',
      dateLabel: '20 Feb 2025',
      status: ComplaintStatus.diproses,
    ),
  ];

  List<ComplaintItem> get _visible {
    switch (_tabIndex) {
      case 1:
        return _all.where((e) => e.isActive).toList();
      case 2:
        return _all.where((e) => e.status == ComplaintStatus.selesai).toList();
      default:
        return _all;
    }
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
            onPressed: () => Navigator.pushNamed(context, CreateComplaintScreen.routeName),
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
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: _visible.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) => _ComplaintCard(item: _visible[i]),
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

  final ComplaintItem item;

  Color get _accent {
    switch (item.status) {
      case ComplaintStatus.diproses:
        return AppColors.primaryBlue;
      case ComplaintStatus.diterima:
        return const Color(0xFFE58A00);
      case ComplaintStatus.selesai:
        return AppColors.green;
    }
  }

  ({Color bg, Color fg}) get _badge {
    switch (item.status) {
      case ComplaintStatus.diproses:
        return (bg: const Color(0xFFE8F3FC), fg: AppColors.primaryBlue);
      case ComplaintStatus.diterima:
        return (bg: const Color(0xFFFFF3D6), fg: const Color(0xFFE58A00));
      case ComplaintStatus.selesai:
        return (bg: const Color(0xFFE8F8EB), fg: AppColors.green);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case ComplaintStatus.diproses:
        return 'Diproses';
      case ComplaintStatus.diterima:
        return 'Diterima';
      case ComplaintStatus.selesai:
        return 'Selesai';
    }
  }

  IconData get _categoryIcon {
    switch (item.category) {
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
                          item.id,
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
                          item.category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: AppColors.mutedText,
                          ),
                        ),
                        const Spacer(),
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

