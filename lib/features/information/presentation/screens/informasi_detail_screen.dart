import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/informasi_model.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/informasi_service.dart';
import '../../../shared/widgets/parete_logo.dart';
import '../../../shared/widgets/parete_network_image.dart';

/// Halaman lengkap pengumuman / kegiatan (Baca Selengkapnya).
class InformasiDetailScreen extends StatefulWidget {
  const InformasiDetailScreen({this.initial, super.key});

  static const String routeName = '/informasi-detail';

  final InformasiModel? initial;

  @override
  State<InformasiDetailScreen> createState() => _InformasiDetailScreenState();
}

class _InformasiDetailScreenState extends State<InformasiDetailScreen> {
  InformasiModel? _item;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _item = widget.initial;
    final id = _item?.id;
    if (id != null && id.isNotEmpty) {
      _loadDetail(id);
    }
  }

  Future<void> _loadDetail(String id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = context.read<AuthService>().api;
      final detail = await InformasiService(api).fetchById(id);
      if (!mounted) return;
      setState(() {
        _item = detail;
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

  @override
  Widget build(BuildContext context) {
    final item = _item;

    if (item == null && _loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (item == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(_error ?? 'Informasi tidak ditemukan.'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: item.hasGambar ? 240 : 120,
            pinned: true,
            backgroundColor: AppColors.primaryBlue,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: item.hasGambar
                  ? PareteNetworkImage(url: item.gambarUrl)
                  : Container(
                      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
                      child: const SafeArea(
                        child: Center(
                          child: PareteLogo(variant: PareteLogoVariant.light, height: 40),
                        ),
                      ),
                    ),
            ),
          ),
          if (_loading)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              transform: Matrix4.translationValues(0, -20, 0),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg + 4,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CategoryBadge(jenis: item.jenis),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlueText,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.mutedText),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(item.tanggalPublikasi),
                        style: const TextStyle(
                          color: AppColors.mutedText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (item.penulis != null && item.penulis!.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.md),
                        const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.mutedText),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.penulis!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.mutedText,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (item.jenis == InformasiJenis.kegiatan && item.tanggalKegiatan != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 16, color: AppColors.mutedText),
                        const SizedBox(width: 6),
                        Text(
                          'Jadwal kegiatan: ${_formatDate(item.tanggalKegiatan)}',
                          style: const TextStyle(
                            color: AppColors.mutedText,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(height: 1, color: AppColors.border),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    item.isi,
                    style: const TextStyle(
                      color: AppColors.darkBlueText,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      _error!,
                      style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    return ApiDate.format(d, pattern: 'EEEE, d MMMM yyyy');
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.jenis});

  final InformasiJenis jenis;

  @override
  Widget build(BuildContext context) {
    final isKegiatan = jenis == InformasiJenis.kegiatan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isKegiatan ? const Color(0xFFFFEBEE) : AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        isKegiatan ? 'KEGIATAN' : 'PENGUMUMAN',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: isKegiatan ? const Color(0xFFE53935) : AppColors.primaryBlue,
        ),
      ),
    );
  }
}
