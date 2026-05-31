import 'package:dio/dio.dart';

import '../api/api_client.dart';
import '../models/informasi_model.dart';
import '../models/pengaduan_model.dart';
import '../models/warga_model.dart';

class DashboardService {
  DashboardService(this._api);

  final ApiClient _api;

  Future<({
    WargaModel warga,
    List<InformasiModel> informasi,
    List<PengaduanModel> pengaduan,
  })> fetch() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/dashboard');
      final wargaJson = res.data?['warga'];
      final infoList = res.data?['informasi_terbaru'];
      final pengaduanList = res.data?['pengaduan_terbaru'];

      return (
        warga: wargaJson is Map<String, dynamic>
            ? WargaModel(
                id: '',
                idKeluarga: wargaJson['id_keluarga']?.toString() ?? '',
                namaKepalaKeluarga: wargaJson['nama_kepala_keluarga']?.toString() ?? '',
                nomorRumah: '',
                alamatLengkap: '',
                nomorHp: '',
                statusAkun: 'Aktif',
                harusGantiPassword: false,
              )
            : const WargaModel(
                id: '',
                idKeluarga: '',
                namaKepalaKeluarga: 'Warga',
                nomorRumah: '',
                alamatLengkap: '',
                nomorHp: '',
                statusAkun: 'Aktif',
                harusGantiPassword: false,
              ),
        informasi: infoList is List
            ? infoList
                .whereType<Map<String, dynamic>>()
                .map((e) => InformasiModel(
                      id: e['id']?.toString() ?? '',
                      jenis: e['jenis_informasi']?.toString() == 'kegiatan'
                          ? InformasiJenis.kegiatan
                          : InformasiJenis.pengumuman,
                      judul: e['judul_informasi']?.toString() ?? '',
                      isi: e['isi_informasi']?.toString() ?? '',
                      tanggalPublikasi:
                          DateTime.tryParse(e['tanggal_publikasi']?.toString() ?? ''),
                    ))
                .toList()
            : <InformasiModel>[],
        pengaduan: pengaduanList is List
            ? pengaduanList.whereType<Map<String, dynamic>>().map(PengaduanModel.fromJson).toList()
            : <PengaduanModel>[],
      );
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }
}

class ProfileService {
  ProfileService(this._api);

  final ApiClient _api;

  Future<({WargaModel warga, Map<String, int> stats})> fetch() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/profile');
      final wargaJson = res.data?['warga'];
      final statsJson = res.data?['stats'];
      if (wargaJson is! Map<String, dynamic>) {
        throw Exception('Data profil tidak valid.');
      }
      final stats = statsJson is Map<String, dynamic>
          ? {
              'total_pengaduan': int.tryParse(statsJson['total_pengaduan']?.toString() ?? '') ?? 0,
              'pengaduan_aktif': int.tryParse(statsJson['pengaduan_aktif']?.toString() ?? '') ?? 0,
              'pengaduan_selesai': int.tryParse(statsJson['pengaduan_selesai']?.toString() ?? '') ?? 0,
            }
          : {'total_pengaduan': 0, 'pengaduan_aktif': 0, 'pengaduan_selesai': 0};
      return (warga: WargaModel.fromJson(wargaJson), stats: stats);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }
}
