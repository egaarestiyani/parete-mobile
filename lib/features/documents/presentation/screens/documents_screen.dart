import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/dokumen_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/dokumen_service.dart';
import 'document_submission_screen.dart';

/// Daftar dokumen resmi RT/RW.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static const String routeName = '/documents';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  static const Color _headerBlue = Color(0xFF2E7DBC);

  static const List<String> _filters = ['Semua', 'Surat', 'Formulir'];

  String _filter = _filters.first;
  bool _loading = true;
  String? _error;
  List<DokumenModel> _docs = [];
  DokumenStats _stats = const DokumenStats(total: 0, baruBulanIni: 0, totalUnduhan: 0);

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
      String? kategori;
      if (_filter == 'Surat') kategori = 'surat';
      if (_filter == 'Formulir') kategori = 'formulir';
      final result = await DokumenService(api).fetch(kategori: kategori);
      if (!mounted) return;
      setState(() {
        _docs = result.docs;
        _stats = result.stats;
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

  List<DokumenModel> get _visibleDocs {
    if (_filter == 'Semua') return _docs;
    final target = _filter.toLowerCase();
    return _docs.where((d) => d.kategori == target).toList();
  }

  Future<void> _downloadDoc(DokumenModel doc) async {
    final token = await context.read<AuthService>().currentToken();
    final uri = Uri.parse('${doc.downloadPath}${token != null ? '?token=$token' : ''}');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka unduhan dokumen.')),
      );
    }
  }

  void _openSubmission() {
    Navigator.pushNamed(context, DocumentSubmissionScreen.routeName);
  }

  Color _extColor(String tipe) {
    return switch (tipe.toLowerCase()) {
      'pdf' => const Color(0xFFE53935),
      'doc' || 'docx' => const Color(0xFF2B89D6),
      'xls' || 'xlsx' => AppColors.green,
      _ => AppColors.mutedText,
    };
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
      body: _loading
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
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F3FC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _StatCell(value: '${_stats.total}', label: 'Total Dokumen'),
                            ),
                            Expanded(
                              child: _StatCell(value: '${_stats.baruBulanIni}', label: 'Baru Bulan Ini'),
                            ),
                            Expanded(
                              child: _StatCell(value: '${_stats.totalUnduhan}', label: 'Diunduh'),
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
                                onSelected: (_) {
                                  setState(() => _filter = f);
                                  _load();
                                },
                                selectedColor: AppColors.yellow,
                                backgroundColor: Colors.white,
                                labelStyle: const TextStyle(
                                  color: AppColors.darkBlueText,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: selected ? AppColors.yellow : AppColors.border,
                                  ),
                                ),
                                showCheckmark: false,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_visibleDocs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(child: Text('Belum ada dokumen.')),
                        )
                      else
                        ..._visibleDocs.map(
                          (d) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                            child: _DocumentTile(
                              title: d.nama,
                              extLabel: d.tipe.toUpperCase(),
                              extColor: _extColor(d.tipe),
                              meta: '${d.tipe.toUpperCase()} • ${d.ukuranLabel}',
                              onDownload: () => _downloadDoc(d),
                            ),
                          ),
                        ),
                    ],
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
  const _DocumentTile({
    required this.title,
    required this.extLabel,
    required this.extColor,
    required this.meta,
    required this.onDownload,
  });

  final String title;
  final String extLabel;
  final Color extColor;
  final String meta;
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
                  color: extColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  extLabel,
                  style: TextStyle(
                    color: extColor,
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
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.darkBlueText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meta,
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
