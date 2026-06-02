import 'dokumen_model.dart';
import 'informasi_model.dart';
import 'pengaduan_model.dart';

enum SearchResultKind {
  pengumuman,
  kegiatan,
  pengaduan,
  dokumen,
}

class SearchResultItem {
  const SearchResultItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.payload,
  });

  final SearchResultKind kind;
  final String title;
  final String subtitle;
  final Object payload;

  InformasiModel get asInformasi => payload as InformasiModel;
  PengaduanModel get asPengaduan => payload as PengaduanModel;
  DokumenModel get asDokumen => payload as DokumenModel;

  String get kindLabel => switch (kind) {
        SearchResultKind.pengumuman => 'Pengumuman',
        SearchResultKind.kegiatan => 'Kegiatan',
        SearchResultKind.pengaduan => 'Pengaduan',
        SearchResultKind.dokumen => 'Dokumen',
      };
}
