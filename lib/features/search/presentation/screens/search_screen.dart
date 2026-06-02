import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/pengaduan_model.dart';
import '../../../../core/models/search_result.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/search_service.dart';
import '../../../complaints/presentation/screens/complaints_list_screen.dart';
import '../../../documents/presentation/screens/documents_screen.dart';
import '../../../information/presentation/screens/informasi_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String routeName = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  late final SearchService _searchService;

  Timer? _debounce;
  bool _loadingData = true;
  String? _loadError;
  String _query = '';
  List<SearchResultItem> _results = [];

  @override
  void initState() {
    super.initState();
    _searchService = SearchService(context.read<AuthService>().api);
    _queryController.addListener(_onQueryChanged);
    _preload();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  Future<void> _preload() async {
    setState(() {
      _loadingData = true;
      _loadError = null;
    });
    try {
      await _searchService.ensureLoaded();
      if (!mounted) return;
      setState(() => _loadingData = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingData = false;
        _loadError = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      final text = _queryController.text;
      setState(() {
        _query = text;
        _results = _searchService.filter(text);
      });
    });
  }

  void _clearQuery() {
    _queryController.clear();
    setState(() {
      _query = '';
      _results = [];
    });
  }

  void _openResult(SearchResultItem item) {
    switch (item.kind) {
      case SearchResultKind.pengumuman:
      case SearchResultKind.kegiatan:
        Navigator.pushNamed(
          context,
          InformasiDetailScreen.routeName,
          arguments: item.asInformasi,
        );
      case SearchResultKind.pengaduan:
        _showPengaduanSheet(item.asPengaduan);
      case SearchResultKind.dokumen:
        Navigator.pushNamed(context, DocumentsScreen.routeName);
    }
  }

  void _showPengaduanSheet(PengaduanModel p) {
    final status = switch (p.status) {
      ComplaintStatusUi.terkirim => 'Terkirim',
      ComplaintStatusUi.diterima => 'Diterima',
      ComplaintStatusUi.diproses => 'Diproses',
      ComplaintStatusUi.selesai => 'Selesai',
      ComplaintStatusUi.ditolak => 'Ditolak',
      ComplaintStatusUi.dibatalkan => 'Dibatalkan',
    };

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              p.judul,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${p.nomorPengaduan} • $status',
              style: const TextStyle(
                color: AppColors.mutedText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              p.deskripsi,
              style: const TextStyle(
                color: AppColors.darkBlueText,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, ComplaintsListScreen.routeName);
                },
                child: const Text('Lihat semua pengaduan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.removeListener(_onQueryChanged);
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasQuery = _query.trim().isNotEmpty;
    final showEmpty = hasQuery && !_loadingData && _loadError == null && _results.isEmpty;
    final showResults = hasQuery && !_loadingData && _loadError == null && _results.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                        ),
                        const Expanded(
                          child: Text(
                            'Pencarian',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _queryController,
                      focusNode: _focusNode,
                      style: const TextStyle(
                        color: AppColors.darkBlueText,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari pengumuman, kegiatan, pengaduan, dokumen...',
                        hintStyle: TextStyle(
                          color: AppColors.mutedText.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.iconMuted),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                onPressed: _clearQuery,
                                icon: const Icon(Icons.close_rounded, color: AppColors.iconMuted),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      textInputAction: TextInputAction.search,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              child: ColoredBox(
                color: Colors.white,
                child: SafeArea(
                  top: false,
                  child: _buildBody(
                    showEmpty: showEmpty,
                    showResults: showResults,
                    hasQuery: hasQuery,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required bool showEmpty,
    required bool showResults,
    required bool hasQuery,
  }) {
    if (_loadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              TextButton(onPressed: _preload, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }

    if (!hasQuery) {
      return _HintPanel();
    }

    if (showEmpty) {
      return const _EmptyResults();
    }

    if (showResults) {
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.xl,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        itemCount: _results.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = _results[index];
          return _SearchResultTile(
            item: item,
            onTap: () => _openResult(item),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}

class _HintPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        const Text(
          'Ketik kata kunci untuk mencari',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            color: AppColors.darkBlueText,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Contoh: sembako, lampu, formulir, kegiatan',
          style: TextStyle(
            color: AppColors.mutedText.withValues(alpha: 0.95),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _HintChip(icon: Icons.campaign_outlined, label: 'Pengumuman & kegiatan'),
        const SizedBox(height: AppSpacing.sm),
        _HintChip(icon: Icons.edit_note_rounded, label: 'Pengaduan warga'),
        const SizedBox(height: AppSpacing.sm),
        _HintChip(icon: Icons.description_outlined, label: 'Dokumen RT'),
      ],
    );
  }
}

class _HintChip extends StatelessWidget {
  const _HintChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlueText,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.mutedText.withValues(alpha: 0.45),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Data tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlueText,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Coba kata kunci lain atau periksa ejaan.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.mutedText.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.item,
    required this.onTap,
  });

  final SearchResultItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.kind) {
      SearchResultKind.pengumuman => Icons.campaign_outlined,
      SearchResultKind.kegiatan => Icons.event_outlined,
      SearchResultKind.pengaduan => Icons.edit_note_rounded,
      SearchResultKind.dokumen => Icons.description_outlined,
    };

    final iconBg = switch (item.kind) {
      SearchResultKind.pengumuman => AppColors.lightBlueBg,
      SearchResultKind.kegiatan => const Color(0xFFFFEBEE),
      SearchResultKind.pengaduan => const Color(0xFFFFF8E1),
      SearchResultKind.dokumen => const Color(0xFFE8F5E9),
    };

    final iconColor = switch (item.kind) {
      SearchResultKind.pengumuman => AppColors.primaryBlue,
      SearchResultKind.kegiatan => const Color(0xFFE53935),
      SearchResultKind.pengaduan => const Color(0xFFF9A825),
      SearchResultKind.dokumen => AppColors.green,
    };

    return Material(
      color: AppColors.lightBlueBg,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        item.kindLabel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.darkBlueText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.iconMuted),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
