import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import '../api/api_client.dart';
import '../models/permohonan_model.dart';

class PermohonanService {
  PermohonanService(this._api);

  final ApiClient _api;

  Future<List<PermohonanModel>> fetch() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/permohonan-dokumen');
      final list = res.data?['data'];
      if (list is! List) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(PermohonanModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<PermohonanModel> fetchById(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/permohonan-dokumen/$id');
      final data = res.data?['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Data permohonan tidak ditemukan.');
      }
      return PermohonanModel.fromJson(data);
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<void> update({
    required String id,
    required String jenisDokumen,
    String? jenisLainnya,
    required String keperluan,
    required String mintaTandaTangan,
    String? catatan,
    PlatformFile? berkasDiisi,
    PlatformFile? dokumenPendukung,
    bool hapusBerkasDiisi = false,
    bool hapusDokumenPendukung = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'jenis_dokumen': jenisDokumen,
        if (jenisLainnya != null && jenisLainnya.isNotEmpty) 'jenis_dokumen_lainnya': jenisLainnya,
        'keperluan': keperluan,
        'minta_tanda_tangan': mintaTandaTangan,
        if (catatan != null && catatan.isNotEmpty) 'catatan_tambahan': catatan,
        if (hapusBerkasDiisi) 'hapus_berkas_diisi': '1',
        if (hapusDokumenPendukung) 'hapus_dokumen_pendukung': '1',
      });

      if (berkasDiisi != null) {
        formData.files.add(await _fileEntry('berkas_diisi', berkasDiisi));
      }
      if (dokumenPendukung != null) {
        formData.files.add(await _fileEntry('dokumen_pendukung', dokumenPendukung));
      }

      await _api.put(
        '/permohonan-dokumen/$id',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<void> batalkan(String id) async {
    try {
      await _api.post('/permohonan-dokumen/$id/batalkan');
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<void> submit({
    required String jenisDokumen,
    String? jenisLainnya,
    required String keperluan,
    required String mintaTandaTangan,
    String? catatan,
    PlatformFile? berkasDiisi,
    PlatformFile? dokumenPendukung,
  }) async {
    try {
      final formData = FormData.fromMap({
        'jenis_dokumen': jenisDokumen,
        if (jenisLainnya != null && jenisLainnya.isNotEmpty) 'jenis_dokumen_lainnya': jenisLainnya,
        'keperluan': keperluan,
        'minta_tanda_tangan': mintaTandaTangan,
        if (catatan != null && catatan.isNotEmpty) 'catatan_tambahan': catatan,
      });

      if (berkasDiisi != null) {
        formData.files.add(await _fileEntry('berkas_diisi', berkasDiisi));
      }
      if (dokumenPendukung != null) {
        formData.files.add(await _fileEntry('dokumen_pendukung', dokumenPendukung));
      }

      await _api.post(
        '/permohonan-dokumen',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<List<int>> downloadSurat(String permohonanId, {required bool ttd}) async {
    final jenis = ttd ? 'ttd' : 'balasan';
    try {
      final res = await _api.download('/permohonan-dokumen/$permohonanId/surat/$jenis');
      return res.data ?? [];
    } on DioException catch (e) {
      throw Exception(_api.messageFromError(e));
    }
  }

  Future<MapEntry<String, MultipartFile>> _fileEntry(String key, PlatformFile file) async {
    if (file.bytes != null) {
      return MapEntry(key, MultipartFile.fromBytes(file.bytes!, filename: file.name));
    }
    return MapEntry(key, await MultipartFile.fromFile(file.path!, filename: file.name));
  }
}
