import '../api/api_client.dart';
import '../models/dokumen_model.dart';
import '../models/informasi_model.dart';
import '../models/pengaduan_model.dart';
import '../models/search_result.dart';
import 'dokumen_service.dart';
import 'informasi_service.dart';
import 'pengaduan_service.dart';

/// Pencarian lintas pengumuman, kegiatan, pengaduan, dan dokumen (data MongoDB via API).
class SearchService {
  SearchService(this._api);

  final ApiClient _api;

  List<InformasiModel>? _informasi;
  List<PengaduanModel>? _pengaduan;
  List<DokumenModel>? _dokumen;

  Future<void> ensureLoaded() async {
    if (_informasi != null) return;

    final informasiFuture = InformasiService(_api).fetch();
    final pengaduanFuture = PengaduanService(_api).fetch();
    final dokumenFuture = DokumenService(_api).fetch();

    final results = await Future.wait([
      informasiFuture,
      pengaduanFuture,
      dokumenFuture,
    ]);

    _informasi = results[0] as List<InformasiModel>;
    _pengaduan = results[1] as List<PengaduanModel>;
    _dokumen = (results[2] as ({List<DokumenModel> docs, DokumenStats stats})).docs;
  }

  List<SearchResultItem> filter(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    final informasi = _informasi ?? [];
    final pengaduan = _pengaduan ?? [];
    final dokumen = _dokumen ?? [];

    final items = <SearchResultItem>[];

    for (final info in informasi) {
      if (!_matches(q, [info.judul, info.isi, info.penulis ?? '', info.jenis.name])) {
        continue;
      }
      final kind = info.jenis == InformasiJenis.kegiatan
          ? SearchResultKind.kegiatan
          : SearchResultKind.pengumuman;
      items.add(
        SearchResultItem(
          kind: kind,
          title: info.judul,
          subtitle: info.ringkasan,
          payload: info,
        ),
      );
    }

    for (final p in pengaduan) {
      if (!_matches(q, [p.judul, p.topik, p.lokasi, p.deskripsi, p.nomorPengaduan])) {
        continue;
      }
      items.add(
        SearchResultItem(
          kind: SearchResultKind.pengaduan,
          title: p.judul,
          subtitle: '${p.nomorPengaduan} • ${p.topik}',
          payload: p,
        ),
      );
    }

    for (final d in dokumen) {
      if (!_matches(q, [d.nama, d.kategori, d.tipe])) continue;
      items.add(
        SearchResultItem(
          kind: SearchResultKind.dokumen,
          title: d.nama,
          subtitle: '${d.kategori.toUpperCase()} • ${d.ukuranLabel}',
          payload: d,
        ),
      );
    }

    return items;
  }

  bool _matches(String query, List<String> fields) {
    for (final field in fields) {
      if (field.toLowerCase().contains(query)) return true;
    }
    return false;
  }
}
