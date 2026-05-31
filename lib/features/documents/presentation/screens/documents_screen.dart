import 'package:flutter/material.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import 'document_submission_screen.dart';

/// Daftar dokumen resmi RT/RW.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static const String routeName = '/documents';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocItem {
  const _DocItem({
    required this.title,
    required this.extLabel,
    required this.extColor,
    required this.meta,
    required this.category,
  });

  final String title;
  final String extLabel;
  final Color extColor;
  final String meta;
  final String category; // 'Semua' | 'Surat' | 'Formulir'
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  static const Color _headerBlue = Color(0xFF2E7DBC);

  static const List<String> _filters = ['Semua', 'Surat', 'Formulir'];

  static const List<_DocItem> _allDocs = [
    _DocItem(
      title: 'Formulir Surat Keterangan Domisili',
      extLabel: 'PDF',
      extColor: Color(0xFFE53935),
      meta: 'PDF • 245 KB',
      category: 'Formulir',
    ),
    _DocItem(
      title: 'Surat Pengantar RT — Template',
      extLabel: 'DOC',
      extColor: Color(0xFF2B89D6),
      meta: 'DOC • 128 KB',
      category: 'Surat',
    ),
    _DocItem(
      title: 'Surat Keterangan Tidak Mampu',
      extLabel: 'PDF',
      extColor: Color(0xFFE53935),
      meta: 'PDF • 312 KB',
      category: 'Surat',
    ),
    _DocItem(
      title: 'Daftar Warga — Formulir',
      extLabel: 'XLS',
      extColor: Color(0xFF33B249),
      meta: 'XLS • 89 KB',
      category: 'Formulir',
    ),
    _DocItem(
      title: 'Surat Keterangan Usaha',
      extLabel: 'PDF',
      extColor: Color(0xFFE53935),
      meta: 'PDF • 198 KB',
      category: 'Surat',
    ),
  ];

  String _filter = _filters.first;

  List<_DocItem> get _visibleDocs {
    if (_filter == 'Semua') return _allDocs;
    return _allDocs.where((d) => d.category == _filter).toList();
  }

  void _openSubmission() {
    Navigator.pushNamed(context, DocumentSubmissionScreen.routeName);
  }

  void _showDownloadSheet(_DocItem doc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DownloadProgressSheet(doc: doc),
    );
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
        title: const Text('Dokumen', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        actions: [
          IconButton(
            onPressed: _openSubmission,
            icon: const Icon(Icons.add_rounded, size: 28),
            tooltip: 'Pengajuan dokumen',
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: const MainBottomNavBar(selectedIndex: 3),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: _StatCell(value: '12', label: 'Total Dokumen'),
                ),
                Expanded(
                  child: _StatCell(value: '3', label: 'Baru Bulan Ini'),
                ),
                Expanded(
                  child: _StatCell(value: '5', label: 'Diunduh'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final selected = f == _filter;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.yellow,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: AppColors.darkBlueText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: selected ? AppColors.yellow : AppColors.border),
                    ),
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._visibleDocs.map(
            (d) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _DocumentTile(
                item: d,
                onDownload: () => _showDownloadSheet(d),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Duration _estimatedDownloadDuration(_DocItem doc) {
  final match = RegExp(r'(\d+)\s*KB', caseSensitive: false).firstMatch(doc.meta);
  final kb = match != null ? int.tryParse(match.group(1)!) ?? 256 : 256;
  // Durasi perkiraan: file lebih besar = unduh lebih lama (demo, ~12–20 ms per KB).
  final ms = (kb * 16).clamp(1600, 12000);
  return Duration(milliseconds: ms);
}

/// Bottom sheet unduh dengan progress bar yang diperbarui setiap frame (real-time).
class _DownloadProgressSheet extends StatefulWidget {
  const _DownloadProgressSheet({required this.doc});

  final _DocItem doc;

  @override
  State<_DownloadProgressSheet> createState() => _DownloadProgressSheetState();
}

class _DownloadProgressSheetState extends State<_DownloadProgressSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _progress;
  bool _cancelled = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(
      vsync: this,
      duration: _estimatedDownloadDuration(widget.doc),
    )..addListener(() {
        if (mounted) setState(() {});
      });
    _progress.forward().then((_) {
      if (!mounted || _cancelled) return;
      setState(() => _completed = true);
    });
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _onCancel() {
    _cancelled = true;
    _progress.stop();
    Navigator.of(context).pop();
  }

  double get _value => _progress.value.clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final pct = (_value * 100).round().clamp(0, 100);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
          child: SafeArea(
            top: false,
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
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  widget.doc.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.darkBlueText,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _completed ? 'Unduhan selesai.' : 'Mengunduh dokumen…',
                        style: TextStyle(
                          color: _completed ? AppColors.green : AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _completed ? 1 : _value,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8F3FC),
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                OutlinedButton(
                  onPressed: _completed
                      ? () {
                          final messenger = ScaffoldMessenger.maybeOf(context);
                          Navigator.of(context).pop();
                          messenger?.showSnackBar(
                            const SnackBar(content: Text('Dokumen siap dibuka (demo).')),
                          );
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    disabledForegroundColor: AppColors.mutedText,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Buka Setelah Diunduh', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton(
                  onPressed: _onCancel,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    foregroundColor: const Color(0xFFE53935),
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    _completed ? 'Tutup' : 'Batal',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.mutedText,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.item, required this.onDownload});

  final _DocItem item;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 0,
      shadowColor: AppColors.cardShadow,
      child: InkWell(
        onTap: onDownload,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.extColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.extLabel,
                  style: TextStyle(
                    color: item.extColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkBlueText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.meta,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, color: AppColors.primaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
