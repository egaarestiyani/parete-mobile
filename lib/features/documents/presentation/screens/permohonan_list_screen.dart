import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/permohonan_model.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/permohonan_service.dart';
import 'document_submission_screen.dart';

class PermohonanListScreen extends StatefulWidget {
  const PermohonanListScreen({super.key});

  static const String routeName = '/documents/permohonan';

  @override
  State<PermohonanListScreen> createState() => _PermohonanListScreenState();
}

class _PermohonanListScreenState extends State<PermohonanListScreen> {
  bool _loading = true;
  String? _error;
  List<PermohonanModel> _items = [];
  String? _downloadingKey;

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
      final items = await PermohonanService(api).fetch();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _openSubmit() async {
    await Navigator.pushNamed(context, DocumentSubmissionScreen.routeName);
    _load();
  }

  Color _statusColor(String status) {
    return switch (status) {
      'Terkirim' => AppColors.mutedText,
      'Diproses' => AppColors.primaryBlue,
      'Selesai' => AppColors.green,
      'Ditolak' => const Color(0xFFE53935),
      'Dibatalkan' => AppColors.mutedText,
      _ => AppColors.mutedText,
    };
  }

  Future<void> _openEdit(PermohonanModel pm) async {
    await Navigator.pushNamed(
      context,
      DocumentSubmissionScreen.routeName,
      arguments: pm,
    );
    _load();
  }

  Future<void> _batalkan(PermohonanModel pm) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan permohonan?'),
        content: const Text(
          'Permohonan yang dibatalkan tidak akan diproses oleh Admin RT.',
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
      await PermohonanService(context.read<AuthService>().api).batalkan(pm.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permohonan berhasil dibatalkan.')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _downloadSurat(PermohonanModel pm, {required bool ttd}) async {
    final key = '${pm.id}-${ttd ? 'ttd' : 'balasan'}';
    if (_downloadingKey != null) return;
    setState(() => _downloadingKey = key);
    try {
      final bytes = await PermohonanService(context.read<AuthService>().api)
          .downloadSurat(pm.id, ttd: ttd);
      if (bytes.isEmpty) throw Exception('Berkas surat kosong.');
      final name = '${pm.jenisDokumenDisplay}${ttd ? '_TTD' : ''}.pdf';
      await Share.shareXFiles(
        [XFile.fromData(Uint8List.fromList(bytes), name: name)],
        subject: pm.jenisDokumenDisplay,
        text: 'Surat dari Admin RT: ${pm.jenisDokumenDisplay}',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _downloadingKey = null);
    }
  }

  void _showDetail(PermohonanModel pm) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            MediaQuery.of(ctx).padding.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  pm.jenisDokumenDisplay,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlueText,
                  ),
                ),
                const SizedBox(height: 8),
                _StatusChip(label: pm.status, color: _statusColor(pm.status)),
                const SizedBox(height: AppSpacing.md),
                _detailRow('Keperluan', pm.keperluan),
                _detailRow('Tanda tangan', pm.mintaTandaTanganLabel),
                if (pm.catatanTambahan != null && pm.catatanTambahan!.isNotEmpty)
                  _detailRow('Catatan Anda', pm.catatanTambahan!),
                if (pm.catatanRt != null && pm.catatanRt!.isNotEmpty)
                  _detailRow('Catatan RT', pm.catatanRt!),
                if (pm.isDitolak && pm.alasanDitolak != null)
                  _detailRow('Alasan ditolak', pm.alasanDitolak!),
                if (pm.tanggalDibuat != null)
                  _detailRow('Diajukan', ApiDate.format(pm.tanggalDibuat)),
                if (pm.tanggalDijawab != null)
                  _detailRow('Diselesaikan', ApiDate.format(pm.tanggalDijawab)),
                if (pm.isSelesai) ...[
                  const SizedBox(height: AppSpacing.md),
                  if (pm.suratBalasanTersedia)
                    _downloadButton(
                      label: 'Unduh surat balasan',
                      loading: _downloadingKey == '${pm.id}-balasan',
                      onTap: () {
                        Navigator.pop(ctx);
                        _downloadSurat(pm, ttd: false);
                      },
                    ),
                  if (pm.mintaDenganTtd && pm.suratTtdTersedia) ...[
                    const SizedBox(height: AppSpacing.sm),
                    _downloadButton(
                      label: 'Unduh surat bertanda tangan',
                      loading: _downloadingKey == '${pm.id}-ttd',
                      onTap: () {
                        Navigator.pop(ctx);
                        _downloadSurat(pm, ttd: true);
                      },
                    ),
                  ],
                ],
                if (pm.canEdit || pm.canBatalkan) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      if (pm.canEdit)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _openEdit(pm);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('Ubah'),
                          ),
                        ),
                      if (pm.canEdit && pm.canBatalkan)
                        const SizedBox(width: AppSpacing.sm),
                      if (pm.canBatalkan)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _batalkan(pm);
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
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
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
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlueText,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downloadButton({
    required String label,
    required VoidCallback onTap,
    required bool loading,
  }) {
    return FilledButton.icon(
      onPressed: loading ? null : onTap,
      icon: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : const Icon(Icons.download_rounded),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        minimumSize: const Size(double.infinity, 48),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'Permohonan Saya',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            onPressed: _openSubmit,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Ajukan dokumen',
          ),
        ],
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
                  child: _items.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 80),
                            Center(
                              child: Text(
                                'Belum ada permohonan dokumen.\nTap + untuk mengajukan.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.mutedText, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          itemCount: _items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final pm = _items[index];
                            return Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              child: InkWell(
                                onTap: () => _showDetail(pm),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              pm.jenisDokumenDisplay,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: AppColors.darkBlueText,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              pm.keperluan,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.mutedText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusChip(
                                        label: pm.status,
                                        color: _statusColor(pm.status),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}
