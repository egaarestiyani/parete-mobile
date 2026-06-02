import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../app/main_tab_navigation.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/models/informasi_model.dart';
import '../../../../core/utils/api_date.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/informasi_service.dart';
import '../../../shared/widgets/parete_page_header.dart';
import 'informasi_detail_screen.dart';

/// Pengumuman & kegiatan warga.
class InformationScreen extends StatefulWidget {
  const InformationScreen({super.key});

  static const String routeName = '/information';

  @override
  State<InformationScreen> createState() => _InformationScreenState();
}

class _InformationScreenState extends State<InformationScreen> {
  static const List<String> _filters = ['Semua', 'Pengumuman', 'Kegiatan'];
  int _filterIndex = 0;
  bool _loading = true;
  String? _error;
  List<InformasiModel> _all = [];

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
      final items = await InformasiService(api).fetch();
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

  List<InformasiModel> get _visible {
    switch (_filterIndex) {
      case 1:
        return _all.where((e) => e.jenis == InformasiJenis.pengumuman).toList();
      case 2:
        return _all.where((e) => e.jenis == InformasiJenis.kegiatan).toList();
      default:
        return _all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PareteTabbedPageHeader(
            title: 'Informasi',
            tabLabels: _filters,
            tabIndex: _filterIndex,
            onTabChanged: (i) => setState(() => _filterIndex = i),
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
                        ? const Center(child: Text('Belum ada informasi.'))
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.lg,
                                AppSpacing.md,
                                AppSpacing.lg,
                                100,
                              ),
                              itemCount: _visible.length,
                              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                              itemBuilder: (context, i) => _InfoCard(item: _visible[i]),
                            ),
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

  final InformasiModel item;

  Color get _accent {
    return item.jenis == InformasiJenis.kegiatan ? const Color(0xFFE53935) : AppColors.primaryBlue;
  }

  String get _categoryLabel =>
      item.jenis == InformasiJenis.kegiatan ? 'KEGIATAN' : 'PENGUMUMAN';

  String get _dateLabel {
    final d = item.tanggalPublikasi;
    if (d == null) return '-';
    return ApiDate.formatDate(d);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            InformasiDetailScreen.routeName,
            arguments: item,
          );
        },
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
                        item.isi,
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
                        _dateLabel,
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
