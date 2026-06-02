import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/dokumen_model.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/dokumen_service.dart';
import '../../../shared/widgets/parete_page_header.dart';
import 'document_submission_screen.dart';
import 'permohonan_list_screen.dart';

/// Daftar dokumen resmi RT/RW.
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  static const String routeName = '/documents';

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  static const List<String> _filters = ['Semua', 'Surat', 'Formulir'];

  int _filterIndex = 0;
  bool _loading = true;
  String? _error;
  String? _downloadingId;
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
      if (_filterIndex == 1) kategori = 'surat';
      if (_filterIndex == 2) kategori = 'formulir';
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
    if (_filterIndex == 0) return _docs;
    final target = _filters[_filterIndex].toLowerCase();
    return _docs.where((d) => d.kategori == target).toList();
  }

  void _onFilterChanged(int index) {
    setState(() => _filterIndex = index);
    _load();
  }

  Future<void> _downloadDoc(DokumenModel doc) async {
    if (_downloadingId != null) return;
    setState(() => _downloadingId = doc.id);
    try {
      final auth = context.read<AuthService>();
      final service = DokumenService(auth.api);

      if (kIsWeb) {
        final token = await auth.currentToken();
        var url = '${ApiConfig.apiBase}/dokumen/${doc.id}/unduh';
        if (token != null && token.isNotEmpty) {
          url += '?token=${Uri.encodeComponent(token)}';
        }
        final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        if (!ok) {
          throw Exception('Gagal membuka unduhan di browser.');
        }
      } else {
        final bytes = await service.downloadById(doc.id);
        if (bytes.isEmpty) {
          throw Exception('Berkas dokumen kosong di server.');
        }
        await Share.shareXFiles(
          [
            XFile.fromData(
              Uint8List.fromList(bytes),
              name: doc.fileName,
              mimeType: _mimeType(doc.tipe),
            ),
          ],
          subject: doc.nama,
          text: 'Dokumen RT: ${doc.nama}',
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unduhan tercatat. Buka file dari menu yang muncul.'),
        ),
      );
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _downloadingId = null);
    }
  }

  static String _mimeType(String tipe) {
    return switch (tipe.toLowerCase()) {
      'pdf' => 'application/pdf',
      'doc' => 'application/msword',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel',
      'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      _ => 'application/octet-stream',
    };
  }

  void _openSubmission() {
    Navigator.pushNamed(context, DocumentSubmissionScreen.routeName);
  }

  void _openPermohonanList() {
    Navigator.pushNamed(context, PermohonanListScreen.routeName);
  }

  Color _extColor(String tipe) {
    return switch (tipe.toLowerCase()) {
      'pdf' => const Color(0xFFE53935),
      'doc' || 'docx' => AppColors.primaryBlue,
      'xls' || 'xlsx' => AppColors.green,
      _ => AppColors.mutedText,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md + 4),
        child: const MainBottomNavBar(selectedIndex: 3),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PareteTabbedPageHeader(
            title: 'Dokumen',
            tabLabels: _filters,
            tabIndex: _filterIndex,
            onTabChanged: _onFilterChanged,
            actions: [
              IconButton(
                onPressed: _openPermohonanList,
                icon: const Icon(Icons.assignment_outlined, color: Colors.white, size: 26),
                tooltip: 'Permohonan saya',
              ),
              IconButton(
                onPressed: _openSubmission,
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
                tooltip: 'Pengajuan dokumen',
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
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.lg,
                            100,
                          ),
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueBg,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _StatCell(value: '${_stats.total}', label: 'Total Dokumen'),
                                  ),
                                  Expanded(
                                    child: _StatCell(
                                      value: '${_stats.baruBulanIni}',
                                      label: 'Baru Bulan Ini',
                                    ),
                                  ),
                                  Expanded(
                                    child: _StatCell(
                                      value: '${_stats.totalUnduhan}',
                                      label: 'Diunduh',
                                    ),
                                  ),
                                ],
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
                              meta: '${d.tipe.toUpperCase()} • ${d.ukuranLabel}${d.sudahDiunduh ? ' • Sudah diunduh' : ''}',
                              downloading: _downloadingId == d.id,
                              onDownload: () => _downloadDoc(d),
                            ),
                          ),
                        ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    this.subtitle,
  });

  final String value;
  final String label;
  final String? subtitle;

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
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText.withValues(alpha: 0.85),
            ),
          ),
        ],
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
    this.downloading = false,
  });

  final String title;
  final String extLabel;
  final Color extColor;
  final String meta;
  final VoidCallback onDownload;
  final bool downloading;

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
              downloading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
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
